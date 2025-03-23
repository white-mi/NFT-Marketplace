// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract StarNFT is ERC721, Ownable {

    mapping(uint256 => string) public starData;
    uint256 private tokenId;

    constructor(address owner) ERC721("StarNFT", "STAR") Ownable(owner) {}

    function mint(address to, string memory data) public onlyOwner {
        starData[tokenId] = data;
        _mint(to, tokenId);
        tokenId++;
    }

    function getStarData(uint256 tokenId) public view returns (string memory) {
        return starData[tokenId];
    }
}