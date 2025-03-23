// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

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

    constructor(address _cardNFT, address _colorNFT, address _starNFT, address owner) Ownable(owner) {
        cardNFT = CardNFT(_cardNFT);
        colorNFT = ColorNFT(_colorNFT);
        starNFT = StarNFT(_starNFT);
    }

    function generateRandomColor() internal view returns (ColorNFT.Color memory) {
        uint256 r = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % 256;
        uint256 g = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, r))) % 256;
        uint256 b = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, r, g))) % 256;
        return ColorNFT.Color(r, g, b);
    }

    function generateRandomCard() internal view returns (CardNFT.Card memory) {
        string[4] memory suits = ["S", "H", "D", "C"];
        string[13] memory values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"];
        uint256 suitIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 4;
        uint256 valueIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, suitIndex))) % 13;
        uint256 someRand = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, suitIndex, valueIndex))) % 100000;
        return CardNFT.Card(string.concat(suits[suitIndex], values[valueIndex]), someRand);
    }

    function generateRandomStar() internal view returns (StarNFT.Star memory) {

        string[30] memory stars = ["VEGA", "SIRIUS", "ALPHA", "BETA", "GAMMA",
         "DELTA", "EPSILON", "ZETA", "ETA", "THETA", "IOTA", "KAPPA", "LAMBDA", 
         "OMEGA", "POLARIS", "ARCTURUS", "RIGEL", "BETELGEUSE", "ALDEBARAN", 
         "CANOPUS", "PROCYON", "CAPELLA", "ANTARES", "SPICA", "DENEB", "FOMALHAUT", 
         "ALTAIR", "MIRACH", "CASTRO", "POLLUX"];

        uint256 starIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 30;
        uint256 someRand = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, starIndex))) % 100000;
        return StarNFT.Star(stars[starIndex], someRand);
    }

    function createNFT(string memory nftType, address to) public returns (uint256) {

        if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("card"))) {
            CardNFT.Card memory data = generateRandomCard();
            cardNFT.mint(to, data);
            return cardNFT._tokenId();
        } else if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("color"))) {
            ColorNFT.Color memory data = generateRandomColor();
            colorNFT.mint(to, data);
            return colorNFT._tokenId();
        } else if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("star"))) {
            StarNFT.Star memory data = generateRandomStar();
            starNFT.mint(to, data); 
            return starNFT._tokenId();
        } else {
            revert("Invalid NFT type");
        }
    }
}