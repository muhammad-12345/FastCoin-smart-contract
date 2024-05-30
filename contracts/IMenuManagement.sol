// SPDX-License-Identifier: GPL-3.0

// IOrderProcess.sol
pragma solidity >=0.7.0 <0.9.0;

interface menuManagement {
    function getItem(uint itemId) external view returns (uint id, string memory name, uint price, bool isAvailable);
}
