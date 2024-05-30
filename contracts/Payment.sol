// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./IOrderProcess.sol";

contract Payment {
    address public owner;
    address public orderAddress;
    IOrderProcess public orderProcessContract;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    uint256 public totalSupply;
    string public name = "FastCoin";
    string public symbol = "FC";
    uint8 public decimals = 18;

    event PaymentProcessed(uint orderId, uint amount, address customer);
    event RefundProcessed(uint orderId, uint amount, address customer);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address _orderAddress) {
        owner = msg.sender;
        orderAddress = _orderAddress;
        orderProcessContract = IOrderProcess(_orderAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyOrderProcess() {
        require(msg.sender == address(orderProcessContract), "Only OrderProcess contract can call this");
        _;
    }

    // In Payment.sol
    function setOrderProcessAddress(address _orderProcessAddress) external onlyOwner {
        orderProcessContract = IOrderProcess(_orderProcessAddress);
    }


    function transfer(address to, uint256 value) public returns (bool) {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        uint256 allowance = allowed[from][msg.sender];
        require(balances[from] >= value && allowance >= value, "Insufficient balance or allowance");
        balances[to] += value;
        balances[from] -= value;
        allowed[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function balanceOf(address owner) public view returns (uint256 balance) {
        return balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    // payment for an order
    function processPayment(uint orderId, uint amount, address customer) external onlyOrderProcess {
        require(balances[customer] >= amount, "Insufficient balance");
        transferFrom(customer, address(this), amount);
        orderProcessContract.updateOrderStatus(orderId, OrderStatus.Completed);
        emit PaymentProcessed(orderId, amount, customer);
    }

    // Refund payment for an order
    function refundPayment(uint orderId, uint amount, address customer) external onlyOwner {
        require(balances[address(this)] >= amount, "Insufficient balance in contract");
        transfer(customer, amount);
        orderProcessContract.updateOrderStatus(orderId, OrderStatus.Refunded);
        emit RefundProcessed(orderId, amount, customer);
    }

    // Update OrderProcess contract address in case of changes
    function updateOrderProcessAddress(address newAddress) external onlyOwner {
        orderAddress = newAddress;
        orderProcessContract = IOrderProcess(newAddress);
    }
}
