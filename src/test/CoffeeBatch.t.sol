// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../CoffeeBatch.sol";

interface Hevm {
    // Set block.timestamp (newTimestamp)
    function warp(uint256) external;

    // Set block.height (newHeight)
    function roll(uint256) external;

    // Loads a storage slot from an address (who, slot)
    function load(address, bytes32) external returns (bytes32);

    // Stores a value to an address' storage slot, (who, slot, value)
    function store(
        address,
        bytes32,
        bytes32
    ) external;

    // Signs data, (privateKey, digest) => (r, v, s)
    function sign(uint256, bytes32)
        external
        returns (
            uint8,
            bytes32,
            bytes32
        );

    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);

    // Performs a foreign function call via terminal, (stringInputs) => (result)
    function ffi(string[] calldata) external returns (bytes memory);

    // Performs the next smart contract call with specified `msg.sender`, (newSender)
    function prank(address) external;

    // Performs all the following smart contract calls with specified `msg.sender`, (newSender)
    function startPrank(address) external;

    // Stop smart contract calls using the specified address with prankStart()
    function stopPrank() external;

    // Sets an address' balance, (who, newBalance)
    function deal(address, uint256) external;

    // Sets an address' code, (who, newCode)
    function etch(address, bytes calldata) external;

    // Expects an error on next call
    function expectRevert(bytes calldata) external;

    // Expects the next emitted event. Params check topic 1, topic 2, topic 3 and data are the same.
    function expectEmit(
        bool,
        bool,
        bool,
        bool
    ) external;
}

contract CoffeeBatchTest is DSTest {
    address user1 = address(0x1);
    address user2 = address(0x2);

    Hevm hevm;
    CoffeeBatch coffeeBatch;

    // @dev Events for testing
    event SetMinter(address indexed owner, address indexed minter, bool status);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function setUp() public {
        hevm = Hevm(HEVM_ADDRESS);
        coffeeBatch = new CoffeeBatch("Affogato Coffee Batch", "CAFE");
    }

    function test_constructor() public {
        assertEq(coffeeBatch.owner(), address(this));
        assertEq(coffeeBatch.name(), "Affogato Coffee Batch");
        assertEq(coffeeBatch.symbol(), "CAFE");
    }

    function test_addMinter(address _minter) public {
        // @dev revert on not owner
        hevm.prank(user1);
        hevm.expectRevert("Ownable: caller is not the owner");
        coffeeBatch.addMinter(_minter);

        // @dev adds minter
        hevm.expectEmit(true, true, false, true);
        emit SetMinter(address(this), _minter, true);
        coffeeBatch.addMinter(_minter);
        assert(coffeeBatch.minters(_minter));
    }

    function test_removeMinter(address _minter) public {
        // @dev revert on not owner
        hevm.prank(user1);
        hevm.expectRevert("Ownable: caller is not the owner");
        coffeeBatch.removeMinter(_minter);

        // @dev removes minter
        hevm.expectEmit(true, true, false, true);
        emit SetMinter(address(this), _minter, false);
        coffeeBatch.removeMinter(_minter);
        assert(!coffeeBatch.minters(_minter));
    }

    function test_mint(address _receiver) public {
        // @dev revert on not owner
        hevm.prank(user1);
        hevm.expectRevert("CoffeeBatch: caller is not a minter");
        coffeeBatch.mint(_receiver);

        coffeeBatch.addMinter(user1);
        hevm.startPrank(user1);
        if (_receiver == address(0)) {
            hevm.expectRevert("INVALID_RECIPIENT");
            coffeeBatch.mint(_receiver);
            return;
        }

        hevm.expectEmit(true, true, true, true);
        emit Transfer(address(0), _receiver, 1);
        coffeeBatch.mint(_receiver);

        assertEq(coffeeBatch.balanceOf(_receiver), 1);
        assertEq(coffeeBatch.ownerOf(1), _receiver);
        coffeeBatch.mint(_receiver);
        coffeeBatch.mint(_receiver);
        assertEq(coffeeBatch.balanceOf(_receiver), 3);
        assertEq(coffeeBatch.ownerOf(2), _receiver);
        assertEq(coffeeBatch.ownerOf(3), _receiver);
    }

    function test_burn() public {
        coffeeBatch.addMinter(user1);
        //        hevm.startPrank(user1);
        hevm.prank(user1);
        coffeeBatch.mint(user1);

        hevm.expectRevert("CoffeeBatch: caller is not the owner");
        hevm.prank(user2);
        coffeeBatch.burn(1);

        hevm.expectEmit(true, true, true, true);
        hevm.prank(user1);
        emit Transfer(user1, address(0), 1);
        coffeeBatch.burn(1);

        assertEq(coffeeBatch.balanceOf(user1), 0);
        assertEq(coffeeBatch.ownerOf(1), address(0));
    }

    function test_transfer() public {
        assert(false);
    }

    //TODO: test delete approval
    function test_approval() public {
        assert(false);
    }
}
