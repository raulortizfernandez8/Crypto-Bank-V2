// Liciencia 
// SPDX-License-Identifier: GPL-3.0-or-later

// Version solidity

pragma solidity 0.8.24;

// Rules:
    //1.Multiuser.
    //2.Only can deposit Ether.
    //3.User can only withdraw his own Ether.
    //4.Max balance = 5 Ether by user.
    //5.MaxBalance modifiable by owner.
    //6.Fees added, so it works like a real bank. Fees can be changed by admin.
    //7.The contract can be stopped for security reasons.
    //8.Admin can withdraw all the money got with fees.


contract CryptoBank {

    // Variables
    uint256 public maxBalance;
    address public admin;
    mapping (address => uint256) public userBalance;
    bool public bankActive = true;
    uint256 bankBalance;
    uint256 comision;

    // Events 
    event EtherDeposit (address user, uint256 amount, uint256 comision);
    event EtherWithDraw (address user, uint256 amount, uint256 comision); 
    event ChangeComision (uint256 nuevaComision);
    event BankBalanceWithDraw (uint256 totalComisionExtracted);

    // Modifiers
    modifier OnlyAdmin() {
        require(msg.sender==admin,"You are not allowed");
        _;
    }

    modifier OnlyActive() {
        require(bankActive,"The bank is disabled"); // This is a Circuit Braker. If something unusual happens, the contract can be stopped.
        _;
    }

    // In constructor we introduce admin_ so we set the admin address, it has to be necessarily 
    //the address which deploys the contract, in that case the admin would be msg.sender.

    constructor(uint256 maxBalance_, address admin_){
        admin = admin_;
        maxBalance = maxBalance_;
    }

    // External Functions
    // 1.Deposit Ether
    function depositEther() external payable OnlyActive { 
        require(userBalance[msg.sender] + msg.value<=maxBalance,"MaxBalance Reached");

        uint256 fee = msg.value*comision/100;
        uint256 neto = msg.value - fee;

        bankBalance += fee; // Comision is added to bank balance

        userBalance[msg.sender] += neto; // We can not send the amount of Ether through a parameter as it would be avulnerability
        emit EtherDeposit(msg.sender,neto,fee); // It has to be send with msg.value (so it is sent money that exists in the address)
    }
    // 2.Withdraw Ether
    // For withdrawing money is very important to do it in a correct order for not comitting a vulnerability
    function withDrawEther(uint256 amount_) external OnlyActive {
        require(amount_ <= userBalance[msg.sender],"Not enough  Ether"); // 1.Checks
                                                                            // CEI Pattern 1.Checks 2.Effects(Update State) 3.Interactions
        uint256 fee = amount_ * comision/100;                                                                 // Reentrancy attacks
        uint256 neto = amount_ - fee;
        

            // 1. Update State
             userBalance[msg.sender] -= amount_; // 2.Effects
             bankBalance += fee;

            // 2. Transfer the Ether
            (bool success,) = msg.sender.call{value: neto}(""); //3.Interactions.
            require(success,"Transfer to user failed");
            emit EtherWithDraw(msg.sender, neto, fee);

    }
    // Function Change Comisions
    function changeComision(uint256 newComision_) external OnlyAdmin {
        require(newComision_<=10,"The new comision is very high. Must be lower than 10%");
        comision = newComision_;
        emit ChangeComision(comision);
    }

    // Function Modify MaxBalance
    function modifyMaxBalance(uint256 newMaxBalance_) external OnlyAdmin{
        maxBalance = newMaxBalance_;
    }

    // Function Modify Bank Active
    function disableBank() external OnlyAdmin{
        bankActive = false;
    }
    
     // Function Modify Bank Active
    function enableBank() external OnlyAdmin{
        bankActive = true;
    }

    // Function Withdraw from Bankbalance
    function withDrawBankBalance() external OnlyAdmin{
        require(bankBalance>0,"The Bank Balance is 0");
        uint256 totalMoney = bankBalance;
        bankBalance = 0;
        (bool success,)= msg.sender.call{value:totalMoney}("");
        require(success,"Withdraw comisions from bank failed");
        emit BankBalanceWithDraw(totalMoney);
    }

}