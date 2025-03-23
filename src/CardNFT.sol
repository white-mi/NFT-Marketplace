// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract CardNFT is ERC721, Ownable {

    uint256 public totalSupply;
    mapping(uint256 => string) public cardData;

    constructor(address owner) ERC721("CardNFT", "CARD") Ownable(owner) {}

    function mint(address to, uint256 tokenId, string memory data) public onlyOwner {
        totalSupply++;
        cardData[tokenId] = data;
        _mint(to, tokenId);
    }

    function getCardData(uint256 tokenId) public view returns (string memory) {
        return cardData[tokenId];
    }
}