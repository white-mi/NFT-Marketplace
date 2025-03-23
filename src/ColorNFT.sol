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
    mapping(uint256 => Color) private _colorData;
    uint256 public _tokenId;

    constructor(address owner) ERC721("ColorNFT", "COLOR") Ownable(owner) {}

    function mint(address to, Color memory data) public onlyOwner {
        _colorData[_tokenId] = data;
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