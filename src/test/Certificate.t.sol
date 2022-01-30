// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../Certificate.sol";
import "../CoffeeBatch.sol";
import "./Hevm.sol";

contract CertificateTest is DSTest {
    address user1 = address(0x1);
    address user2 = address(0x2);
    CoffeeBatch coffeeBatch = new CoffeeBatch("Affogato Coffee Batch", "CAFE");

    Hevm hevm;
    Certificate certificate;

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
        certificate = new Certificate("Affogato Certificate", "CERT");
        coffeeBatch.addMinter(user1);
    }

    function test_constructor() public {
        assertEq(certificate.owner(), address(this));
        assertEq(certificate.name(), "Affogato Certificate");
        assertEq(certificate.symbol(), "CERT");
    }

    function test_addMinter(address _minter) public {
        // @dev revert on not owner
        hevm.prank(user1);
        hevm.expectRevert("Ownable: caller is not the owner");
        certificate.addMinter(_minter);

        // @dev adds minter
        hevm.expectEmit(true, true, false, true);
        emit SetMinter(address(this), _minter, true);
        certificate.addMinter(_minter);
        assert(certificate.minters(_minter));
    }

    function test_removeMinter(address _minter) public {
        // @dev revert on not owner
        hevm.prank(user1);
        hevm.expectRevert("Ownable: caller is not the owner");
        certificate.removeMinter(_minter);

        // @dev removes minter
        hevm.expectEmit(true, true, false, true);
        emit SetMinter(address(this), _minter, false);
        certificate.removeMinter(_minter);
        assert(!certificate.minters(_minter));
    }

    function test_mint() public {
        // @dev revert on not owner
        hevm.prank(user1);
        hevm.expectRevert("Certificate: caller is not a minter");
        certificate.mint(address(coffeeBatch), 1);

        certificate.addMinter(user1);
        hevm.startPrank(user1);
        hevm.expectRevert("INVALID_RECIPIENT");
        certificate.mint(address(0), 1);

        hevm.expectEmit(true, true, true, true);
        emit Transfer(address(0), address(coffeeBatch), 1);
        certificate.mint(address(coffeeBatch), 1);

        assertEq(certificate.balanceOf(address(coffeeBatch)), 1);
        assertEq(certificate.ownerOf(1), address(coffeeBatch));
        certificate.mint(address(coffeeBatch));
        certificate.mint(address(coffeeBatch));
        assertEq(certificate.balanceOf(address(coffeeBatch)), 3);
        assertEq(certificate.ownerOf(2), address(coffeeBatch));
        assertEq(certificate.ownerOf(3), address(coffeeBatch));
    }

    //TODO: only owner of CB can burn
    function test_burn() public {
        certificate.addMinter(user1);
        hevm.prank(user1);
        certificate.mint(user1);

        hevm.expectRevert("Certificate: caller is not the owner");
        hevm.prank(user2);
        certificate.burn(1);

        hevm.expectEmit(true, true, true, true);
        hevm.prank(user1);
        emit Transfer(user1, address(0), 1);
        certificate.burn(1);

        assertEq(certificate.balanceOf(user1), 0);
        assertEq(certificate.ownerOf(1), address(0));
    }

    // TODO: Disable transfers
    function test_transfer() public {
        certificate.addMinter(user1);
        hevm.prank(user1);
        certificate.mint(user1);

        //Wrong owner
        hevm.expectRevert("NOT_AUTHORIZED");
        hevm.startPrank(user2);
        certificate.transferFrom(user1, user2, 1);

        //Wrong owner
        hevm.expectRevert("WRONG_FROM");
        certificate.transferFrom(user2, user2, 1);

        hevm.expectEmit(true, true, true, true);
        hevm.prank(user1);
        emit Transfer(user1, user2, 1);
        certificate.transferFrom(user1, user2, 1);
    }

    //TODO: disable approvals
    function test_approval() public {
        certificate.addMinter(user1);
        hevm.prank(user1);
        certificate.mint(user1);

        //Wrong owner
        hevm.expectRevert("NOT_AUTHORIZED");
        hevm.prank(user2);
        certificate.approve(user2, 1);

        hevm.expectEmit(true, true, true, true);
        hevm.prank(user1);
        emit Approval(user1, user2, 1);
        certificate.approve(user2, 1);

        hevm.expectEmit(true, true, true, true);
        hevm.prank(user2);
        emit Transfer(user1, user2, 1);
        certificate.transferFrom(user1, user2, 1);
    }

    function test_rootOwner() public {
        assert(false);
    }
}
