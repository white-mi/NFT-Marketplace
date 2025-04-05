// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MarketNFT} from "./MarketNFT.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract ColorNFT is MarketNFT {
    using Strings for uint256;

    constructor(string memory name, 
        string memory symbol,
        uint256 _exponentCurve,
        uint256 _meanPrice,
        address owner
    ) MarketNFT(name, symbol,
         _exponentCurve,
         _meanPrice,
         owner) {}
    

    function hexToRGB(string memory hexColor) internal pure returns (uint256 r, uint256 g, uint256 b) {
        uint256 color = hexStringToUint(hexColor);
        r = (color >> 16) & 0xFF;
        g = (color >> 8) & 0xFF;
        b = color & 0xFF;
    }

    function hexStringToUint(string memory s) internal pure returns (uint256) {
        bytes memory bs = bytes(s);
        uint256 result = 0;
        for (uint256 i = 2; i < 8; i++) {
            bytes1 char = bs[i];
            uint8 val = charToHexValue(char);
            result = (result << 4) | val;
        }
        return result;
    }

    function charToHexValue(bytes1 c) internal pure returns (uint8) {
    if (c >= 0x30 && c <= 0x39) {
        return uint8(c) - 48; 
    }
    
    if (c >= 0x41 && c <= 0x46) {
        return uint8(c) - 55; 
    }
    
    revert("Invalid hex character");
}

    function _rgbToHex(
        uint256 r, 
        uint256 g, 
        uint256 b
    ) internal pure returns (string memory) {
        bytes memory hexBytes = abi.encodePacked(
            "0x",
            _byteToHex(r),
            _byteToHex(g),
            _byteToHex(b)
        );
        
        return string(hexBytes);
    }

    function _byteToHex(uint256 value) internal pure returns (bytes memory) {
        bytes memory hexAlphabet = "0123456789ABCDEF";
        bytes memory hexPair = new bytes(2);
        hexPair[0] = hexAlphabet[value >> 4];
        hexPair[1] = hexAlphabet[value & 0x0F];
        
        return hexPair;
    }

    function get_price(Info memory data) internal pure override returns (uint256) {
        uint256 max_price = 256 * 256 + 256 * 256 + 256 * 256;
        uint256 red;
        uint256 green;
        uint256 blue;
        (red,green,blue) = hexToRGB(data.str);
        return ((red * red + blue * blue + green * green) * 50000000) / max_price;
    }

    function generateInfo(uint256 randomness) public view override onlyOwner returns (Info memory) {
        bytes32 hash = keccak256(abi.encodePacked(randomness, blockhash(block.number - 1)));
        uint256 red = uint256(hash) & 255;
        uint256 green = uint256(hash >> 8) & 255;
        uint256 blue = uint256(hash >> 16) & 255;
        return Info(_rgbToHex(red,green,blue), 666);
    }

    function _generateTokenURI(Info memory data) internal pure override returns (string memory) {
        return data.str;
    }
}