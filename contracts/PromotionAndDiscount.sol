// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DiscountsPromotions {
    enum PromotionType { Discount, BuyOneGetOne, SpecialEvent }

    struct Discount {
        uint discountPercent;
        uint validTill; // timestamp for discount validity
        bool isActive; //validity
        PromotionType Ptype;
    }

    // Mapping of item IDs to their respective discounts
    mapping(uint => Discount) public itemDiscounts;
    
    address public owner;

    event DiscountCreated(uint itemId, uint discountPercent, uint validTill);
    event DiscountRemoved(uint itemId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Create or update a discount for an item
    // only owner can offer discount
   function setDiscount(uint itemId, uint discountPercent, uint validTill, PromotionType pType) external onlyOwner {
    itemDiscounts[itemId] = Discount({
        discountPercent: discountPercent,
        validTill: validTill,
        isActive: true,
        Ptype: pType 
    });
    emit DiscountCreated(itemId, discountPercent, validTill);
}

    // Remove a discount from an item
    // only owner can remove discount
    function removeDiscount(uint itemId) external onlyOwner {
        delete itemDiscounts[itemId];
        emit DiscountRemoved(itemId);
    }

    // Check if an item is eligible for a discount and calculate the discounted price
    function getDiscountedPrice(uint itemId, uint price) public view returns (uint) {
        Discount memory discount = itemDiscounts[itemId];
        if (discount.isActive && block.timestamp <= discount.validTill) {
            uint discountAmount = (price * discount.discountPercent) / 100;
            return price - discountAmount;
        }
        return price;
    }

    // Update owner (cafe) address
    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}
