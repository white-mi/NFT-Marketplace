// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MarketNFT} from "./MarketNFT.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {AccessControl} from "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

contract NFTFactory is Ownable, AccessControl {

    mapping(string => address) nfts;
    string[] keys;
    bytes32 public constant ADMIN = keccak256("ADMINCHIK");

    constructor(address[] memory _nfts, address owner) Ownable(owner) {
        _grantRole(ADMIN, msg.sender);
        for (uint256 i = 0; i < _nfts.length; i++) {
            nfts[MarketNFT(_nfts[i]).name()] = _nfts[i];
            keys.push(MarketNFT(_nfts[i]).name());
        }
    }

    function generateNFT(uint256 randomness, string memory name) internal returns (MarketNFT.Info memory) {
        return MarketNFT(nfts[name]).generateInfo(randomness);
    }

    function createNFT(string memory nftType, address to, uint256 randomness) external onlyOwner returns (uint256) {
        bool flag = false;
        for (uint256 i = 0; i < keys.length; i++) {
            if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked(keys[i]))) {
                flag = true;
                break;
            }
        }
        require(flag, "Invalid NFT type");
        MarketNFT.Info memory data = generateNFT(randomness, nftType);
        MarketNFT(nfts[nftType]).mint(to, data);
        return MarketNFT(nfts[nftType])._tokenId() - 1;
    }

    function getBasePrice(string memory nftType, uint256 tokenId) external view onlyOwner returns (uint256) {
        bool flag = false;
        for (uint256 i = 0; i < keys.length; i++) {
            if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked(keys[i]))) {
                flag = true;
                break;
            }
        }
        require(flag, "Invalid NFT type");
        return MarketNFT(nfts[nftType])._tokenPrice(tokenId);
    }

    function addNewNFT(address newNFT) public onlyRole(ADMIN) {
        nfts[MarketNFT(newNFT).name()] = newNFT;
        keys.push(MarketNFT(newNFT).name());
    }

    function getKeysLen() external view returns (uint256) {
        return keys.length;
    }

    function getNftName(uint256 i) external view returns (string memory) {
        return keys[i];
    }

    function getNftAddr(string memory name) external view returns (address) {
        bool flag = false;
        for (uint256 i = 0; i < keys.length; i++) {
            if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked(keys[i]))) {
                flag = true;
                break;
            }
        }
        return flag ? nfts[name] : address(0);
    }
}