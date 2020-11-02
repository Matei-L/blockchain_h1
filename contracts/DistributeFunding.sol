// "SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.7.4;

import "Ownable.sol";

contract DistributeFunding is Ownable {
    
    address crowdFundingOwner;
    uint totalShares;
    uint leftShares;
    address payable[] shareHolders;
    mapping(address => uint) shares;
    
    constructor(uint _totalShares){
        totalShares = _totalShares;
        leftShares = _totalShares;
        // by default, the contract's owner is also the crowdFundingOwner
        crowdFundingOwner = owner;
    }
    
    modifier onlyCrowdFundingOwner() {
        require(msg.sender == crowdFundingOwner, "Caller is not crowdFundingOwner");
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
        return shares[msg.sender] * 100 / (totalShares - leftShares);
    }
    
    function setCrowdFundingOwner(address _crowdFundingOwner) public onlyOwner {
        crowdFundingOwner = _crowdFundingOwner;
    }
    
    function getCrowdFundingOwner() public view returns (address){
        return crowdFundingOwner;
    }
    
    function distributeFunding() public payable onlyCrowdFundingOwner {
        uint founds = msg.value;
        uint accumulatedShares = totalShares - leftShares;
        for (uint i = 0; i<shareHolders.length; i++){
            shareHolders[i].transfer(founds * shares[shareHolders[i]] / accumulatedShares);
        }
        
    }
    
    function resetContract(uint _totalShares) public onlyOwner {
        totalShares = _totalShares;
        leftShares = _totalShares;
        for (uint i = 0; i<shareHolders.length; i++){
            shares[shareHolders[i]] = 0;
        }
        delete shareHolders;
        crowdFundingOwner = owner;
    }
}