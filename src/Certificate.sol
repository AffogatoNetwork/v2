// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "openzeppelin-contracts/access/Ownable.sol";
import "solmate/tokens/ERC721.sol";

// TODO: create interface for CB children

// 1. create token
// 2. transfer to CB
// 3. update CB state

//TODO: this should be simpleERC998
interface ICoffeeBatch {
    function onERC721Received(
        address _from,
        uint256 _tokenId,
        uint256 _childTokenId
    ) external returns (bool);
}

contract Certificate is Ownable, ERC721 {
    mapping(address => bool) public minters;
    uint256 currentID = 0;
    bytes4 magicNumber = 0x150b7a02;

    event SetMinter(address indexed owner, address indexed minter, bool status);

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    modifier onlyMinter() {
        require(minters[msg.sender], "Certificate: caller is not a minter");
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

    function mint(address _coffeeBatch, uint256 _coffeeBatchId)
        external
        onlyMinter
    {
        currentID++;
        _mint(_coffeeBatch, currentID);
        bool result = ICoffeeBatch(_coffeeBatch).onERC721Received(
            msg.sender,
            _coffeeBatchId,
            currentID
        );
        require(result, "Not supported");
    }

    function burn(uint256 _id) external {
        require(
            ownerOf[_id] == msg.sender,
            "Certificate: caller is not the owner"
        );
        _burn(_id);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        //do something
        return "";
    }
}
