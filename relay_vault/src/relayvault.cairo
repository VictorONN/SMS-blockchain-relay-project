use starknet::ContractAddress;

#[starknet::interface]
trait MpesavaultTrait<T> {
    fn register(ref self: T, amount: u256);
    fn send(ref self: T, amount: u256, to: starknet::ContractAddress);
}


#[starknet::contract]
mod Relayvault {

    use starknet::{ContractAddress, get_caller_address, get_contract_address, contract_address_try_from_felt252};
    use integer::Felt252IntoU256;

    use relayvault::interface::ERC20ABI;
    use relayvault::interface::ERC20ABIDispatcher;
    use relayvault::interface::ERC20ABIDispatcherTrait;

    #[event] 
    #[derive(Drop, starknet::Event)]
    enum Event {
        Sent: Sent,
    }

    #[derive(Drop, starknet::Event)]
    struct Sent {
        #[key]
        relay: ContractAddress,
        #[key]
        to: ContractAddress,
        #[key]
        amount: u256
    }

    #[storage]
    struct Storage {
        registered_relays: LegacyMap<ContractAddress, bool>,
        relay_balances: LegacyMap<ContractAddress, u256>,
        transactions: LegacyMap<felt252, SendTransaction>,
    }

    #[external(v0)]
    impl Mpesavault of super::MpesavaultTrait<ContractState> {
        fn register(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();

            let this_contract = get_contract_address();

            ERC20ABIDispatcher {contract_address: contract_address_try_from_felt252(0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8)}.transfer_from(caller, this_contract, amount);
            self.registered_relays.write(caller, true);         
            return ();   
        }

        fn send(ref self: ContractState, amount: u256, to: ContractAddress) {
            let this_contract = get_contract_address();

            let caller = get_caller_address();

            let original_balance = self.relay_balances.read(caller);

            self.check_balance_helper(amount);           

            ERC20ABIDispatcher {contract_address: 0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8}.transfer_from(
                this_contract, 
                to, 
                amount
            );

            self.relay_balances.write(caller, original_balance - amount); 

            self.emit(Event::Sent(Sent {
                relay: caller,
                to: to,
                amount: amount,
            }))
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
    }

}