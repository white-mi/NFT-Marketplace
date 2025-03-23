// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Math} from  "../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

interface INFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract Marketplace is Ownable {

    using Math for uint256;

    struct Listing {
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool isForSale;
    }

    mapping(uint256 => Listing) public listings;
    uint256 public listingCount;

    uint256 public constant K = 0.01;
    mapping(address => uint256) public basePrice;

    mapping(address => uint256) public balances;

    event NFTListed(address indexed seller, address indexed nftContract, uint256 tokenId, uint256 price);
    event NFTPurchased(address indexed buyer, address indexed nftContract, uint256 tokenId, uint256 price);
    event Withdrawal(address indexed user, uint256 amount);

    constructor() {
        basePrice[address(0)] = 0.01 ether;
    }

    function listNFT(address nftContract, uint256 tokenId, uint256 price) public {
        require(INFT(nftContract).ownerOf(tokenId) == msg.sender, "You do not own this NFT");
        listings[listingCount] = Listing(nftContract, tokenId, price, true);
        listingCount++;

        emit NFTListed(msg.sender, nftContract, tokenId, price);
    }

    function buyNFT(uint256 listingId) public payable {
        Listing storage listing = listings[listingId];
        require(listing.isForSale, "NFT is not for sale");
        require(msg.value >= listing.price, "Insufficient payment");

        INFT(listing.nftContract).transferFrom(listing.owner, msg.sender, listing.tokenId);
        balances[listing.owner] += listing.price;
        listing.isForSale = false;

        emit NFTPurchased(msg.sender, listing.nftContract, listing.tokenId, listing.price);
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    function getCurrentPrice(address nftContract) public view returns (uint256) {
        uint256 supply = INFT(nftContract).totalSupply();
        return basePrice[nftContract].mul(uint256(2).pow(supply));
    }
}