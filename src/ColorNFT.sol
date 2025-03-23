// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract ColorNFT is ERC721, Ownable {

    using Strings for uint256;

    struct Color {
        uint256 red;
        uint256 green;
        uint256 blue;
    }
    mapping(uint256 _tokenId => Color) public _colorData;
    mapping(uint256 _tokenId => uint256) public _price;
    uint256 public _tokenId;

    constructor(address owner) ERC721("ColorNFT", "COLOR") Ownable(owner) {}

    function get_price(Color memory data) pure internal returns (uint256) {
        uint256 max_price = 256 * 256 + 256 * 256 + 256 * 256;
        return ((data.red * data.red + data.blue * data.blue + data.green * data.green) * 100000000 gwei) / max_price;
    }

    function mint(address to, Color memory data) public onlyOwner {
        _colorData[_tokenId] = data;
        _price[_tokenId] = get_price(data);
        _mint(to, _tokenId);
        _tokenId++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        Color memory col =  _colorData[tokenId]; 
        return string(abi.encodePacked(
            "data:json;base64,",
            Base64.encode(bytes(string(abi.encodePacked("(", col.red.toString(), ",", col.green.toString(), ",", col.blue.toString(), ")"))))
        ));
    }
}