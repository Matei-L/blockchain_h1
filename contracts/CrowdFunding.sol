// "SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.7.0;

import "contracts/Ownable.sol";
import "contracts/DistributeFunding.sol";

contract CrowdFunding is Ownable {
    
    enum State { TARGET_NOT_REACHED, TARGET_REACHED, CLOSED }
    State state;
    
    uint fundingGoal;
    uint totalFundsReceived;
    DistributeFunding distributeFundingContract;
    
    struct Contributor {
        string name;
        uint age;
        uint contribution;
    }
    mapping(address => Contributor) contributors;
    
    
    
    constructor(uint _fundingGoal, DistributeFunding _distributeFundingContract) {
        
        state = State.TARGET_NOT_REACHED;
        fundingGoal = _fundingGoal;
        totalFundsReceived = 0;
        distributeFundingContract = _distributeFundingContract;
    }
    
    function distributeFunding() public onlyOwner {
        if (state != State.TARGET_REACHED) {
            revert(getState());
        }
        distributeFundingContract.distributeFunding{value:fundingGoal}();
        state = State.CLOSED;
    }
    
    function contribute() public payable {
        
        if (state != State.TARGET_NOT_REACHED) {
            revert("Target is already reached!");
        }
    
        uint fundsToAdd;
        if (totalFundsReceived + msg.value >= fundingGoal) {
            
            fundsToAdd = fundingGoal - totalFundsReceived;
            uint rest = msg.value - fundsToAdd;
            contributors[msg.sender].contribution = fundsToAdd;
            
            if (rest>0) {
                msg.sender.transfer(rest);
            }
            
            state = State.TARGET_REACHED;
        } else {
            
            fundsToAdd = msg.value;
            contributors[msg.sender].contribution = fundsToAdd;
        }
        
        totalFundsReceived += fundsToAdd;
    }
    
    function removeMoneyFromContribution(uint amount) public {
        
        if (state != State.TARGET_NOT_REACHED) {
            revert("Target is already reached!");
        }
        
        
        if (contributors[msg.sender].contribution < amount) {
            
            revert("Retrieved money is bigger than contribution");
        }
        
        contributors[msg.sender].contribution -= amount;
        msg.sender.transfer(amount);
        totalFundsReceived -= amount;
    }
    
    function getState() public view returns (string memory) {
        
        if(state == State.TARGET_REACHED) {
            
            return "Target reached!";
        } else if (state == State.CLOSED) {
            
            return "Target reached! Funding Closed!";
        }
        
        return "Target not reached!";
    }
    
    function getFundingGoal() public view returns (uint) {
        
        return fundingGoal;
    }
    
    function getFundsReceived() public view returns (uint) {
        
        return totalFundsReceived;
    }
    
    function getContributorForAddress(address contributorAddress) public view onlyOwner returns (string memory, uint, uint) {
        
        return (contributors[contributorAddress].name, contributors[contributorAddress].age, contributors[contributorAddress].contribution);
    }
    
    function viewProfile() public view returns (string memory, uint, uint) {
        
        return (contributors[msg.sender].name, contributors[msg.sender].age, contributors[msg.sender].contribution);
    }
    
    function editProfile(string memory name, uint age) public {
        
        contributors[msg.sender].name = name;
        contributors[msg.sender].age = age;
    }
    
}