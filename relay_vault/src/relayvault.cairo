use starknet::ContractAddress;
use array::{ArrayTrait};

#[starknet::interface]
trait MpesavaultTrait<T> {
    fn register(ref self: T, amount: u256);
    fn send(ref self: T, amount: u256, from: starknet::ContractAddress, to: starknet::ContractAddress);
    fn withdraw(ref self: T, amount: u256);
    fn view_relays(self: @T) -> Array<felt252>;
    fn view_balance(self: @T) -> u256;
}


#[starknet::contract]
mod Relayvault {

    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};

    use relayvault::interface::IERC20ABI;
    use relayvault::interface::IERC20ABIDispatcher;
    use relayvault::interface::IERC20ABIDispatcherTrait;

    #[event] 
    #[derive(Drop, starknet::Event)]
    enum Event {
        Sent: Sent,
    }

    #[derive(Drop, starknet::Event)]
    struct Sent {
        #[key]
        relay: starknet::ContractAddress,
        #[key]
        to: starknet::ContractAddress,
        #[key]
        amount: u256
    }

    #[storage]
    struct Storage {
        registered_relays: LegacyMap<ContractAddress, bool>,
        relay_balances: LegacyMap<ContractAddress, u256>,
        transactions: LegacyMap<felt252, SendTransaction>,
        owner_address: starknet::ContractAddress,
        token: IERC20ABIDispatcher,
        relays: ArrayTrait::felt252,
        amount_in_vault: u256,
        fees_collected: u256, 
        fee_percentage: u256,
        withdraw_timelock: u64
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, token_address: starknet::ContractAddress, fee_percentage: u256, withdraw_time: u64
    ) {
        let caller = get_caller_address();
        self.owner_address.write(caller);
        self.token.write(IERC20ABIDispatcher {contract_address: token_address});
        self.fee_percentage.write(fee_percentage);
        self.withdraw_timelock.write(withdraw_time);
    }

    #[external(v0)]
    impl Mpesavault of super::MpesavaultTrait<ContractState> {

        fn view_relays(self: @ContractState) -> Array<felt252>{
            // let mut current_relays: Array<felt252> = self.relays.read();
            // current_relays 
            self.relays.read()
        }

        fn view_balance(self: @ContractState) -> u256 {
            self.amount_in_vault.read()
        }

        

        // @dev How individual relays register to the vault by sending a certain amount of money
        fn register(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();

            let this_contract = get_contract_address();

            self.token.read().transfer_from(
                caller, 
                this_contract, 
                amount);
            
            self.registered_relays.write(caller, true);   
            let current_amount = self.amount_in_vault.read();
            self.amount_in_vault.write(current_amount + amount);
            // how to write to an array in storage
            self.relays.write(caller);

            return ();   
        }
        
        // @dev The 'trusted' admin sends money to receiver relay after receiving confirmation of offchain transfer of funds to a certain relay
        fn send(ref self: ContractState, amount: u256, from: starknet::ContractAddress, to: starknet::ContractAddress) {

            self.check_admin();
            let this_contract = get_contract_address();
            
            // ' );

            let original_balance = self.relay_balances.read(from);

            // TODO: Subtract fee from amount to be sent

            self.check_balance_helper(amount);           

            self.token.read().transfer_from(
                this_contract, 
                to, 
                amount
            );

            self.relay_balances.write(from, original_balance - amount); 

            self.emit(Event::Sent(Sent {
                relay: from,
                to: to,
                amount: amount,
            }));

            // self.emit(Sent{
            //     relay: from, 
            //     to: to, 
            //     amount: amount
            // })
        }
        
        // @dev Relay can withdraw their funds and stop being a relay, after a certain amount of time has passed  
        fn withdraw (ref self: ContractState, amount: u256) {
            let this_contract = get_contract_address();
            let caller = get_caller_address();
            self.check_balance_helper(amount);
            self.relay_balances.write(caller, self.relay_balances.read(caller) - amount);
            let current_amount = self.amount_in_vault.read();
            self.amount_in_vault.write(current_amount - amount);
            let current_timestamp: u64 = get_block_timestamp();
            let withdraw_period: u64 = self.withdraw_timelock.read();
            if (get_block_timestamp() > current_timestamp + withdraw_period) {
                self.token.read().transfer_from(this_contract, caller, amount);
            }
            return();

        }

    }

    //
    //internal
    //
    #[generate_trait]
    impl PrivateMethods of PrivateMethodsTrait {

        fn check_balance_helper(self: @ContractState, amount: u256) {
            let caller = get_caller_address();

            assert(self.registered_relays.read(caller) == true, 'not a relay');

            assert(self.relay_balances.read(caller) > amount, 'No liquidity');

            return();
        }

        fn check_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner_address.read(), 'Not the admin');
        }
    }
    

    impl IERC20ABIImpl of IERC20ABI<ContractState> {
        fn transfer_from(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256)
            {
                let caller = get_caller_address();
                self.token.read().balance_of(caller) - amount;
                self.token.read().balance_of(recipient) + amount;
            }

            fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
                self.token.read(account)

            }

    }

}