use starknet::ContractAddress;
use array::{ArrayTrait};
use traits::{TryInto, Into};


#[starknet::interface]
trait MpesavaultTrait<T> {
    // admin function 
    fn set_parameters(
        ref self: T,
        token_address: starknet::ContractAddress,
        fee_percentage: u64,
        withdraw_time: u64
    );
    // relay function 
    fn register(ref self: T, amount: u256);
    //user buy 
    fn user_buy(ref self: T, amount: u256, relay: starknet::ContractAddress);
    //user send function
    fn user_send(ref self: T, amount: u256, to: starknet::ContractAddress);
    // view function for user balance
    fn view_user_balance(self: @T, address: starknet::ContractAddress) -> u256;
    // user withdraw function 
    fn user_withdraw(ref self: T, amount: u256) -> u256;
    // relay deposit to vault
    fn relay_deposit(ref self: T, amount: u256);
    // relay withdraw from vault
    fn relay_withdraw(ref self: T, amount: u256);
    // view function for vault balance 
    fn view_total_balance(self: @T) -> u256;
    // view function for relayer balance
    fn view_relayer_balance(self: @T, address: starknet::ContractAddress) -> u256;
}

#[starknet::contract]
mod Relayvault {
    use core::traits::TryInto;
    use core::zeroable::Zeroable;
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};

    // use relayvault::interfaces::interface_ERC20::{IERC20Dispatcher, IERC20DispatcherTrait};
    use relayvault::yas_erc20::{IERC20Dispatcher, IERC20DispatcherTrait};

    use super::MpesavaultTrait;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Sent: Sent,
    }

    #[derive(Drop, starknet::Event)]
    struct Sent {
        #[key]
        relay_to: starknet::ContractAddress,
        #[key]
        amount: u256
    }

    #[storage]
    struct Storage {
        //verified relays
        registered_relays: LegacyMap<ContractAddress, bool>,
        //relay balances
        relay_balances: LegacyMap<ContractAddress, u256>,
        //user balances
        user_balances: LegacyMap<ContractAddress, u256>,
        //trusted admin address 
        owner_address: starknet::ContractAddress,
        //token: in our case ERC20
        token: IERC20Dispatcher,
        //total amount in vault 
        amount_in_vault: u256,
        //total fees collected over time 
        fees_collected: u256,
        // fee percentage is a constant, maybe should not be in storage??  
        fee_percentage: u64,
        //amount of time it takes to confirm exit of relay
        exit_timelock: u64
    }

    // TODO: for testnet, pass in my Testnet wallet. Change in mainnet 
    // mainnet USDC: 0x053C91253BC9682c04929cA02ED00b3E423f6710D2ee7e0D5EBB06F3eCF368A8 
    // goerli USDC: 0x005a643907b9a4bc6a55e9069c4fd5fd1f5c79a22470690f75556c4736e34426
    // fee percentage: 0x2
    // withdraw_time: 24 hrs which is 86400s which is 0x15180 in hex

    // 0x005a643907b9a4bc6a55e9069c4fd5fd1f5c79a22470690f75556c4736e34426
    // 0x02d0fb6e2af16293054169d9dc7104a1745687422e34eee7ae935313653dc305
    // 1
    // 86400
    #[constructor]
    fn constructor(
        ref self: ContractState,
        token_address: starknet::ContractAddress,
        owner_address: starknet::ContractAddress,
        fee_percentage: u64,
        withdraw_time: u64
    ) {
        self.owner_address.write(owner_address);
        self.token.write(IERC20Dispatcher { contract_address: token_address });
        self.fee_percentage.write(fee_percentage);
        self.exit_timelock.write(withdraw_time);
    }

    #[external(v0)]
    impl Mpesavault of super::MpesavaultTrait<ContractState> {
        fn view_total_balance(self: @ContractState) -> u256 {
            self.amount_in_vault.read()
        }

        fn view_relayer_balance(self: @ContractState, address: starknet::ContractAddress) -> u256 {
            //confirm address is a registered relay 
            //need this because even registered relays can have 0 balance like all non-registered ones
            assert(self.registered_relays.read(address) == true, 'address is not a relay');

            self.relay_balances.read(address)
        }

        fn user_buy(ref self: ContractState, amount: u256, relay: ContractAddress) {
            let caller = get_caller_address();
            let relay_balance = self.relay_balances.read(relay);
            assert(relay_balance > amount, 'relayer: inadequate funds');
            self.relay_balances.write(relay, relay_balance - amount);
            // TODO: implement fee
            self.user_balances.write(caller, self.user_balances.read(caller) + amount);
        }

        fn user_send(ref self: ContractState, amount: u256, to: starknet::ContractAddress) {
            let caller = get_caller_address();
            assert(self.user_balances.read(caller) > amount, 'user: inadequate funds');

            let this_contract = get_contract_address();
            // TODO: implement fee
            self.token.read().transferFrom(this_contract, to, amount);

            //emit an event 
            self.emit(Event::Sent(Sent { relay_to: to, amount: amount, }));
        }

        fn view_user_balance(self: @ContractState, address: starknet::ContractAddress) -> u256 {
            // TODO: how to check for non registered users. 
            // I dont know how default values show in Starknet but they could show 0 even for non
            // registered users
            self.user_balances.read(address)
        }

        fn user_withdraw(ref self: ContractState, amount: u256) -> u256 {
            let caller = get_caller_address();
            let user_balance = self.user_balances.read(caller);
            assert(user_balance > amount, 'user: inadequate funds');

            let this_contract = get_contract_address();

            self.user_balances.write(caller, user_balance - amount);

            self.token.read().transferFrom(this_contract, caller, amount);
            // return the new balance
            self.user_balances.read(caller)
        }

        // mainnet USDC: 0x053C91253BC9682c04929cA02ED00b3E423f6710D2ee7e0D5EBB06F3eCF368A8 
        // goerli USDC: 0x005a643907b9a4bc6a55e9069c4fd5fd1f5c79a22470690f75556c4736e34426
        // fee percentage: 0x2
        // withdraw_time: 24 hrs which is 86400s which is 0x15180 in hex
        fn set_parameters(
            ref self: ContractState,
            token_address: starknet::ContractAddress,
            fee_percentage: u64,
            withdraw_time: u64
        ) {
            let caller = get_caller_address();
            assert(caller == self.owner_address.read(), 'Not owner');
            self.token.write(IERC20Dispatcher { contract_address: token_address });
            self.fee_percentage.write(fee_percentage);
            self.exit_timelock.write(withdraw_time);
        }

        fn relay_deposit(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();

            assert(self.registered_relays.read(caller) == true, 'relay: not a relay');

            let this_contract = get_contract_address();

            self.token.read().transferFrom(caller, this_contract, amount);

            let current_amount = self.amount_in_vault.read();
            self.amount_in_vault.write(current_amount + amount);

            let relay_amount = self.relay_balances.read(caller);
            self.relay_balances.write(caller, relay_amount + amount);
        // return ();

        }

        // @dev How individual relays register to the vault by sending a certain amount of money
        fn register(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();

            let this_contract = get_contract_address();

            self.token.read().transferFrom(caller, this_contract, amount);

            self.relay_balances.write(caller, amount);

            self.registered_relays.write(caller, true);
            let current_amount = self.amount_in_vault.read();
            self.amount_in_vault.write(current_amount + amount);
        }

        // TODO: IMPROVE WITHDRAW LOGIC
        //       maybe introduce a notify withdraw function 
        // @dev A relay can withdraw their funds and stop being a relay. Their is a cool down period of time until funds actually exit the contract  
        fn relay_withdraw(ref self: ContractState, amount: u256) {
            let this_contract = get_contract_address();
            let caller = get_caller_address();
            let withdraw_period: u64 = self.exit_timelock.read();

            self.check_balance_helper(amount);
            self.relay_balances.write(caller, self.relay_balances.read(caller) - amount);

            let current_amount = self.amount_in_vault.read();
            self.amount_in_vault.write(current_amount - amount);

            if (get_block_timestamp() > get_block_timestamp() + withdraw_period) {
                //Placeholder for easy integration. Use tokens below instead for final implementation
                self.relay_balances.write(caller, self.relay_balances.read(caller) - amount);
                self.amount_in_vault.write(current_amount - amount);

                self.token.read().transferFrom(this_contract, caller, amount);
            }
        }
    }

    //
    //internal
    //
    #[generate_trait]
    impl PrivateMethods of PrivateMethodsTrait {
        fn check_balance_helper(self: @ContractState, amount: u256) {
            let caller = get_caller_address();

            // assert(self.registered_relays.read(caller) == true, 'not a relay');

            assert(self.relay_balances.read(caller) > amount, 'No liquidity');

            return ();
        }

        fn check_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner_address.read(), 'Not the admin');
        }
    }
}
