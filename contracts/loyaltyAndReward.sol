// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract loyaltyAndReward {
    // Mapping of user addresses to their points balance
    mapping(address => uint256) public pointsBalance;
    mapping(address => CustomerTier) public customerTiers;


    // Access control - only the owner (the cafe) can issue points
    address public owner;
    enum CustomerTier { Bronze, Silver, Gold }

    event PointsIssued(address indexed customer, uint256 points);
    event PointsRedeemed(address indexed customer, uint256 points);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Issue loyalty points to a customer
    function issuePoints(address customer, uint256 points) external onlyOwner {
        pointsBalance[customer] += points;
        emit PointsIssued(customer, points);

        // Update customer tier based on new points balance or other criteria
        if (pointsBalance[customer] > 1000) {
            customerTiers[customer] = CustomerTier.Gold;
        } else if (pointsBalance[customer] > 500) {
            customerTiers[customer] = CustomerTier.Silver;
        } else {
            customerTiers[customer] = CustomerTier.Bronze;
        }
    }

    // Redeem loyalty points for a discount
    function redeemPoints(address customer, uint256 points) external {
        require(pointsBalance[customer] >= points, "Insufficient points");
        pointsBalance[customer] -= points;
        emit PointsRedeemed(customer, points);
    }

    // Update owner (cafe) address
    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}
