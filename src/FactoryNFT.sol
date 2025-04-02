// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {CardNFT} from "./CardNFT.sol";
import {ColorNFT} from "./ColorNFT.sol";
import {StarNFT} from "./StarNFT.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {AccessControl} from "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

contract NFTFactory is Ownable, AccessControl {
    using Strings for uint256;

    // Константы
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 private constant MAX_STARS = 3000;
    uint256 private constant STARS_PER_NAME = 100;

    // Адреса NFT контрактов
    address public immutable cardNFT;
    address public immutable colorNFT;
    address public immutable starNFT;

    // Данные для генерации звезд
    string[30] private _starNames = [
        "VEGA", "SIRIUS", "ALPHA", "BETA", "GAMMA", "DELTA",
        "EPSILON", "ZETA", "ETA", "THETA", "IOTA", "KAPPA",
        "LAMBDA", "OMEGA", "POLARIS", "ARCTURUS", "RIGEL",
        "BETELGEUSE", "ALDEBARAN", "CANOPUS", "PROCYON",
        "CAPELLA", "ANTARES", "SPICA", "DENEB", "FOMALHAUT",
        "ALTAIR", "MIRACH", "CASTRO", "POLLUX"
    ];
    
    // Оптимизированное хранение комбинаций звезд
    mapping(uint256 => uint256) private _starCombosBitmask;
    uint256 private _remainingStars = MAX_STARS;

    // Уникальные цвета
    mapping(bytes32 => bool) public usedColors;
    address public currentImplementation;

    constructor(address _cardNFT, address _colorNFT, address _starNFT, address owner) Ownable(owner) {
        cardNFT = _cardNFT;
        colorNFT = _colorNFT;
        starNFT = _starNFT;
        _grantRole(ADMIN_ROLE, owner);
    }

    // ========== Основные функции ==========

    function createNFT(string memory nftType, address to, uint256 randomness) external onlyOwner returns (uint256) {
        if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("card"))) {
            CardNFT.Card memory data = _generateRandomCard(randomness);
            CardNFT(cardNFT).mint(to, data); // Явное приведение типа
            return CardNFT(cardNFT)._tokenId() - 1;
        } else if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("color"))) {
            ColorNFT.Color memory data = _generateRandomColor(randomness);
            ColorNFT(colorNFT).mint(to, data); // Явное приведение типа
            return ColorNFT(colorNFT)._tokenId() - 1;
        } else if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("star"))) {
            StarNFT.Star memory data = _generateRandomStar(randomness);
            StarNFT(starNFT).mint(to, data); // Явное приведение типа
            return StarNFT(starNFT)._tokenId() - 1;
        } else {
            revert("Invalid NFT type");
        }
    }

    // ========== Генерация NFT ==========

    function _generateRandomColor(uint256 randomness) internal returns (ColorNFT.Color memory) {
        for(uint i = 0; i < 5; i++) {
            uint256 r = uint256(keccak256(abi.encodePacked(randomness, i, "R"))) % 256;
            uint256 g = uint256(keccak256(abi.encodePacked(randomness, i, "G"))) % 256;
            uint256 b = uint256(keccak256(abi.encodePacked(randomness, i, "B"))) % 256;
            
            bytes32 colorHash = keccak256(abi.encodePacked(r, g, b));
            if(!usedColors[colorHash]) {
                usedColors[colorHash] = true;
                return ColorNFT.Color(r, g, b);
            }
        }
        revert("Color generation failed");
    }

    function _generateRandomCard(uint256 randomness) internal pure returns (CardNFT.Card memory) {
        string[4] memory suits = ["S", "H", "D", "C"];
        uint256 suitIndex = randomness % 4;

        string memory value;
        uint256 rarityRoll = randomness % 100;
        
        if (rarityRoll >= 98) {
            value = (randomness % 2 == 0) ? "A" : "K";
        } else if (rarityRoll > 75) {
            value = (randomness % 2 == 0) ? "Q" : "J";
        } else {
            string[9] memory commonValues = ["2", "3", "4", "5", "6", "7", "8", "9", "10"];
            value = commonValues[randomness % 9];
        }
        
        return CardNFT.Card(string.concat(suits[suitIndex], value));
    }

    function _generateRandomStar(uint256 randomness) internal returns (StarNFT.Star memory) {
        require(_remainingStars > 0, "All stars minted");
        
        uint256 comboIndex = randomness % _remainingStars;
        uint256 combo = _getStarCombo(comboIndex);

        // Удаляем использованную комбинацию
        _setStarCombo(comboIndex, _getStarCombo(_remainingStars - 1));
        _remainingStars--;

        uint256 starIndex = combo / STARS_PER_NAME;
        uint256 num = combo % STARS_PER_NAME;
        
        return StarNFT.Star(_starNames[starIndex], num + 1); // +1 чтобы номера были от 1 до 100
    }

    // ========== Оптимизированное хранение звезд ==========

    function _getStarCombo(uint256 index) internal view returns (uint256) {
        uint256 bucket = index / 256;
        uint256 offset = (index % 256) * 10; // 10 бит на комбинацию (0-2999)
        return (_starCombosBitmask[bucket] >> offset) & 0x3FF; // Маска 10 бит
    }

    function _setStarCombo(uint256 index, uint256 value) internal {
        uint256 bucket = index / 256;
        uint256 offset = (index % 256) * 10;
        uint256 mask = ~(0x3FF << offset);
        _starCombosBitmask[bucket] = (_starCombosBitmask[bucket] & mask) | (value << offset);
    }

    // ========== Вспомогательные функции ==========

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

    // ========== Администрирование ==========

    function addAdmin(address account) external onlyRole(ADMIN_ROLE) {
        _grantRole(ADMIN_ROLE, account);
    }

    function upgradeTo(address newImplementation) external onlyRole(ADMIN_ROLE) {
        currentImplementation = newImplementation;
    }

    // ========== Системные функции ==========

    fallback() external payable {
        address impl = currentImplementation;
        require(impl != address(0), "Implementation not set");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}