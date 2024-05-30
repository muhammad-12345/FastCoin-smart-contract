// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract menuManagement{
    //structure
    struct MenuItem{
        uint id;
        string name;
        uint price;
        bool isAvailable;
    }

    //static variable to keep track 
    mapping(uint => MenuItem) public menuItems;
    uint public nextItemId;
    address public Owner;

    //only cafe staff the owner of the contract can make changes
    modifier onlyStaff(){
        require (msg.sender == Owner, "Only cafe Staff have control access");
        _;
    }

    constructor (){
        Owner=msg.sender;
    }

    //events
    event itemAdded (uint itemId, string name, uint price);
    event itemUpdated (uint itemId, string name, uint price, bool isAvailable);
    event itemRemoved (uint itemId);

    //Functions
    function addItem (string memory name, uint price) public onlyStaff{
        // name cannot be none
        require(bytes(name).length > 0, "Name cannot be empty");
        // price cannot be zero
        require(price > 0, "Price must be greater than 0");
        menuItems[nextItemId] = MenuItem(nextItemId, name, price, true);
        nextItemId++;
        emit itemAdded(nextItemId, name, price);
    }

    function updateItem (uint itemId, string memory name, uint price, bool isAvailable) public onlyStaff{
        // name cannot be none
        require(bytes(name).length > 0, "Name cannot be empty");
        // price cannot be zero
        require(price > 0, "Price must be greater than 0");
        require (itemId < nextItemId, "Item does NOT exist");
        menuItems[itemId] = MenuItem (itemId, name, price, isAvailable);
        emit itemUpdated(itemId, name, price, isAvailable);
    }

    function removeItem (uint itemId) public onlyStaff{
        require(itemId < nextItemId, "item Does NOT exist");
        delete menuItems[itemId];
        emit itemRemoved(itemId);
    }

    function getItem (uint itemId) public view returns (MenuItem memory) {
        require(itemId < nextItemId, "Item Does NOT exist");
        return menuItems[itemId];
    }

    function transferOwnership (address newOwner) public onlyStaff {
        require(newOwner != address(0), "New address is Zero address");
        Owner = newOwner;
    }

}