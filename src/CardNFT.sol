// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";

contract CardNFT is ERC721, Ownable {

    mapping(uint256 => string) private _cardData;
    uint256 private _tokenId;

    constructor(address owner) ERC721("CardNFT", "CARD") Ownable(owner) {}

    function mint(address to, string memory data) public onlyOwner {
        _cardData[_tokenId] = data;
        _mint(to, _tokenId);
        _tokenId++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        return string(abi.encodePacked(
            "data:json;base64,",
            Base64.encode(bytes(_cardData[tokenId]))
        ));
    }

}