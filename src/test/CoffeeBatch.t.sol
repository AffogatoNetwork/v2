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

    // Calls another contract with a specified `msg.sender`
    function prank(address) external;

    // Sets an address' balance, (who, newBalance)
    function deal(address, uint256) external;

    // Sets an address' code, (who, newCode)
    function etch(address, bytes calldata) external;

    // Expects revert with message
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

    //Events for testing
    event SetMinter(address indexed owner, address indexed minter, bool status);

    function setUp() public {
        hevm = Hevm(HEVM_ADDRESS);
        coffeeBatch = new CoffeeBatch();
    }

    function test_constructor() public {
        assertEq(coffeeBatch.owner(), address(this));
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

    function test_mint() public {
        assert(false);
    }

    function test_transfer() public {
        assert(false);
    }
}
