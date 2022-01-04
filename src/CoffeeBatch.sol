// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "openzeppelin-contracts/access/Ownable.sol";

// TODO: create interface for CB children
// TODO: add 721

contract CoffeeBatch is Ownable {
    mapping(address => bool) public minters;

    event SetMinter(address indexed owner, address indexed minter, bool status);

    function addMinter(address minter) public onlyOwner {
        minters[minter] = true;
        emit SetMinter(msg.sender, minter, true);
    }

    function removeMinter(address minter) public onlyOwner {
        minters[minter] = false;
        emit SetMinter(msg.sender, minter, false);
    }
}
