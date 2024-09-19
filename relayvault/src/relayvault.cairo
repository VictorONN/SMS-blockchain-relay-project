use starknet::{ContractAddress, ClassHash};

#[starknet::interface]
pub trait IUpgradeableContract<TContractState> {
    fn upgrade(ref self: TContractState, impl_hash: ClassHash);
    fn version(self: @TContractState) -> u8;
}

#[starknet::interface]
pub trait IRelayvaultTrait<TContractState> {
    // admin function
    fn set_parameters(
        ref self: TContractState,
        token_address: starknet::ContractAddress,
        fee_percentage: u64,
        withdraw_time: u64
    );
    // relay function
    fn relay_register(ref self: TContractState, amount: u256);
    //user buy
    fn user_buy(
        ref self: TContractState,
        user_to: ContractAddress,
        relayer_from: ContractAddress,
        amount: u256
    );
    //user send function
    fn user_send(ref self: TContractState, to: starknet::ContractAddress, amount: u256);
    // view function for user balance
    fn view_user_balance(self: @TContractState, address: starknet::ContractAddress) -> u256;
    // user withdraw function
    fn user_withdraw(ref self: TContractState, amount: u256) -> u256;
    // relay deposit to vault
    fn relay_deposit(ref self: TContractState, amount: u256);
    // relay withdraw from vault
    fn relay_withdraw(ref self: TContractState, amount: u256);
    // view function for vault balance
    fn view_total_balance(self: @TContractState) -> u256;
    // view function for relayer balance
    fn view_relay_balance(self: @TContractState, address: starknet::ContractAddress) -> u256;
}

#[starknet::contract]
mod Relayvault {
    use openzeppelin_token::erc20::interface::IERC20DispatcherTrait;
    use core::traits::{TryInto, Into};
    use core::zeroable::Zeroable;
    use core::starknet::{
        ContractAddress, get_caller_address, get_contract_address, get_block_timestamp, ClassHash
    };
    use array::{ArrayTrait};
    use core::starknet::storage::{
        Map, StoragePointerReadAccess, StoragePointerWriteAccess, StorageMapReadAccess,
        StorageMapWriteAccess, StoragePathEntry
    };
    use starknet::SyscallResultTrait;

    use openzeppelin::token::erc20::interface::{IERC20Dispatcher};
    use openzeppelin::token::erc20::{ERC20Component, ERC20HooksEmptyImpl};

    use super::IRelayvaultTrait;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Sent: Sent,
        Upgraded: Upgraded
    }

    /// @dev How much money was sent and destination address
    #[derive(Drop, starknet::Event)]
    struct Sent {
        #[key]
        destination_to: ContractAddress,
        #[key]
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Upgraded {
        implementation: ClassHash
    }

    #[storage]
    struct Storage {
        registered_relays: Map<ContractAddress, bool>,
        relay_balances: Map<ContractAddress, u256>,
        user_balances: Map<ContractAddress, u256>,
        owner_address: ContractAddress,
        token: ContractAddress, // Payment token address
        amount_in_vault: u256,
        fees_collected: u256,
        fee_percentage: u64,
        exit_timelock: u64,
        version: u8,
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
        // self.token.write(IERC20Dispatcher { contract_address: token_address });
        self.token.write(token_address);
        self.fee_percentage.write(fee_percentage);
        self.exit_timelock.write(withdraw_time);
    }

    // Public functions inside the impl block
    #[abi(embed_v0)]
    impl RelayvaultImpl of super::IRelayvaultTrait<ContractState> {
        fn view_total_balance(self: @ContractState) -> u256 {
            self.amount_in_vault.read()
        }

        fn view_relay_balance(self: @ContractState, address: starknet::ContractAddress) -> u256 {
            //need this because even registered relays can have 0 balance like all non-registered
            //ones
            assert(self.registered_relays.entry(address).read() == true, 'address is not a relay');

            self.relay_balances.entry(address).read()
        }

        fn user_send(ref self: ContractState, to: starknet::ContractAddress, amount: u256) {
            let _caller = get_caller_address();
            assert(self.user_balances.entry(_caller).read() > amount, 'user: inadequate funds');

            let _this_contract = get_contract_address();
            // TODO: implement fee maybe
            let token_dispatcher = IERC20Dispatcher { contract_address: self.token.read() };
            let have_tokens_been_transferred = token_dispatcher.transfer(to, amount);
            // self.token.read().transfer(to, amount);
            if have_tokens_been_transferred {
                //Which is the correct syntax between these two?
                // self.emit(Event::Sent(Sent { destination_to: to, amount: amount, }));
                self.emit(Sent { destination_to: to, amount: amount });
            }
        }

        fn view_user_balance(self: @ContractState, address: starknet::ContractAddress) -> u256 {
            // TODO: how to check for non registered users.
            // I dont know how default values show in Starknet but they could show 0 even for non
            // registered users
            self.user_balances.entry(address).read()
        }

        fn user_withdraw(ref self: ContractState, amount: u256) -> u256 {
            let caller = get_caller_address();
            let mut user_balance = self.user_balances.entry(caller).read();
            assert(user_balance > amount, 'user: inadequate funds');

            let _this_contract = get_contract_address();

            let _new_user_balance = user_balance - amount;

            let token_dispatcher = IERC20Dispatcher { contract_address: self.token.read() };
            let have_tokens_been_transferred = token_dispatcher.transfer(caller, amount);

            if have_tokens_been_transferred {
                self.user_balances.entry(caller).write(_new_user_balance);
            }

            // self.token.read().transfer(caller, amount);
            // return the new balance

            // self.user_balances.entry(caller).read()
            _new_user_balance
        }

        fn user_buy(
            ref self: ContractState,
            user_to: ContractAddress,
            relayer_from: ContractAddress,
            amount: u256
        ) {
            self.check_admin();
            let relayer_balance = self.relay_balances.entry(relayer_from).read();
            assert(relayer_balance > amount, 'relayer: inadequate funds');
            self.relay_balances.entry(relayer_from).write(relayer_balance - amount);
            // TODO: implement fee
            self.user_balances.entry(user_to).write(self.user_balances.read(user_to) + amount);
        }

        // mainnet USDC: 0x053C91253BC9682c04929cA02ED00b3E423f6710D2ee7e0D5EBB06F3eCF368A8
        // goerli USDC: 0x005a643907b9a4bc6a55e9069c4fd5fd1f5c79a22470690f75556c4736e34426
        // fee percentage: 0x2
        // withdraw_time: 24 hrs which is 86400s which is 0x15180 in hex
        fn set_parameters(
            ref self: ContractState,
            token_address: ContractAddress,
            fee_percentage: u64,
            withdraw_time: u64
        ) {
            self.check_admin();
            // self.token.write(IERC20Dispatcher { contract_address: token_address });
            self.token.write(token_address);
            self.fee_percentage.write(fee_percentage);
            self.exit_timelock.write(withdraw_time);
        }

        fn relay_deposit(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();

            assert(self.registered_relays.entry(caller).read() == true, 'relay: not a relay');

            let this_contract = get_contract_address();

            let token_dispatcher = IERC20Dispatcher { contract_address: self.token.read() };
            let have_tokens_been_transferred = token_dispatcher
                .transfer_from(caller, this_contract, amount);

            if have_tokens_been_transferred {
                let current_amount = self.amount_in_vault.read();
                self.amount_in_vault.write(current_amount + amount);

                let relay_amount = self.relay_balances.entry(caller).read();
                self.relay_balances.entry(caller).write(relay_amount + amount);
            }
            // self.token.read().transferFrom(caller, this_contract, amount);

        }

        // @dev How individual relays register to the vault by sending a certain amount of money
        fn relay_register(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();

            let this_contract = get_contract_address();

            // self.token.read().transferFrom(caller, this_contract, amount);

            let token_dispatcher = IERC20Dispatcher { contract_address: self.token.read() };
            let have_tokens_been_transferred = token_dispatcher
                .transfer_from(caller, this_contract, amount);

            if have_tokens_been_transferred {
                self.relay_balances.entry(caller).write(amount);

                self.registered_relays.entry(caller).write(true);
                let current_amount = self.amount_in_vault.read();
                self.amount_in_vault.write(current_amount + amount);
            }
        }

        // TODO: IMPROVE WITHDRAW LOGIC
        //       maybe introduce a notify withdraw function
        // @dev A relay can withdraw their funds and stop being a relay. Their is a cool down period
        // of time until funds actually exit the contract
        fn relay_withdraw(ref self: ContractState, amount: u256) {
            let _this_contract = get_contract_address();
            let _caller = get_caller_address();
            let _withdraw_period: u64 = self.exit_timelock.read();
            //update relayer amount
            self.check_balance_helper(amount);
            self
                .relay_balances
                .entry(_caller)
                .write(self.relay_balances.entry(_caller).read() - amount);
            //update vault amount
            let _current_amount = self.amount_in_vault.read();
            self.amount_in_vault.write(_current_amount - amount);

            if (get_block_timestamp() > get_block_timestamp() + _withdraw_period) {
                let token_dispatcher = IERC20Dispatcher { contract_address: self.token.read() };
                let have_tokens_been_transferred = token_dispatcher.transfer(_caller, amount);

                if have_tokens_been_transferred {
                    self
                        .relay_balances
                        .entry(_caller)
                        .write(self.relay_balances.entry(_caller).read() - amount);
                    self.amount_in_vault.write(_current_amount - amount);
                }
            }
        }
    }
    //
    //internal
    //
    #[generate_trait]
    impl PrivateMethods of PrivateMethodsTrait {
        fn check_balance_helper(self: @ContractState, amount: u256) {
            let _caller = get_caller_address();

            assert(self.relay_balances.entry(_caller).read() > amount, 'No liquidity');

            return ();
        }

        fn check_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner_address.read(), 'Not the admin');
        }
    }

    #[abi(embed_v0)]
    impl UpgradeableContract of super::IUpgradeableContract<ContractState> {
        fn upgrade(ref self: ContractState, impl_hash: ClassHash) {
            assert(impl_hash.is_non_zero(), 'Class hash cannot be zero');
            self.check_admin();
            starknet::syscalls::replace_class_syscall(impl_hash).unwrap_syscall();
            self.version.write(self.version.read() + 1);
            self.emit(Event::Upgraded(Upgraded { implementation: impl_hash }))
        }

        fn version(self: @ContractState) -> u8 {
            self.version.read()
        }
    }
}
