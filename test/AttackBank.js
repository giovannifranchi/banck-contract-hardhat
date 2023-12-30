const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("AttackBank", function () {

    async function deployBankFixture() {
        const [owner, otherAccount, secondAccount, thirdAccount] = await ethers.getSigners();

        const Bank = await ethers.getContractFactory("Bank");
        const bank = await Bank.deploy({value: ethers.parseEther("50.0")});
        const AttackBank = await ethers.getContractFactory("Attacker");
        const attackBank = await AttackBank.deploy(bank.target, ethers.parseEther("10.0"), ethers.parseEther("9.0") ,{value: ethers.parseEther("10.0")});

        return { bank, owner, otherAccount, secondAccount, thirdAccount, attackBank };
    }

    describe("Deployment", function(){

        it("Should have the right balances", async function(){
            const provider = ethers.provider;
            const { bank, attackBank } = await loadFixture(deployBankFixture);
            expect(await provider.getBalance(bank.target)).to.equal(ethers.parseEther("50.0"));
            expect(await provider.getBalance(attackBank.target) ).to.equal(ethers.parseEther("10.0"));
        })

        it("Should drain almost all bank's balance", async function(){
            const provider = ethers.provider;
            const { bank, attackBank, otherAccount } = await loadFixture(deployBankFixture);
            const receipt = await attackBank.connect(otherAccount).deposit();
            await receipt.wait();
            const receipt2 = await attackBank.connect(otherAccount).attack();
            await receipt2.wait();
            expect(await provider.getBalance(bank.target)).to.equal(ethers.parseEther("0.0"));
            expect(await provider.getBalance(attackBank.target) ).approximately(ethers.parseEther("60.0"), ethers.parseEther("1.0"));
        })
    })

});