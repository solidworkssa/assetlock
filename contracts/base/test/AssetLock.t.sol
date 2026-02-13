// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/AssetLock.sol";

contract AssetLockTest is Test {
    AssetLock public c;
    
    function setUp() public {
        c = new AssetLock();
    }

    function testDeployment() public {
        assertTrue(address(c) != address(0));
    }
}
