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
        address payable pAddress;
        uint balance;
        
        bool approvedPurchaseCar;
        bool approvedSellProposal;
        bool approvedDriver;
    }
    
    struct Driver {
        address payable dAddress;
        uint salary;
        uint approvalState;
        
        uint balance;
    }
    
    address public manager;
    
    address[] public participantAddresses;
    mapping(address => Participant) public participants;
    
    Driver public driver;
    Driver public oldDriver;
    
    address payable public carDealer;
    uint public contractBalance;
    uint constant expenses = 10 ether;
    uint constant participationFee = 100 ether;      // TODO: Change this to 100(DEBUG: 10 ether).
    uint public ownedCar;
    
    Driver public proposedDriver;
    Proposal public proposedCar;
    Proposal public proposedRepurchase;
    
    uint public lastCarExpensesDate;
    uint public lastDriverSalaryDate;
    uint public lastPayDividendDate;
    
    
    modifier onlyManager {
        require(
            msg.sender == manager,
            "You have to be manager to use this function!"
        );
        _;
    }
    
    modifier onlyCarDealer {
        require(
            msg.sender == carDealer,
            "You have to be car dealer to use this function!"
        );
        _;
    }
    
    modifier onlyDriver {
        require(
            msg.sender == driver.dAddress || msg.sender == oldDriver.dAddress,
            "You have to be driver to use this function!"
        );
        _;
    }
    
    modifier onlyParticipant {
        bool isParticipant = false;
        
        for (uint i = 0; i < participantAddresses.length; i++) {
            if (msg.sender == participantAddresses[i]) {
                isParticipant = true;
                break;
            }
        }
        
        require(
            isParticipant,
            "You have to be a participant to use this function!"
        );
        _;
    }
    
    
    /**
     * @dev Set contract deployer as manager
     */
    constructor() {
        manager = msg.sender;
        contractBalance = 0;
        lastCarExpensesDate = 0;
        lastPayDividendDate = 0;
        lastDriverSalaryDate = 0;
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
        
        bool isParticipant = false;
        
        for (uint i = 0; i < participantAddresses.length; i++) {
            if (msg.sender == participantAddresses[i]) {
                isParticipant = true;
                break;
            }
        }
        
        require (
            !isParticipant, 
            "You have already joined to the business."
        );
        
        participantAddresses.push(msg.sender);
        
        Participant memory p = Participant(payable(msg.sender), 0, false, false, false);
        participants[msg.sender] = p;
        contractBalance += msg.value;
    }
    
    
    function setCarDealer(address payable carDealerAddress) public
    onlyManager()
    {
        carDealer = carDealerAddress;
    }
    
    
    function carProposeToBusiness(uint carID, uint price, uint offerValidTime) public 
    onlyCarDealer()
    {
        proposedCar = Proposal(carID, price, offerValidTime, 0);
        
        for (uint i = 0; i < participantAddresses.length; i++) {
            participants[participantAddresses[i]].approvedPurchaseCar = false;
        }
    }
    
    
    function approvePurchaseCar() public 
    onlyParticipant()
    {
        Participant memory p = participants[msg.sender];
        
        require(
            !p.approvedPurchaseCar,
            "You have already approved this car proposal!"
        );
        
        proposedCar.approvalState += 1;
        participants[msg.sender].approvedPurchaseCar = true;
    }
    
    
    function purchaseCar() public
    onlyManager()
    {
        require(
            block.timestamp <= proposedCar.offerValidTime,
            "Proposal is not valid anymore!"
        );
        
        require(
            contractBalance >= proposedCar.price,
            "Contract has not enough balance to buy this car!"
        );
        
        require(
            proposedCar.approvalState >= (participantAddresses.length / 2),
            "Proposal has to be approved by at least half of the participants!"
        );
        
        carDealer.transfer(proposedCar.price);
        contractBalance -= proposedCar.price;
        ownedCar = proposedCar.carID;
    }
    
    
    function repurchaseCarPropose(uint carID, uint price, uint offerValidTime) public 
    onlyCarDealer()
    {
        require(
            carID == ownedCar,
            "The requested car is not owned by this contract!"
        );
        
        proposedRepurchase = Proposal(carID, price, offerValidTime, 0);
        
        for (uint i = 0; i < participantAddresses.length; i++) {
            participants[participantAddresses[i]].approvedSellProposal = false;
        }
    }
    
    
    function approveSellProposal() public 
    onlyParticipant()
    {
        Participant memory p = participants[msg.sender];
        
        require(
            !p.approvedSellProposal,
            "You have already approved this car proposal!"
        );
        
        proposedRepurchase.approvalState += 1;
        participants[msg.sender].approvedSellProposal = true;
    }
    
    
    function repurchaseCar() public payable
    onlyCarDealer()
    {
        require(
            block.timestamp <= proposedRepurchase.offerValidTime,
            "Proposal is not valid anymore!"
        );
        
        require(
            msg.value == proposedRepurchase.price,
            "Proposal price to repurchase of the car must be the same!"
        );
        
        require(
            proposedRepurchase.approvalState >= (participantAddresses.length / 2),
            "Proposal has to be approved by at least half of the participants!"
        );
        
        contractBalance += proposedRepurchase.price;
        ownedCar = 0;
    }
    
    
    function proposeDriver(address dAddress, uint salary) public 
    onlyManager()
    {
        proposedDriver = Driver(payable(dAddress), salary, 0, 0);
        
        for (uint i = 0; i < participantAddresses.length; i++) {
            participants[participantAddresses[i]].approvedDriver = false;
        }
    }
    
    
    function approveDriver() public 
    onlyParticipant()
    {
        Participant memory p = participants[msg.sender];
        
        require(
            !p.approvedDriver,
            "You have already approved this driver proposal!"
        );
        
        proposedDriver.approvalState += 1;
        participants[msg.sender].approvedDriver = true;
    }
    
    
    function setDriver() public 
    onlyManager()
    {
        require(
            proposedDriver.approvalState >= (participantAddresses.length / 2),
            "Proposal has to be approved by at least half of the participants!"
        );
        
        driver = proposedDriver;
    }
    
    
    function fireDriver() public 
    onlyManager()
    {
        require(
            contractBalance >= driver.salary,
            "Contract has not enough balance to fire this driver!"
        );
        
        oldDriver = driver;
        oldDriver.balance += oldDriver.salary;
        contractBalance -= oldDriver.salary;
        delete driver;
    }
    
    
    function getCharge() public payable {
        contractBalance += msg.value;
    }
    
    
    function releaseSalary() public 
    onlyManager()
    {
        require(
            lastDriverSalaryDate + 1 months <= block.timestamp,    // TODO: change this to 1 month(DEBUG: 1 minute).
            "You have already paid the driver this month!"
        );
        
        require(
            contractBalance >= driver.salary,
            "Contract has not enough balance to pay this driver!"
        );
        
        driver.balance += driver.salary;
        contractBalance -= driver.salary;
        lastDriverSalaryDate = block.timestamp;
    }
    
    
    function getSalary() public 
    onlyDriver()
    {
        Driver memory salaryDriver = (msg.sender == driver.dAddress) ? driver : oldDriver;
        
        require(
            salaryDriver.balance > 0,
            "You have no balance in your account!"
        );
        
        payable(msg.sender).transfer(salaryDriver.balance);
        
        if (msg.sender == driver.dAddress)
            driver.balance = 0;
        else
            oldDriver.balance = 0;
    }
    
    
    function carExpenses() public 
    onlyManager()
    {
        require(
            lastCarExpensesDate + 6 months <= block.timestamp, // TODO: change this to 6 months.
            "You have already paid the expenses in the last 6 months!"
        );
        
        require(
            contractBalance >= expenses,
            "Contract has not enough balance to pay the expenses!"
        );
        
        carDealer.transfer(expenses);
        contractBalance -= expenses;
        lastCarExpensesDate = block.timestamp;
    }
    
    
    function payDividend() public 
    onlyManager()
    {
        require(
            lastPayDividendDate + 6 months <= block.timestamp, // TODO: change this to 6 months(DEBUG: 1 minute).
            "You have already paid the profits in the last 6 months!"
        );
        
        require(
            lastCarExpensesDate + 6 months > block.timestamp &&    // TODO: change this to 6 months(DEBUG: 1 minute).
            lastDriverSalaryDate + 1 months > block.timestamp,     // TODO: change this to 1 month(DEBUG: 1 minute).
            "Make sure you have paid the necessary expenses and driver salary before paying participants!"
        );
        
        uint profitPerParticipant = contractBalance / participantAddresses.length;
        
        
        for (uint i = 0; i < participantAddresses.length; i++) {
            participants[participantAddresses[i]].balance += profitPerParticipant;
        }
        
        contractBalance = 0;
        lastPayDividendDate = block.timestamp;
    }
    
    
    function getDivided() public 
    onlyParticipant()
    {
        Participant memory p = participants[msg.sender];
        
        require(
            p.balance > 0,
            "You have no balance in your account!"
        );
        
        payable(msg.sender).transfer(p.balance);
        participants[msg.sender].balance = 0;
    }
    
    
    fallback () external {
        revert();
    }
    
}