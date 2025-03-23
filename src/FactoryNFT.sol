// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {CardNFT} from "./CardNFT.sol";
import {ColorNFT} from "./ColorNFT.sol";
import {StarNFT} from "./StarNFT.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract NFTFactory is Ownable {

    using Strings for uint256;

    CardNFT public cardNFT;
    ColorNFT public colorNFT;
    StarNFT public starNFT;

    event NFTCreated(address indexed owner, string nftType, uint256 tokenId, string data);

    constructor(address _cardNFT, address _colorNFT, address _starNFT) Ownable(msg.sender) {
        cardNFT = CardNFT(_cardNFT);
        colorNFT = ColorNFT(_colorNFT);
        starNFT = StarNFT(_starNFT);
    }

    function generateRandomColor() internal view returns (string memory) {
        //uint256 r = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 256;
        //uint256 g = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, r))) % 256;
        //uint256 b = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, r, g))) % 256;
        //return string(abi.encodePacked("(", r.toString(), ",", g.toString(), ",", b.toString(), ")"));
    }

    function generateRandomCard() internal pure returns (string memory) {
        string[4] memory suits = ["S", "H", "D", "C"];
        string[13] memory values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"];
        //uint256 suitIndex = uint256(keccak256(abi.encodePacked(block.timestamp))) % 4;
        //uint256 valueIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 13;
        //return string(abi.encodePacked(suits[suitIndex], values[valueIndex]));
    }

    function generateRandomStar() internal pure returns (string memory) {
        string[5] memory stars = ["VEGA", "SIRIUS", "ALPHA", "BETA", "GAMMA"];
        //uint256 starIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 5;
        //return stars[starIndex];
    }

    function createNFT(string memory nftType) public {
        uint256 tokenId;
        string memory data;

        if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("card"))) {
            tokenId = cardNFT.totalSupply() + 1;
            data = generateRandomCard();
            cardNFT.mint(msg.sender, tokenId, data);
        } else if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("color"))) {
            tokenId = colorNFT.totalSupply() + 1;
            data = generateRandomColor();
            colorNFT.mint(msg.sender, tokenId, data);
        } else if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("star"))) {
            tokenId = starNFT.totalSupply() + 1;
            data = generateRandomStar();
            starNFT.mint(msg.sender, tokenId, data); 
        } else {
            revert("Invalid NFT type");
        }

        emit NFTCreated(msg.sender, nftType, tokenId, data);
    }
}