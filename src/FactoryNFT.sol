// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {CardNFT} from "./CardNFT.sol";
import {ColorNFT} from "./ColorNFT.sol";
import {StarNFT} from "./StarNFT.sol";
import {RandomNumberConsumer} from "./random.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {AccessControl} from "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

contract NFTFactory is Ownable, AccessControl {
    using Strings for uint256;

    address public cardNFT;
    address public colorNFT;
    address public starNFT;
    RandomNumberConsumer public rng;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public currentImplementation;

    constructor(address _cardNFT, address _colorNFT, address _starNFT, address owner, address _rng) Ownable(owner) {
        cardNFT = _cardNFT;
        colorNFT = _colorNFT;
        starNFT = _starNFT;
        rng = RandomNumberConsumer(_rng);
        _grantRole(ADMIN_ROLE, owner);
    }

    function generateRandomColor() internal returns (ColorNFT.Color memory) {
        bytes32 requestId = rng.getRandomNumber();
        uint256 r1 = rng.randomResult();
        requestId = rng.getRandomNumber();
        uint256 r2 = rng.randomResult();
        requestId = rng.getRandomNumber();
        uint256 r3 = rng.randomResult();
        uint256 r = uint256(r1) % 256;
        uint256 g = uint256(r2) % 256;
        uint256 b = uint256(r3) % 256;
        return ColorNFT.Color(r, g, b);
    }

    function generateRandomCard() internal view returns (CardNFT.Card memory) {
        string[4] memory suits = ["S", "H", "D", "C"];
        string[13] memory values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"];
        uint256 suitIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 4;
        uint256 valueIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, suitIndex))) % 13;
        uint256 someRand =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, suitIndex, valueIndex))) % 100000;
        return CardNFT.Card(string.concat(suits[suitIndex], values[valueIndex]), someRand);
    }

    function generateRandomStar() internal view returns (StarNFT.Star memory) {
        string[30] memory stars = [
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

        uint256 starIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 30;
        uint256 someRand = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, starIndex))) % 100000;
        return StarNFT.Star(stars[starIndex], someRand);
    }

    function createNFT(string memory nftType, address to) external onlyOwner returns (uint256) {
        if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("card"))) {
            CardNFT.Card memory data = generateRandomCard();
            CardNFT(cardNFT).mint(to, data); // Явное приведение типа
            return CardNFT(cardNFT)._tokenId() - 1;
        } else if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("color"))) {
            ColorNFT.Color memory data = generateRandomColor();
            ColorNFT(colorNFT).mint(to, data); // Явное приведение типа
            return ColorNFT(colorNFT)._tokenId() - 1;
        } else if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("star"))) {
            StarNFT.Star memory data = generateRandomStar();
            StarNFT(starNFT).mint(to, data); // Явное приведение типа
            return StarNFT(starNFT)._tokenId() - 1;
        } else {
            revert("Invalid NFT type");
        }
    }

    function getBasePrice(string memory nftType, uint256 tokenId) external view onlyOwner returns (uint256) {
        if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("card"))) {
            return CardNFT(cardNFT)._price(tokenId);
        } else if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("color"))) {
            return ColorNFT(colorNFT)._price(tokenId);
        } else if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("star"))) {
            return StarNFT(starNFT)._price(tokenId);
        }
        revert("Invalid NFT type");
    }

    function addAdmin(address account) external onlyRole(ADMIN_ROLE) {
        _grantRole(ADMIN_ROLE, account);
    }

    function upgradeTo(address newImplementation) external onlyRole(ADMIN_ROLE) {
        currentImplementation = newImplementation;
    }

    fallback() external payable {
        (bool success,) = currentImplementation.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    receive() external payable {}
}
