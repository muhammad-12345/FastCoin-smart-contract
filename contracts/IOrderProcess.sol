// SPDX-License-Identifier: GPL-3.0

// IOrderProcess.sol
pragma solidity >=0.7.0 <0.9.0;

enum OrderStatus { Placed, Preparing, Ready, Completed, Refunded }

interface IOrderProcess {
    function updateOrderStatus(uint orderId, OrderStatus _status) external;
}
