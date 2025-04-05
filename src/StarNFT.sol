// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MarketNFT} from "./MarketNFT.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract StarNFT is MarketNFT {
    using Strings for uint256;

    string[30] private stars = [
            "VEGA",
            "SIRIUS",
            "ALPHA",
            "BETA",
            "GAMMA",
            "DELTA",
            "EPSILON",
            "ZETA",
            "ETA",
            "THETA",
            "IOTA",
            "KAPPA",
            "LAMBDA",
            "OMEGA",
            "POLARIS",
            "ARCTURUS",
            "RIGEL",
            "BETELGEUSE",
            "ALDEBARAN",
            "CANOPUS",
            "PROCYON",
            "CAPELLA",
            "ANTARES",
            "SPICA",
            "DENEB",
            "FOMALHAUT",
            "ALTAIR",
            "MIRACH",
            "CASTRO",
            "POLLUX"
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

    function get_price(Info memory data) internal view override returns (uint256) {

        uint256 index = 0;

        for (uint256 i = 0; i < 30; i++) {
            if (keccak256(abi.encodePacked(stars[i])) == keccak256(abi.encodePacked(data.str))) {
                index = i;
                break;
            }
        }

        return ((30 - index) + data.num / 10000) * 1000000;
    }

    function generateInfo(uint256 randomness) public view override onlyOwner returns (Info memory) {
        uint256 starIndex = randomness % 30;
        uint256 someRand = uint256(keccak256(abi.encodePacked(block.timestamp, starIndex, randomness))) % 100000;
        return Info(stars[starIndex], someRand);
    }

    function _generateTokenURI(Info memory data) internal pure override returns (string memory) {
        return string.concat(data.str, "-",  data.num.toString());
    }
}