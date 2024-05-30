// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./IOrderProcess.sol";
import "./ILoyaltyAndReward.sol";
import "./IPromotionAndDiscount.sol";
import "./IMenuManagement.sol";
import "./IPayment.sol";  


// enum OrderStatus { Placed, Preparing, Ready, Completed }

contract orderProcess {
    IPayment paymentContract;

    struct orderItem {
        uint itemId;
        uint quantity;
    }

    struct Order {
        uint orderId;
        address customer;
        orderItem[] items;
        uint totalAmount;
        bool isFulfilled;
        OrderStatus status;
    }

    address public owner;
    mapping (uint => Order) public orders;
    uint nextOrderId;
    menuManagement menuManagementContract;
    LoyaltyAndReward loyaltyAndRewardContract;
    DiscountsPromotions discountsPromotionsContract;

    event orderPlaced (uint orderId, address customer, uint totalAmount);
    event orderFulfilled (uint orderId, address customer);
    event OrderStatusUpdated (uint orderId, OrderStatus _status);

    modifier isItemAvailable(uint itemId){
        (, , , bool isAvailable) = menuManagementContract.getItem(itemId);
        require(isAvailable, "item is NOT available");
        _;
    }

    modifier onlyOwner (){
        require(msg.sender == owner, "only owner");
        _;
    }

    
    function setPaymentAddress(address _paymentAddress) external onlyOwner {
       paymentContract = IPayment(_paymentAddress); 
    }


    constructor(address _menuManagementaddress, address _loyaltyAndRewardAddress, address _discountsPromotionsAddress, address _paymentAddress){
        menuManagementContract = menuManagement(_menuManagementaddress);
        loyaltyAndRewardContract = LoyaltyAndReward(_loyaltyAndRewardAddress);
        discountsPromotionsContract = DiscountsPromotions(_discountsPromotionsAddress);
        paymentContract = IPayment(_paymentAddress);
        owner = msg.sender;
    }

    function placeOrder(orderItem[] memory items) public returns (uint orderId){
        uint totalAmount = 0;
        Order storage order = orders[nextOrderId];
        order.customer = msg.sender;
        order.orderId = nextOrderId;

        for (uint i = 0; i < items.length; i++){
            require (items[i].quantity > 0, "Quantity must be greater than 0");
            (, , uint price, bool isAvailable) = menuManagementContract.getItem(items[i].itemId);
            require(isAvailable, "Item not available");

            uint discountedPrice = discountsPromotionsContract.getDiscountedPrice(items[i].itemId, price);

            totalAmount += discountedPrice * items[i].quantity;
            order.items.push(orderItem(items[i].itemId, items[i].quantity));
        }

        order.totalAmount = totalAmount;
        order.status = OrderStatus.Placed;
        emit orderPlaced(nextOrderId, msg.sender, totalAmount);
        paymentContract.processPayment(orderId, totalAmount, msg.sender);
        nextOrderId++;
        return nextOrderId - 1;
    }

    function fulfillOrder (uint orderId) public {
        Order storage order = orders[orderId];
        require (msg.sender == order.customer, "Only customer can fulfill order");
        require (!order.isFulfilled, "Already fulfilled");

        order.isFulfilled = true;

        if(order.isFulfilled && order.status == OrderStatus.Completed) {
            loyaltyAndRewardContract.issuePoints(order.customer, calculatePoints(order.totalAmount));
        }

        emit orderFulfilled(orderId, msg.sender);
    }

    function calculatePoints(uint totalAmount) internal pure returns (uint256) {
        if (totalAmount >= 10 ether){
            return totalAmount * 5;
        } else if (totalAmount >= 5 ether){
            return totalAmount * 3;
        } else {
            return totalAmount;
        }
        
    }

    function getOrderDetails(uint orderId) public view returns (Order memory){
        require (orderId < nextOrderId, "Order is Not Yet placed");
        return orders[orderId];
    } 

    // Update order status
    function updateOrderStatus(uint orderId, OrderStatus _status) public onlyOwner {
        Order storage order = orders[orderId];
        // check the order exists
        require(orderId < nextOrderId, "Order does not exist"); 
        order.status = _status;
        emit OrderStatusUpdated(orderId, _status);
    }


}