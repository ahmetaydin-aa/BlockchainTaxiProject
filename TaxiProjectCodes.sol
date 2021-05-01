// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title SharedTaxi
 * @dev SharedTaxi application.
 */
contract SharedTaxi {
    
    struct Proposal {
        uint carID;
        uint price;
        uint offerValidTime;
        uint approvalState;
    }
    
    struct Participant {
        address pAddress;
        uint balance;
        
        bool approvedPurchaseCar;
        bool approvedSellProposal;
        bool approvedDriver;
    }
    
    struct Driver {
        address dAddress;
        uint salary;
        uint approvalState;
    }
    
    address public manager;
    
    address[] participantAddresses;
    mapping(address => Participant) participants;
    
    Driver public driver;
    address carDealer;
    uint contractBalance;
    uint constant expenses = 10 ether;
    uint constant participationFee = 100 ether;
    uint ownedCar;
    Proposal public purposedCar;
    Proposal public purposedRepurchase;
    
    uint lastCarExpensesDate;
    uint lastPayDividendDate;
    
    
    /**
     * @dev Set contract deployer as manager
     */
    constructor() {
        manager = msg.sender;
    }
    
    
    function join() public payable {
        require (
            participantAddresses.length < 10, 
            "Sorry, we have reach the limit of participants."
        );
        require (
            msg.value == participationFee, 
            "To join this business, you have to send 100 ethers."
        );
        participantAddresses.push(msg.sender);
    }
    
    
    function setCarDealer() public {
        require(msg.sender == manager);
    }
    
    
    function carProposeToBusiness() {
        require(msg.sender == carDealer);
        
    }
    
    
    function approvePurchaseCar() {
        
    }
    
    
    function purchaseCar() {
        require(msg.sender == manager);
        
    }
    
    
    function repurchaseCarPropose() {
        require(msg.sender == carDealer);
        
    }
    
    
    function approveSellProposal() {
        
    }
    
    
    function repurchaseCar() {
        require(msg.sender == carDealer);
        
    }
    
    
    function proposeDriver() {
        require(msg.sender == manager);
        
    }
    
    
    function approveDriver() {
        
    }
    
    
    function setDriver() {
        require(msg.sender == manager);
        
    }
    
    
    function fireDriver() {
        require(msg.sender == manager);
        
    }
    
    
    function getCharge() {
        
    }
    
    
    function releaseSalary() {
        require(msg.sender == manager);
        
    }
    
    
    function getSalary() {
        require(msg.sender == driver.dAddress);
        
    }
    
    
    function carExpenses() {
        require(msg.sender == manager);
        
    }
    
    
    function payDividend() {
        require(msg.sender == manager);
        
    }
    
    
    function getDivided() {
        
    }
    
    
    fallback () {
        revert();
    }
    
}