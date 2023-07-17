#[contract]

mod Mpesavault {

    use relayvault::erc20::IERC20;
    use relayvault::erc20::IERC20::IERC20Dispatcher;
    use relayvault::erc20::IERC20::IERC20DispatcherTrait;
    
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_contract_address;  
    
    use integer::u256_from_felt252;


    struct Storage { 
        registered_relays: LegacyMap::<ContractAddress, bool>,
        relay_balances: LegacyMap::<ContractAddress, bool>,
        transactions: LegacyMap::<felt252, SendTransaction>,          
    }

    #[event]
    fn Sent(relay: ContractAddress, to: ContractAddress, amount: felt252) {}

    // new relay registering 
    #[external]   
    fn register() {

        let this_contract = get_contract_address();
        let caller = get_caller_address();
        //send some funds to the wallet 
        IERC20Dispatcher {contract_address: 0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8}.transfer_from(caller, this_contract, u256_from_felt252(amount));
        registered_relays::write(caller, true);         
        return ();   
        }


    // how relayer sends money. The receiver is able to see from offchain the recipient, user wallet and relayer,  and forward the amount  
    // USDC mainnet: 0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8 
    // @dev sender_address: user who sends. User allows the relayer(caller) to spend
    // @dev to_address: user account or relayer who is supposed to handle transactions on behalf of particular user
    #[external]
    fn send(amount: felt252, to_address: ContractAddress) -> felt252 {
        
        let this_contract = get_contract_address();

        check_balance_helper();

        //send value 
        IERC20Dispatcher {contract_address: 0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8}.transfer_from(this_contract, to_address, u256_from_felt256(amount));

        //update new balance of user and relay 
        relay_balances::write(caller, relay_balance - amount);
        users::write(sender_address, user_amount - amount);

        // emit event 
        Sent(caller: ContractAddress, to: ContractAddress, amount: felt252);
        return ();

    }

    fn check_balance_helper() {
        let caller = get_caller_address();
    
        assert(registered_relays::read(caller) == true, 'not a relay');

        let relay_balance = relay_balances::read(caller);
        assert(relay_balance > amount, 'No liquidity');

        return();
    }

    }