// SPDX-License-Identifier: GPL-3.0

// IOrderProcess.sol
pragma solidity >=0.7.0 <0.9.0;

interface DiscountsPromotions {
    function getDiscountedPrice(uint itemId, uint price) external view returns (uint);
}
