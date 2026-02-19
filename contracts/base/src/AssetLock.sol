// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AssetLock Contract
/// @author solidworkssa
/// @notice Time-locked asset vesting contract.
contract AssetLock {
    string public constant VERSION = "1.0.0";


    struct Lock {
        address owner;
        uint256 amount;
        uint256 unlockTime;
    }
    
    mapping(uint256 => Lock) public locks;
    uint256 public nextLockId;
    
    function lock(uint256 _time) external payable {
        locks[nextLockId++] = Lock({
            owner: msg.sender,
            amount: msg.value,
            unlockTime: block.timestamp + _time
        });
    }
    
    function unlock(uint256 _id) external {
        Lock memory l = locks[_id];
        require(msg.sender == l.owner, "Not owner");
        require(block.timestamp >= l.unlockTime, "Locked");
        
        delete locks[_id];
        payable(msg.sender).transfer(l.amount);
    }

}
