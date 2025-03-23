// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

interface INFTFactory {
    function createNFT(string memory nftType, address to) external returns (uint256);
    function cardNFT() external view returns (address);
    function colorNFT() external view returns (address);
    function starNFT() external view returns (address);
}

contract Marketplace is Ownable {
    using Math for uint256;
    
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        string nftType;
        bool isActive;
    }

    struct CurveConfig {
        uint256 basePrice;
        uint256 exponent;
        uint256 supply;
    }

    mapping(string => CurveConfig) public curves;
    mapping(bytes32 => Listing) public listings;
    bytes32[] public allListings;
    address public factory;

    event NFTListed(
        bytes32 listingId,
        string nftType,
        address indexed seller,
        uint256 price
    );
    
    event NFTBought(
        bytes32 listingId,
        address indexed buyer,
        uint256 price
    );

    constructor(address _factory) Ownable(msg.sender) {
        factory = _factory;

        curves["card"] = CurveConfig(0.01 ether, 2, 0);
        curves["color"] = CurveConfig(0.005 ether, 3, 0);
        curves["star"] = CurveConfig(0.02 ether, 2, 0);
    }

    function currentPrice(string memory nftType) public view returns (uint256) {
        CurveConfig memory config = curves[nftType];
        return config.basePrice * (config.exponent ** config.supply);
    }

    function listNFT(address nftContract, uint256 tokenId, string memory nftType) external {
        require(_isValidType(nftType), "Invalid NFT type");
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        
        bytes32 listingId = keccak256(abi.encodePacked(nftContract, tokenId));
        listings[listingId] = Listing(msg.sender, nftContract, tokenId, nftType, true);
        allListings.push(listingId);
        
        curves[nftType].supply += 1;
        emit NFTListed(listingId, nftType, msg.sender, currentPrice(nftType));
    }

    function mint(string memory nftType) external payable {
        require(_isValidType(nftType), "Invalid NFT type");
        uint256 price = currentPrice(nftType);
        require(msg.value >= price, "Insufficient funds");
        
        address nftContract = _getContractByType(nftType);
        uint256 tokenId = INFTFactory(factory).createNFT(nftType, address(this));
        
        bytes32 listingId = keccak256(abi.encodePacked(nftContract, tokenId));
        listings[listingId] = Listing(address(this), nftContract, tokenId, nftType, true);
        allListings.push(listingId);
        
        curves[nftType].supply += 1;
        emit NFTListed(listingId, nftType, msg.sender, price);
    }

    function buyNFT(bytes32 listingId) external payable {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "Listing inactive");
        
        uint256 price = currentPrice(listing.nftType);
        require(msg.value >= price, "Insufficient funds");
        
        listing.isActive = false;
        curves[listing.nftType].supply -= 1;
        
        IERC721(listing.nftContract).transferFrom(address(this), msg.sender, listing.tokenId);
        
        uint256 fee = (price * 250) / 10000; // 2.5%
        payable(owner()).transfer(fee);
        payable(listing.seller).transfer(price - fee);
        
        emit NFTBought(listingId, msg.sender, price);
    }

    function _isValidType(string memory nftType) private pure returns (bool) {
        return keccak256(abi.encodePacked(nftType)) == keccak256("card") ||
               keccak256(abi.encodePacked(nftType)) == keccak256("color") ||
               keccak256(abi.encodePacked(nftType)) == keccak256("star");
    }


    function _getContractByType(string memory nftType) private view returns (address) {
        if (keccak256(abi.encodePacked(nftType)) == keccak256("card")) return INFTFactory(factory).cardNFT();
        if (keccak256(abi.encodePacked(nftType)) == keccak256("color")) return INFTFactory(factory).colorNFT();
        if (keccak256(abi.encodePacked(nftType)) == keccak256("star")) return INFTFactory(factory).starNFT();
        revert("Unknown type");
    }

    function getActiveListings() external view returns (Listing[] memory) {
        Listing[] memory active = new Listing[](allListings.length);
        uint256 count;
        for(uint256 i = 0; i < allListings.length; i++) {
            if(listings[allListings[i]].isActive) {
                active[count] = listings[allListings[i]];
                count++;
            }
        }
        assembly { mstore(active, count) }
        return active;
    }
}
