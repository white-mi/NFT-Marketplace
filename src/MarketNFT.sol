// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

abstract contract MarketNFT is ERC721, Ownable {
    struct Info{
        string str;
        uint256 num;
    }

    mapping(uint256 _tokenId => Info) public _nftData;
    mapping(uint256 _tokenId => uint256) public _tokenPrice;
    uint256 public _tokenId;
    uint256 public curveExp;
    uint256 public meanPrice;

    constructor(
        string memory name, 
        string memory symbol,
        uint256 _exponentCurve,
        uint256 _meanPrice,
        address owner
    ) ERC721(name, symbol) Ownable(owner) {
        curveExp=_exponentCurve;
        meanPrice=_meanPrice;
    }

    function get_price(Info memory data) internal view virtual returns (uint256) {
        return data.num;
    }

    function generateInfo(uint256 randomness) public virtual onlyOwner returns (Info memory) {
        return Info('',randomness%10);
    }

    function mint(address to, Info memory data) public onlyOwner {
        _nftData[_tokenId] = data;
        _tokenPrice[_tokenId] = get_price(data);
        _mint(to, _tokenId);
        _tokenId++;
    }

    function _generateTokenURI(Info memory data) internal view virtual returns (string memory) {
        return data.str;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        Info memory data = _nftData[tokenId];
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(bytes(_generateTokenURI(data)))
            )
        );
    }

}