// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Wallet is Ownable{
    using SafeERC20 for IERC20;
    mapping(address => mapping(address => uint256)) public balances;
    bool public initialized;

    function initialize(address owner) public{
        require(!initialized, 'Already initialized');
        initialized = true;
        _transferOwnership(owner);
    }

    function deposit(address token, uint256 amount) public payable {
        if (token == address(0)) {
            balances[msg.sender][token] += msg.value;
        } else {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
            balances[msg.sender][token] += amount;
        }
    }

    function withdraw(address token, uint256 amount) public onlyOwner{
        if(token == address(0)){
            (bool sent, ) = msg.sender.call{value: amount}("");
            require(sent, "Failed to send Ether");
        }else{
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }
}