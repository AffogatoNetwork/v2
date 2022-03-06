// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "openzeppelin-contracts/access/Ownable.sol";
import "solmate/tokens/ERC721.sol";

// TODO: create interface for CB children

contract CoffeeBatch is Ownable, ERC721 {
    uint256 currentID = 0;

    mapping(address => bool) public minters;

    // tokenId => Token URI
    mapping(uint256 => string) private tokenURIs;

    ////////////////////////////////////////////////////////
    // ERC998ERC721 and ERC998ERC721Enumerable implementation
    ////////////////////////////////////////////////////////

    // tokenId => child contract
    mapping(uint256 => address[]) private childContracts;

    // tokenId => (child address => contract index+1)
    mapping(uint256 => mapping(address => uint256)) private childContractIndex;

    // tokenId => (child address => array of child tokens)
    mapping(uint256 => mapping(address => uint256[])) private childTokens;

    // tokenId => (child address => (child token => child index+1)
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private childTokenIndex;

    // child address => childId => tokenId
    mapping(address => mapping(uint256 => uint256)) internal childTokenOwner;

    event SetMinter(address indexed owner, address indexed minter, bool status);

    event ReceivedChild(
        address indexed _from,
        uint256 indexed _tokenId,
        address indexed _childContract,
        uint256 _childTokenId
    );

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

    function mint(address _receiver, string memory _tokenUri)
        external
        onlyMinter
    {
        currentID++;
        tokenURIs[currentID] = _tokenUri;
        _mint(_receiver, currentID);
    }

    function burn(uint256 _id) external {
        require(
            ownerOf[_id] == msg.sender,
            "CoffeeBatch: caller is not the owner"
        );
        _burn(_id);
    }

    function onERC721Received(
        address _from,
        uint256 _tokenId,
        uint256 _childTokenId
    ) external returns (bool) {
        receiveChild(_from, _tokenId, msg.sender, _childTokenId);
        require(
            ERC721(msg.sender).ownerOf(_childTokenId) != address(0),
            "Child token not owned."
        );
        return true;
    }

    function receiveChild(
        address _from,
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId
    ) private {
        require(ownerOf[_tokenId] != address(0), "_tokenId does not exist.");
        require(
            childTokenIndex[_tokenId][_childContract][_childTokenId] == 0,
            "Cannot receive child token because it has already been received."
        );
        uint256 childTokensLength = childTokens[_tokenId][_childContract]
            .length;
        if (childTokensLength == 0) {
            childContractIndex[_tokenId][_childContract] = childContracts[
                _tokenId
            ].length;
            childContracts[_tokenId].push(_childContract);
        }
        childTokens[_tokenId][_childContract].push(_childTokenId);
        childTokenIndex[_tokenId][_childContract][_childTokenId] =
            childTokensLength +
            1;
        childTokenOwner[_childContract][_childTokenId] = _tokenId;
        emit ReceivedChild(_from, _tokenId, _childContract, _childTokenId);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        //do something
        return tokenURIs[id];
    }

    function rootOwnerOfChild(address _childContract, uint256 _childTokenId)
        external
        view
        returns (uint256 tokenIdOwner)
    {
        return childTokenOwner[_childContract][_childTokenId];
    }

    function ownerOfChild(address _childContract, uint256 _childTokenId)
        external
        view
        returns (address parentTokenOwner, uint256 parentTokenId)
    {
        parentTokenId = childTokenOwner[_childContract][_childTokenId];
        return (ownerOf[parentTokenId], parentTokenId);
    }
}
