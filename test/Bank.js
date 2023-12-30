const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Bank", function () {

    async function deployBankFixture() {
        const [owner, otherAccount] = await ethers.getSigners();

        const Bank = await ethers.getContractFactory("Bank");
        const bank = await Bank.deploy();

        return { bank, owner, otherAccount };
    }


    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            const { bank, owner } = await loadFixture(deployBankFixture);

            expect(await bank.getOwner()).to.equal(owner.address);
        });

        it("Should have a registered balance of 0", async function(){
            const { bank } = await loadFixture(deployBankFixture);
            expect(await bank.getBankBalance()).to.equal(0);
        })

        it("Should have a balance of 0", async function (){
            const { bank } = await loadFixture(deployBankFixture);
            const provider = ethers.provider;
            const balance = await provider.getBalance(bank.target);
            expect(balance).to.equal(0);
        })

        it("Should have an approved owner set to 0", async function(){
            const { bank } = await loadFixture(deployBankFixture);
            const zeroAddress = "0x0000000000000000000000000000000000000000";
            expect(await bank.getApprovedOwner()).to.equal(zeroAddress);
        })
    });

    describe("Deposit", function(){

        it("Should register amount deposited", async function(){
            const { bank, owner, otherAccount } = await loadFixture(deployBankFixture);
            const depositAmount = 100;
            const receipt = await bank.connect(otherAccount).deposit(depositAmount, {value: depositAmount});
            await receipt.wait();
            expect(await bank.getBankBalance()).to.equal(depositAmount);
        })

        it("Should fail deposit if amount is less than sent ETH", async function(){
            const { bank, owner, otherAccount } = await loadFixture(deployBankFixture);
            const depositAmount = 100;
            const realDespositAmount = 50;
            await expect(bank.connect(otherAccount).deposit(depositAmount, {value: realDespositAmount}))
            .to.be.revertedWithCustomError(bank, "Bank__NotEnoughEth").withArgs(realDespositAmount);
        })

        it("Should update balances after a deposit", async function(){
            const { bank, owner, otherAccount } = await loadFixture(deployBankFixture);
            const depositAmount = 100;
            const receipt = await bank.connect(otherAccount).deposit(depositAmount, {value: depositAmount});
            await receipt.wait();
            expect(await bank.getBankBalance()).to.equal(depositAmount);
            expect(await bank.getBalance(otherAccount.address)).to.equal(depositAmount);
        })

        it("Should emit a deposit log", async function(){
            const { bank, owner, otherAccount } = await loadFixture(deployBankFixture);
            const depositAmount = 100;
            await expect(bank.connect(otherAccount).deposit(depositAmount, {value: depositAmount}))
            .to.emit(bank, "Deposit")
            .withArgs(otherAccount.address, depositAmount);
        })
    
    })
});
