use contracts::DiceGame::{IDiceGameDispatcher, IDiceGameDispatcherTrait};
use starknet::ContractAddress;

#[starknet::interface]
pub trait IRiggedRoll<T> {
    fn rigged_roll(ref self: T, amount: u256);
    fn withdraw(ref self: T, to: ContractAddress, amount: u256);
    fn last_dice_value(self: @T) -> u256;
    fn predicted_roll(self: @T) -> u256;
    fn dice_game_dispatcher(self: @T) -> IDiceGameDispatcher;
}

#[starknet::contract]
mod RiggedRoll {
    use openzeppelin::access::ownable::ownable::OwnableComponent::InternalTrait;
use keccak::keccak_u256s_le_inputs;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::token::erc20::interface::IERC20CamelDispatcherTrait;
    use starknet::{ContractAddress, get_contract_address, get_block_number, get_caller_address};
    use super::{IRiggedRoll, IDiceGameDispatcher, IDiceGameDispatcherTrait};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        dice_game: IDiceGameDispatcher,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        predicted_roll: u256
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, dice_game_address: ContractAddress, owner: ContractAddress
    ) {
        self.dice_game.write(IDiceGameDispatcher { contract_address: dice_game_address });
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl RiggedRollImpl of super::IRiggedRoll<ContractState> {
        // ToDo Checkpoint 2: Implement the `rigged_roll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
        fn rigged_roll(ref self: ContractState, amount: u256) {
            // Ensure the amount is at least 0.002 ETH
            assert(amount >= 2000000000000000, 'Not enough ETH');
            // Predict the roll
            let prev_block: u256 = get_block_number().into() - 1;
            let nonce = self.dice_game.read().nonce();
            let array = array![prev_block, nonce];
            let predicted_roll = keccak_u256s_le_inputs(array.span()) % 16;
            self.predicted_roll.write(predicted_roll);

            // Only roll if we're guaranteed to win (roll <= 5)
            if predicted_roll <= 5 {
                let eth_token = self.dice_game.read().eth_token_dispatcher();
                // Send ETH to RiggedRoll contract
                eth_token.transferFrom(get_caller_address(), get_contract_address(), amount);
                // Approve the DiceGame contract to spend RiggedRoll contract ETH
                let dice_game_address = self.dice_game.read().contract_address;
                eth_token.approve(dice_game_address, amount);

                // Call roll_dice on the DiceGame contract
                self.dice_game.read().roll_dice(amount);
            }
        }

        // ToDo Checkpoint 3: Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
        fn withdraw(ref self: ContractState, to: ContractAddress, amount: u256) {
            self.ownable.assert_only_owner();
            let eth_token = self.dice_game.read().eth_token_dispatcher();
            assert(amount <= eth_token.balanceOf(get_contract_address()), 'Not enough balance');
            eth_token.transfer(to, amount);
        }

        fn last_dice_value(self: @ContractState) -> u256 {
            self.dice_game.read().last_dice_value()
        }
        fn predicted_roll(self: @ContractState) -> u256 {
            self.predicted_roll.read()
        }
        fn dice_game_dispatcher(self: @ContractState) -> IDiceGameDispatcher {
            self.dice_game.read()
        }
    }
}
