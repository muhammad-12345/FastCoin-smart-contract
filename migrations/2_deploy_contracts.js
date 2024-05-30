const MenuManagement = artifacts.require("menuManagement");
const LoyaltyAndReward = artifacts.require("loyaltyAndReward");
const DiscountsPromotions = artifacts.require("DiscountsPromotions");
const OrderProcess = artifacts.require("orderProcess");
const Payment = artifacts.require("Payment");

module.exports = async function (deployer) {
    // Deploy the MenuManagement contract first because others depend on it.
    await deployer.deploy(MenuManagement, { gas: 5000000 });
    const menuManagementInstance = await MenuManagement.deployed();

    // Deploy the LoyaltyAndReward contract.
    await deployer.deploy(LoyaltyAndReward);
    const loyaltyAndRewardInstance = await LoyaltyAndReward.deployed();

    // Deploy the DiscountsPromotions contract.
    await deployer.deploy(DiscountsPromotions);
    const discountsPromotionsInstance = await DiscountsPromotions.deployed();

    // Deploy the OrderProcess contract with the necessary addresses.
   // Deploy the OrderProcess contract with a placeholder for the Payment contract's address
   await deployer.deploy(OrderProcess, 
    menuManagementInstance.address, 
    loyaltyAndRewardInstance.address, 
    discountsPromotionsInstance.address,
    accounts[0] // Placeholder address, for example, the deployer's address
   );
   const orderProcessInstance = await OrderProcess.deployed();

// Deploy the Payment contract with the real OrderProcess contract's address
   await deployer.deploy(Payment, orderProcessInstance.address);
   const paymentInstance = await Payment.deployed();

// Update the OrderProcess contract with the real Payment contract's address
   await orderProcessInstance.setPaymentAddress(paymentInstance.address);


};
