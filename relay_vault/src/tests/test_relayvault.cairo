use starknet::ContractAddress;
use integer::u256; 
use starknet::testing::set_caller_address;

fn STATE() -> relayvault::ContractState {
    Relayvault::contract_state_for_testing()
}

#[test]
fn test_constructor () {
    let mut state = STATE();
    Relayvault::constructor(ref state, )
}

#[test]
#[available_gas(2000000)]
fn test_send() {
    
}


#[test]
#[available_gas(2000000)]
fn test_withdraw() {
    let mut state = STATE();
    
}

#[test] 
#[available_gas(2000000)]
fn test_register() {
    let mut state = STATE(); 
    
} 