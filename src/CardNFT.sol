// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MarketNFT} from "./MarketNFT.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract CardNFT is MarketNFT {
    using Strings for uint256;

    string[4] private SUITS = ["S", "H", "D", "C"];
    string[13] private VALUES = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"];

    string[52] private cards = [
            "SA",
            "SK",
            "SQ",
            "SJ",
            "S10",
            "S9",
            "S8",
            "S7",
            "S6",
            "S5",
            "S4",
            "S3",
            "S2",
            "HA",
            "HK",
            "HQ",
            "HJ",
            "H10",
            "H9",
            "H8",
            "H7",
            "H6",
            "H5",
            "H4",
            "H3",
            "H2",
            "DA",
            "DK",
            "DQ",
            "DJ",
            "D10",
            "D9",
            "D8",
            "D7",
            "D6",
            "D5",
            "D4",
            "D3",
            "D2",
            "CA",
            "CK",
            "CQ",
            "CJ",
            "C10",
            "C9",
            "C8",
            "C7",
            "C6",
            "C5",
            "C4",
            "C3",
            "C2"
        ];


    constructor(string memory name, 
        string memory symbol,
        uint256 _exponentCurve,
        uint256 _meanPrice,
        address owner
    ) MarketNFT(name, symbol,
         _exponentCurve,
         _meanPrice,
         owner) {}

    function get_price(Info memory data) internal view override returns  (uint256) {
        uint256 index = 0;
        for (uint256 i = 0; i < 52; i++) {
            if (keccak256(abi.encodePacked(cards[i])) == keccak256(abi.encodePacked(data.str))) {
                index = i;
                break;
            }
        }
        return (((51 - index) % 13 + 1) * 4 + data.num / 10000) * 1000000;
    }

    function generateInfo(uint256 randomness) public view override onlyOwner returns (Info memory) {
        bytes32 hash = keccak256(abi.encodePacked(randomness, blockhash(block.number - 1)));
        uint256 suitIndex = uint256(hash) % 4;
        uint256 valueIndex = (uint256(hash) >> 8) % 13; 
        uint256 someRand = (uint256(hash) >> 16) % 100000; 
        return Info(string.concat(SUITS[suitIndex], VALUES[valueIndex]), someRand);
    }

    function _generateTokenURI(Info memory data) internal pure override returns (string memory) {
        return string.concat(data.str, "-",  data.num.toString());
    }
}