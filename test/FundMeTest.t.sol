// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FdundMeTest is Test{

    uint256 constant GAS_PRICE = 1;


    FundMe fundMe;
    DeployFundMe deployFundMe;
    function setUp() external{
        deployFundMe = new DeployFundMe();
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        fundMe = deployFundMe.run();
    }

    address user = makeAddr("USER");

    function testMiniumDollarIsFive() view public{
        console.log(fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(),5e18);
    }

    function testOwnerIsMsgSender() view public{
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testPriceFeedVersionIsAccurate() view public {
        uint256 version =fundMe.getVersion();
        assertEq(version,4);
    }

    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert(); // next line should revert
        fundMe.fund();
    }


    function testFundUpdatesFundedDataStructure() public funded{
    
    
        assertEq(fundMe.getAddressToAmountFunded(user),10e18);
        
    }

    function testAddsFunderToArrayofFunders() public funded{
        address funder = fundMe.getFunder(0);
        assertEq(funder,user);
    }

    modifier funded(){  
        vm.deal(user,1000 ether);
        vm.prank(user);
        fundMe.fund{value:10e18}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.prank(user);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithSingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart-gasEnd)*tx.gasprice;
        // console.log(gasUsed);
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance+startingOwnerBalance,endingOwnerBalance);

    }

    function testWithdrawFromMultipleFunders() public funded{
        uint160 numberOfFunders = 10;
        uint160 startinfFunderIndex = 1;
        for(uint160 i = startinfFunderIndex;i<numberOfFunders;i++){
            hoax(address(i),10e18);
            fundMe.fund{value:10e18}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance==0);
        assert(startingFundMeBalance+startingOwnerBalance==fundMe.getOwner().balance);
    }
    


}