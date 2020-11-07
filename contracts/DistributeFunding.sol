// "SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.7.0;

import "contracts/Ownable.sol";

contract DistributeFunding is Ownable {
    
    address crowdFundingContractAddress;
    uint totalShares;
    uint leftShares;
    address payable[] shareHolders;
    mapping(address => uint) shares;
    
    constructor(uint _totalShares){
        totalShares = _totalShares;
        leftShares = _totalShares;
        // by default, the contract's owner is also the crowdFundingOwner
        crowdFundingContractAddress = owner;
    }
    
    modifier onlyCrowdFundingContract() {
        require(msg.sender == crowdFundingContractAddress, "Caller is not crowdFundingContractAddress");
        _;
    }
    
    function addShare(address payable shareHolderAdress, uint shareValue) public onlyOwner {
        if(shareValue <= leftShares){
            shares[shareHolderAdress] += shareValue;
            leftShares -= shareValue;
            shareHolders.push(shareHolderAdress);
        }
        else {
            revert('Not enough shares left.');
        }
    }
    
    function removeShare(address shareHolderAdress, uint shareValue) public onlyOwner {
        if(shareValue <= shares[shareHolderAdress]){
            shares[shareHolderAdress] -= shareValue;
            leftShares += shareValue;
        }
        else{
            revert('Shareholder doesn\'t have this many shares.');
        }
    }
    
    function checkLeftShares() public view returns (uint) {
        return leftShares;
    }
    
    function checkTotalShares() public view returns (uint) {
        return totalShares;
    }
    
    function checkSharesFor(address shareHolderAdress) public view onlyOwner returns (uint) {
        return shares[shareHolderAdress];
    }
    
    function checkMyShares() public view returns (uint) {
        return shares[msg.sender];
    }
    
    function checkMyPercentage() public view returns (uint) {
        require(totalShares > leftShares, "No shares distributed!");
        return shares[msg.sender] * 100 / (totalShares - leftShares);
    }
    
    function getCrowdFundingContractAddress() public view onlyOwner returns (address){
        return crowdFundingContractAddress;
    }
    
    function setCrowdFundingContractAddress(address payable _newCrowdFundingContractAddress) public onlyOwner {
        crowdFundingContractAddress = _newCrowdFundingContractAddress;
    }
    
    function distributeFunding() public payable onlyCrowdFundingContract {
        require(totalShares > leftShares, "No shares distributed!");
        uint founds = msg.value;
        uint accumulatedShares = totalShares - leftShares;
        for (uint i = 0; i<shareHolders.length; i++){
            shareHolders[i].transfer(founds * shares[shareHolders[i]] / accumulatedShares);
        }
        
    }
}