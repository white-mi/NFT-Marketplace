// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract StarNFT is ERC721, Ownable {

    using Strings for uint256;

    struct Star {
        string star;
        uint256 num;
    }
    mapping(uint256 _tokenId => Star) public _starData;
    mapping(uint256 _tokenId => uint256) public _price;
    uint256 public _tokenId;

    constructor(address owner) ERC721("StarNFT", "STAR") Ownable(owner) {}

    function get_price(Star memory data) pure internal returns (uint256) {

        string[30] memory stars = ["VEGA", "SIRIUS", "ALPHA", "BETA", "GAMMA",
         "DELTA", "EPSILON", "ZETA", "ETA", "THETA", "IOTA", "KAPPA", "LAMBDA", 
         "OMEGA", "POLARIS", "ARCTURUS", "RIGEL", "BETELGEUSE", "ALDEBARAN", 
         "CANOPUS", "PROCYON", "CAPELLA", "ANTARES", "SPICA", "DENEB", "FOMALHAUT", 
         "ALTAIR", "MIRACH", "CASTRO", "POLLUX"];

        uint256 index = 0;

        for (uint256 i = 0; i < 30; i++) {
            if (keccak256(abi.encodePacked(stars[i])) == keccak256(abi.encodePacked(data.star))) {
                index = i;
                break;
            }
        }

        return ((30 - index) + data.num / 10000) * 10000000 gwei;
    }

    function mint(address to, Star memory data) public onlyOwner {
        _starData[_tokenId] = data;
        _price[_tokenId] = get_price(data);
        _mint(to, _tokenId);
        _tokenId++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        Star memory star = _starData[tokenId];
        return string(abi.encodePacked(
            "data:json;base64,",
            Base64.encode(bytes(string(abi.encodePacked(star.star, star.num.toString()))))
        ));
    }
}