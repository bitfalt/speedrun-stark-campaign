/**
 * This file is autogenerated by Scaffold-Stark.
 * You should not edit it manually or your changes might be overwritten.
 */

const deployedContracts = {
  devnet: {
    ExampleExternalContract: {
      address:
        "0x5cce6e1ae5356a413973e80a686ba57409d40cddd1e44009874946e2f4d0f93",
      abi: [
        {
          type: "impl",
          name: "ExampleExternalContractImpl",
          interface_name:
            "contracts::ExampleExternalContract::IExampleExternalContract",
        },
        {
          type: "enum",
          name: "core::bool",
          variants: [
            {
              name: "False",
              type: "()",
            },
            {
              name: "True",
              type: "()",
            },
          ],
        },
        {
          type: "interface",
          name: "contracts::ExampleExternalContract::IExampleExternalContract",
          items: [
            {
              type: "function",
              name: "complete",
              inputs: [],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "completed",
              inputs: [],
              outputs: [
                {
                  type: "core::bool",
                },
              ],
              state_mutability: "view",
            },
          ],
        },
        {
          type: "event",
          name: "contracts::ExampleExternalContract::ExampleExternalContract::Event",
          kind: "enum",
          variants: [],
        },
      ],
      classHash:
        "0x66e60aaac2b13b648b4189764def40f09014422a3f816b2ba58105d8196afe1",
    },
    Staker: {
      address:
        "0x5090d697f57ff4328b99d39574f4d3932cbc276b9539a373ddc699803fcd135",
      abi: [
        {
          type: "impl",
          name: "StakerImpl",
          interface_name: "contracts::Staker::IStaker",
        },
        {
          type: "struct",
          name: "core::integer::u256",
          members: [
            {
              name: "low",
              type: "core::integer::u128",
            },
            {
              name: "high",
              type: "core::integer::u128",
            },
          ],
        },
        {
          type: "enum",
          name: "core::bool",
          variants: [
            {
              name: "False",
              type: "()",
            },
            {
              name: "True",
              type: "()",
            },
          ],
        },
        {
          type: "struct",
          name: "openzeppelin::token::erc20::interface::IERC20CamelDispatcher",
          members: [
            {
              name: "contract_address",
              type: "core::starknet::contract_address::ContractAddress",
            },
          ],
        },
        {
          type: "interface",
          name: "contracts::Staker::IStaker",
          items: [
            {
              type: "function",
              name: "execute",
              inputs: [],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "stake",
              inputs: [
                {
                  name: "amount",
                  type: "core::integer::u256",
                },
              ],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "withdraw",
              inputs: [],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "balances",
              inputs: [
                {
                  name: "account",
                  type: "core::starknet::contract_address::ContractAddress",
                },
              ],
              outputs: [
                {
                  type: "core::integer::u256",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "completed",
              inputs: [],
              outputs: [
                {
                  type: "core::bool",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "deadline",
              inputs: [],
              outputs: [
                {
                  type: "core::integer::u64",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "example_external_contract",
              inputs: [],
              outputs: [
                {
                  type: "core::starknet::contract_address::ContractAddress",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "open_for_withdraw",
              inputs: [],
              outputs: [
                {
                  type: "core::bool",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "eth_token_dispatcher",
              inputs: [],
              outputs: [
                {
                  type: "openzeppelin::token::erc20::interface::IERC20CamelDispatcher",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "threshold",
              inputs: [],
              outputs: [
                {
                  type: "core::integer::u256",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "total_balance",
              inputs: [],
              outputs: [
                {
                  type: "core::integer::u256",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "time_left",
              inputs: [],
              outputs: [
                {
                  type: "core::integer::u64",
                },
              ],
              state_mutability: "view",
            },
          ],
        },
        {
          type: "constructor",
          name: "constructor",
          inputs: [
            {
              name: "eth_contract",
              type: "core::starknet::contract_address::ContractAddress",
            },
            {
              name: "external_contract_address",
              type: "core::starknet::contract_address::ContractAddress",
            },
          ],
        },
        {
          type: "event",
          name: "contracts::Staker::Staker::Stake",
          kind: "struct",
          members: [
            {
              name: "sender",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
            {
              name: "amount",
              type: "core::integer::u256",
              kind: "data",
            },
          ],
        },
        {
          type: "event",
          name: "contracts::Staker::Staker::Event",
          kind: "enum",
          variants: [
            {
              name: "Stake",
              type: "contracts::Staker::Staker::Stake",
              kind: "nested",
            },
          ],
        },
      ],
      classHash:
        "0x3e4b3e218dd4174aa24d04acb875d9e2978326b652520eec290c4b3113eece0",
    },
  },
} as const;

export default deployedContracts;
