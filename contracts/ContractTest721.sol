// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Uncomment this line to use console.log
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

contract ContractTest721 is ERC721 {
    
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}
}
