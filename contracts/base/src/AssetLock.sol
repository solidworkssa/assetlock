// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AssetLock {
    struct Lock {
        address owner;
        address beneficiary;
        uint256 amount;
        uint256 unlockTime;
        bool withdrawn;
    }

    mapping(uint256 => Lock) public locks;
    uint256 public lockCounter;

    event Locked(uint256 indexed lockId, address indexed owner, uint256 unlockTime);
    event Withdrawn(uint256 indexed lock Id, address indexed beneficiary);

    error NotUnlockedYet();
    error Unauthorized();
    error AlreadyWithdrawn();

    function createLock(address beneficiary, uint256 duration) external payable returns (uint256) {
        uint256 lockId = lockCounter++;
        locks[lockId] = Lock(msg.sender, beneficiary, msg.value, block.timestamp + duration, false);
        emit Locked(lockId, msg.sender, block.timestamp + duration);
        return lockId;
    }

    function withdraw(uint256 lockId) external {
        Lock storage lock = locks[lockId];
        if (msg.sender != lock.beneficiary) revert Unauthorized();
        if (block.timestamp < lock.unlockTime) revert NotUnlockedYet();
        if (lock.withdrawn) revert AlreadyWithdrawn();
        
        lock.withdrawn = true;
        payable(lock.beneficiary).transfer(lock.amount);
        emit Withdrawn(lockId, lock.beneficiary);
    }

    function getLock(uint256 lockId) external view returns (Lock memory) {
        return locks[lockId];
    }

    function timeUntilUnlock(uint256 lockId) external view returns (uint256) {
        Lock memory lock = locks[lockId];
        if (block.timestamp >= lock.unlockTime) return 0;
        return lock.unlockTime - block.timestamp;
    }
}
