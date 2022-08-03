// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "../src/PostDAO.sol";

/*
    Deploys and sends a post with the test metadata if testPost = true
*/
contract Deploy is Script {

    uint256 constant PROFILE_ID = 17046;
    PostDAO private postDAO;
    bool testPost = true;
    ILensHub lensHub = ILensHub(0x60Ae865ee4C725cd04353b5AAb364553f56ceF82);

    function run() external {
        vm.startBroadcast();

        postDAO = new PostDAO('PostDAO', 'DOPE', '', 0x60Ae865ee4C725cd04353b5AAb364553f56ceF82, PROFILE_ID);
        lensHub.setDispatcher(PROFILE_ID, address(postDAO));

        if(testPost) {
            postDAO.mint(msg.sender, 1);
            postDAO.burn(
                0, 
                'https://bafybeihwnmasj6edfkx3tqhz2drfr22ydcuybubvph73lztguimhck74wa.ipfs.infura-ipfs.io/', 
                0x0BE6bD7092ee83D44a6eC1D949626FeE48caB30c,
                abi.encode(false), 
                address(0), 
                abi.encode('')
            );
        }
        vm.stopBroadcast();
    }
}