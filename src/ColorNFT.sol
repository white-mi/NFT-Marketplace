// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ColorNFT is ERC721, Ownable {

    uint256 public totalSupply;
    mapping(uint256 => string) public colorData;

    constructor(address owner) ERC721("ColorNFT", "COLOR") Ownable(owner) {}

    function mint(address to, uint256 tokenId, string memory data) public onlyOwner {
        totalSupply++;
        colorData[tokenId] = data;
        _mint(to, tokenId);
    }

    function getColorData(uint256 tokenId) public view returns (string memory) {
        return colorData[tokenId];
    }
}