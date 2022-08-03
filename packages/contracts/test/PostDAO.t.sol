// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "@lens/libraries/DataTypes.sol";
import "forge-std/console2.sol";
import '../src/PostDAO.sol';

contract postDAOTest is Test {
    
    uint256 public constant PROFILE_ID = 1408;
    PostDAO private postDAO;

    ILensHub lensHub = ILensHub(0xDb46d1Dc155634FbC732f92E853b10B288AD5a1d);

    address addressWithDAOProfile = 0x14306f86629E6bc885375a1f81611a4208316B2b;
    address nftOwner = 0x7020AFb73882c715415810Cfe12946bf1f999a9b;

    function setUp() public {
        postDAO = new PostDAO('PostDAO', 'DOPE', '', 0xDb46d1Dc155634FbC732f92E853b10B288AD5a1d, PROFILE_ID);
        vm.prank(addressWithDAOProfile);
        lensHub.setDispatcher(PROFILE_ID, address(postDAO));
    }


    function testMintWithEnoughFunds() public {
        uint256 supply = postDAO.currentSupply();
        assertEq(supply, 0);
        postDAO.mint{value: 25 ether}(nftOwner, 5);
        assertEq(postDAO.currentSupply(), supply + 5);
        assertEq(postDAO.ownerOf(1), nftOwner);
    }    
    
    function testMintWithoutFunds() public {
        uint256 supply = postDAO.currentSupply();
        assertEq(supply, 0);
        vm.expectRevert(abi.encodeWithSignature("NotEnoughMatic()"));
        postDAO.mint{value: 5 ether}(msg.sender, 5);
    }

    function testMintMaxSupply() public {
        vm.expectRevert(abi.encodeWithSignature("NotEnoughNFTs()"));
        postDAO.mint{value: 0 ether}(nftOwner, 10001);
    }

    function testBurnIfNftOwner() public {
        DataTypes.ProfileStruct memory profile =  lensHub.getProfile(PROFILE_ID);

        postDAO.mint{value: 25 ether}(msg.sender, 5);
        assertEq(postDAO.ownerOf(2), address(msg.sender));
        
        vm.prank(msg.sender);
        postDAO.burn(
            2, 
            'aave.com', 
            0x23b9467334bEb345aAa6fd1545538F3d54436e96, // test module, everyone can collect
            abi.encode(false), 
            address(0), 
            abi.encode('')
        );

        assertEq(lensHub.getContentURI(PROFILE_ID, profile.pubCount+1), 'aave.com');
        
        unchecked {
            assertEq(postDAO.balanceOf(msg.sender), 4);
        }
    }

    function testBurnIfNotNftOwner() public {
        postDAO.mint{value: 25 ether}(msg.sender, 5);
        assertEq(postDAO.ownerOf(2), address(msg.sender));
        vm.expectRevert(abi.encodeWithSignature("NotYourNFT()"));
        postDAO.burn(
            2, 
            'aave.com', 
            address(0), 
            abi.encode(''), 
            address(0), 
            abi.encode('')
        );
    }

    function testWithdrawAsOwner() public {
        postDAO.mint{value: 25 ether}(nftOwner, 5);
        postDAO.withdraw(25 ether, nftOwner);
        assertEq(address(postDAO).balance, 0 ether);
    }

    function testWithdrawNotOwner() public {
        postDAO.mint{value: 25 ether}(nftOwner, 5);
        vm.startPrank(nftOwner);
        vm.expectRevert("UNAUTHORIZED");
        postDAO.withdraw(25 ether, nftOwner);
    }
}
