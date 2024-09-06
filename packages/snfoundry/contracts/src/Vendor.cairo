use starknet::ContractAddress;
#[starknet::interface]
pub trait IVendor<T> {
    fn buy_tokens(ref self: T, eth_amount_wei: u256);
    fn withdraw(ref self: T);
    fn sell_tokens(ref self: T, amount_tokens: u256);
    fn tokens_per_eth(self: @T) -> u256;
    fn your_token(self: @T) -> ContractAddress;
    fn eth_token(self: @T) -> ContractAddress;
}

#[starknet::contract]
mod Vendor {
    use contracts::YourToken::{IYourTokenDispatcher, IYourTokenDispatcherTrait};
    use core::traits::TryInto;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::access::ownable::interface::IOwnable;
    use openzeppelin::token::erc20::interface::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use starknet::{get_caller_address, get_contract_address};
    use super::{ContractAddress, IVendor};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // ToDo Checkpoint 2: Define const TokensPerEth 
    const TOKENS_PER_ETH: u256 = 100;

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        eth_token: IERC20CamelDispatcher,
        your_token: IYourTokenDispatcher,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        BuyTokens: BuyTokens,
        SellTokens: SellTokens,
    }

    #[derive(Drop, starknet::Event)]
    struct BuyTokens {
        buyer: ContractAddress,
        eth_amount: u256,
        tokens_amount: u256,
    }

    //  ToDo Checkpoint 3: Define the event SellTokens
    #[derive(Drop, starknet::Event)]
    struct SellTokens {
        seller: ContractAddress,
        tokens_amount: u256,
        eth_amount: u256,
    }

    #[constructor]
    // Todo Checkpoint 2: Edit the constructor to initialize the owner of the contract.
    fn constructor(
        ref self: ContractState,
        eth_token_address: ContractAddress,
        your_token_address: ContractAddress,
        owner: ContractAddress
    ) {
        self.eth_token.write(IERC20CamelDispatcher { contract_address: eth_token_address });
        self.your_token.write(IYourTokenDispatcher { contract_address: your_token_address });
        self.ownable.initializer(owner);
    // ToDo Checkpoint 2: Initialize the owner of the contract here.
    }
    #[abi(embed_v0)]
    impl VendorImpl of IVendor<ContractState> {
        // ToDo Checkpoint 2: Implement your function buy_tokens here.
        fn buy_tokens(ref self: ContractState, eth_amount_wei: u256) {
            // Calculate the amount of tokens to transfer
            let tokens_to_transfer: u256 = (eth_amount_wei * self.tokens_per_eth());
            let token = self.your_token.read();
            // Check vendor has enough tokens to sell
            let tokens_available = token.balance_of(get_contract_address());
            assert(tokens_to_transfer <= tokens_available, 'Vendor not enough balance');

            // Get the caller's address
            let recipient = get_caller_address();

            // Transfer ETH from the buyer to the contract
            let eth_token = self.eth_token.read();
            let allowance = eth_token.allowance(recipient, get_contract_address());
            assert(allowance >= eth_amount_wei, 'Allowance is not enough');

            eth_token.transferFrom(recipient, get_contract_address(), eth_amount_wei);
            // Transfer YourToken from the contract to the buyer
            token.approve(get_contract_address(), tokens_to_transfer);
            token.transfer(recipient, tokens_to_transfer);

            // Emit the BuyTokens event
            self
                .emit(
                    BuyTokens {
                        buyer: recipient,
                        eth_amount: eth_amount_wei,
                        tokens_amount: tokens_to_transfer
                    }
                );
        }

        // ToDo Checkpoint 2: Implement your function withdraw here.
        fn withdraw(ref self: ContractState) {
            self.ownable.assert_only_owner();
            let eth_token = self.eth_token.read();
            let balance = eth_token.balanceOf(get_contract_address());
            eth_token.approve(get_contract_address(), balance);
            eth_token.transfer(self.ownable.owner(), balance);
        }

        // ToDo Checkpoint 3: Implement your function sell_tokens here.
        fn sell_tokens(ref self: ContractState, amount_tokens: u256) {
            // Calculate the amount of ETH used to buy the tokens
            let eth_amount_wei = amount_tokens / self.tokens_per_eth();
            // Check seller has enough tokens to sell
            let seller = get_caller_address();
            let token = self.your_token.read();
            let token_balance = token.balance_of(seller);
            assert(token_balance >= amount_tokens, 'Seller not enough balance');
            // Check seller has approved the contract to transfer the tokens
            let token_allowance = token.allowance(seller, get_contract_address());
            assert(token_allowance >= amount_tokens, 'Allowance is not enough');
            // Transfer tokens from the seller to the contract
            token.transfer_from(seller, get_contract_address(), amount_tokens);

            // Transfer ETH from the contract to the seller
            let eth_token = self.eth_token.read();
            // Check contract has enough ETH to sell
            let eth_balance = eth_token.balanceOf(get_contract_address());
            assert(eth_balance >= eth_amount_wei, 'Contract not enough balance');
            // Approve to transfer the ETH
            eth_token.approve(get_contract_address(), eth_amount_wei);
            eth_token.transferFrom(get_contract_address(), seller, eth_amount_wei);

            // Emit the SellTokens event
            self
                .emit(
                    SellTokens {
                        seller: seller, tokens_amount: amount_tokens, eth_amount: eth_amount_wei
                    }
                );
        }

        // ToDo Checkpoint 2: Modify to return the amount of tokens per 1 ETH.
        fn tokens_per_eth(self: @ContractState) -> u256 {
            TOKENS_PER_ETH
        }

        fn your_token(self: @ContractState) -> ContractAddress {
            self.your_token.read().contract_address
        }

        fn eth_token(self: @ContractState) -> ContractAddress {
            self.eth_token.read().contract_address
        }
    }
}
