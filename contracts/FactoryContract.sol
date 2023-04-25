// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Wallet.sol";

contract FactoryContract {
    mapping(address => address) public walletOwner;

    function deployWallet(bytes32 salt)
        internal
        returns (address instance)
    {
        require(walletOwner[msg.sender] == address(0), "You already have a wallet");
        bytes memory bytecode = type(Wallet).creationCode;
        assembly {
            instance := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
        walletOwner[msg.sender] = instance;
    }

    function createWallet(
        bytes32 _salt
    )
        external
        returns (address walletAddress)
    {
        walletAddress = deployWallet(_salt);
        Wallet(walletAddress).initialize(msg.sender);
    }
}