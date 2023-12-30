// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;


contract Bank {

    /** Errors */

    error Banck__NotEnoughBalance(uint256 balance);
    error Bank__NotEnoughAllowance(uint256 allowance); 
    error Bank__NotEnoughEth(uint256 eth);
    error Bank__OnlyOwnerCanCallThisFunction();
    error Bank__OnlyApprovedOwnerCanCallThisFunction();

    event Deposit(address indexed sender, uint256 amount);
    event Withdraw(address indexed sender, uint256 amount);
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed sender, address indexed recipient, uint256 amount);
    event NewOwnerApProved(address indexed newOwner);
    event OwnershipTransfered(address indexed newOwner);
    event Skimmed(address indexed owner, uint256 amount);

    uint256 private s_bankBalance;
    address private s_owner;
    address private s_approvedOwner;
    mapping(address => uint256) private s_balances;
    mapping(address => mapping(address => uint256)) private s_allowances;



    modifier onlyOwner(){
        if(msg.sender != s_owner){
            revert Bank__OnlyOwnerCanCallThisFunction();
        }
        _;
    }

    modifier enoughEth(uint256 amount){
        if(msg.value < amount){
            revert Bank__NotEnoughEth(msg.value);
        }
        _;
    }

    modifier enoughBalance(address account, uint256 amount){
        if(s_balances[account] < amount){
            revert Banck__NotEnoughBalance(s_balances[account]);
        }
        _;
    }

    modifier enoughAllowance(address sender, address recipient, uint256 amount){
        if(s_allowances[sender][recipient] < amount){
            revert Bank__NotEnoughAllowance(s_allowances[sender][recipient]);
        }
        _;
    }

    modifier onlyAprrovedOwner(){
        if(msg.sender != s_approvedOwner){
            revert Bank__OnlyApprovedOwnerCanCallThisFunction();
        }
        _;
    }

    constructor(){
        s_owner = msg.sender;
    }

    receive() external payable {
        
    }

    fallback() external payable {
        
    }

    function deposit(uint256 amount) public payable enoughEth(amount) {
        s_bankBalance += amount;
        s_balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external enoughBalance(msg.sender, amount) {
        s_balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function widthdrawAll(address[] memory allowers) external {
        uint256 userAmount = s_balances[msg.sender];
        for(uint256 i = 0; i < allowers.length; i++){
            uint256 allowance = s_allowances[msg.sender][allowers[i]];
            s_allowances[allowers[i]][msg.sender] = 0;
            userAmount += allowance;
        }
        s_balances[msg.sender] = 0;
        payable(msg.sender).transfer(userAmount);
        emit Withdraw(msg.sender, userAmount);
    }

    function transfer(address recipient, uint256 amount) external enoughBalance(msg.sender, amount){
        s_balances[msg.sender] -= amount;
        s_balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
    }


    function approve(address recipient, uint256 amount) external enoughBalance(msg.sender, amount){
        s_allowances[msg.sender][recipient] = amount;
    }


    function transferFrom(address sender, address recipient, uint256 amount) external enoughAllowance(sender, recipient, amount){
        if(s_allowances[sender][recipient] != type(uint256).max){
            s_allowances[sender][recipient] -= amount;
        }else{
            s_balances[sender] -= amount;
            s_balances[recipient] += amount;
        }
    }

    function skim() external onlyOwner {
        if(address(this).balance > s_bankBalance){
            payable(s_owner).transfer(address(this).balance - s_bankBalance);
        }
        emit Skimmed(s_owner, address(this).balance - s_bankBalance);
    }

    function approveOwner(address newOwner) external onlyOwner{
        s_approvedOwner = newOwner;
    }

    function claimOwnership() external onlyAprrovedOwner{
        s_owner = s_approvedOwner;
        s_approvedOwner = address(0);
    }

    function getBalance(address account) external view returns(uint256){
        return s_balances[account];
    }

    function getAllowance(address sender, address recipient) external view returns(uint256){
        return s_allowances[sender][recipient];
    }

    function getOwner() external view returns(address){
        return s_owner;
    }

    function getApprovedOwner() external view returns(address){
        return s_approvedOwner;
    }

    function getBankBalance() external view returns(uint256){
        return s_bankBalance;
    }


    
}