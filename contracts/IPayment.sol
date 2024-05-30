// SPDX-License-Identifier: GPL-3.0

// IOrderProcess.sol
pragma solidity >=0.7.0 <0.9.0;

interface IPayment {
    function processPayment(uint orderId, uint amount, address customer) external;
    function refundPayment(uint orderId, uint amount, address customer) external;
}