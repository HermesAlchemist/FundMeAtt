// GET funds from users
// Withdraw funds
// Set a minimum funding value is USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PriceConverter} from "./PriceConverter.sol";


// 774448 GAS

error NotOwner();

contract FundMe
{
    address public immutable i_owner;

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    constructor() 
    {
        i_owner = msg.sender;
    }

    function fund() public payable 
    {
        msg.value.getConversionRate();
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send the minimum value");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner
    {
        // for loop
        // [1,2,3,4]
        // 0 1 2 3
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++)
        {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        } 
        // reset the array
        funders = new address[](0);
        // actually withdraw the funds

        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

    modifier onlyOwner()
    {
        require(msg.sender == i_owner, "Sender is not owner!");
        // if(msg.sender != i_owner) { revert NotOwner(); }
        _;
    }

    receive() external payable
    {
        fund();
    }

    fallback() external payable
    {
        fund();
    }
}