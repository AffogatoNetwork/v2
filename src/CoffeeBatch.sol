// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "openzeppelin-contracts/access/Ownable.sol";
import "solmate/tokens/ERC721.sol";

// TODO: create interface for CB children
// TODO: add 721

contract CoffeeBatch is Ownable, ERC721 {
    mapping(address => bool) public minters;
    uint256 currentID = 0;

    event SetMinter(address indexed owner, address indexed minter, bool status);

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    modifier onlyMinter() {
        require(minters[msg.sender], "CoffeeBatch: caller is not a minter");
        _;
    }

    function addMinter(address _minter) external onlyOwner {
        minters[_minter] = true;
        emit SetMinter(msg.sender, _minter, true);
    }

    function removeMinter(address _minter) external onlyOwner {
        minters[_minter] = false;
        emit SetMinter(msg.sender, _minter, false);
    }

    function mint(address _receiver) external onlyMinter {
        currentID++;
        _mint(_receiver, currentID);
    }

    function burn(uint256 _id) external {
        require(
            ownerOf[_id] == msg.sender,
            "CoffeeBatch: caller is not the owner"
        );
        _burn(_id);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        //do something
        return "";
    }
}
