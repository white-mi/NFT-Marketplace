// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {Math} from "../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {UUPSUpgradeable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";

import {NFTFactory} from "./FactoryNFT.sol";

contract Marketplace is Ownable, ReentrancyGuard, UUPSUpgradeable {
    using Math for uint256;

    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        string nftType;
    }

    struct Curve {
        uint256 exponent;
        uint256 totalListed;
        uint256 totalMinted;
    }

    NFTFactory public factory;
    mapping(address => Curve) public curves;
    mapping(bytes32 => Listing) public listings;
    mapping(bytes32 => uint256) public listingIndex;
    bytes32[] public allListings;
    uint256 public platformFee = 250;
    uint256 public allTotalListed = 0;

    event NFTMinted(address indexed owner, address nftContract, uint256 tokenId);
    event NFTListed(bytes32 listingId, address indexed seller, string nftType, uint256 tokenId, uint256 price);
    event NFTBought(bytes32 listingId, address indexed buyer, uint256 price);

    constructor(address payable _factory) Ownable(msg.sender) {
        factory = NFTFactory(_factory);
        _initCurves();
    }

    function _initCurves() private {
        curves[factory.colorNFT()] = Curve(2, 0, 0);
        curves[factory.starNFT()] = Curve(5, 0, 0);
    }

    function mintNFT(string memory nftType) external {
        address nftContract = _getContractByType(nftType);
        require(nftContract != address(0), "Invalid NFT type");

        uint256 tokenId = factory.createNFT(nftType, msg.sender);
        curves[nftContract].totalMinted += 1;
        emit NFTMinted(msg.sender, nftContract, tokenId);
    }

    function listNFT(address nftContract, uint256 tokenId, string memory nftType) external {
        require(_isSupportedContract(nftContract), "Unsupported NFT");
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not owner");

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        bytes32 listingId = keccak256(abi.encodePacked(block.timestamp, nftContract, tokenId));
        listings[listingId] =
            Listing({seller: msg.sender, nftContract: nftContract, tokenId: tokenId, nftType: nftType});

        allListings.push(listingId);
        listingIndex[listingId] = allListings.length - 1;
        curves[nftContract].totalListed += 1;
        allTotalListed += 1;

        emit NFTListed(listingId, msg.sender, nftType, tokenId, calculatePrice(listingId));
    }

    function buyNFT(bytes32 listingId) external payable nonReentrant {
        Listing storage listing = listings[listingId];

        uint256 currentPrice = calculatePrice(listingId);
        require(msg.value >= currentPrice, "Insufficient funds");

        curves[listing.nftContract].totalListed -= 1;
        allTotalListed -= 1;

        uint256 index = listingIndex[listingId];
        bytes32 lastListingId = allListings[allListings.length - 1];
        allListings[index] = lastListingId;
        listingIndex[lastListingId] = index;
        allListings.pop();
        delete listings[listingId];
        delete listingIndex[listingId];

        IERC721(listing.nftContract).transferFrom(address(this), msg.sender, listing.tokenId);

        uint256 fee = (currentPrice * platformFee) / 10000;
        payable(owner()).transfer(fee);
        payable(listing.seller).transfer(currentPrice - fee);
        if (msg.value > currentPrice) {
            payable(msg.sender).transfer(msg.value - currentPrice);
        }

        emit NFTBought(listingId, msg.sender, currentPrice);
    }

    function returnNFT(bytes32 listingId) external {
        Listing storage listing = listings[listingId];

        require(msg.sender == address(listing.seller));

        curves[listing.nftContract].totalListed -= 1;
        allTotalListed -= 1;

        uint256 index = listingIndex[listingId];
        bytes32 lastListingId = allListings[allListings.length - 1];
        allListings[index] = lastListingId;
        listingIndex[lastListingId] = index;
        allListings.pop();
        delete listings[listingId];
        delete listingIndex[listingId];

        IERC721(listing.nftContract).transferFrom(address(this), msg.sender, listing.tokenId);
    }

    function getActiveListings() external view returns (Listing[] memory) {
        Listing[] memory active = new Listing[](allListings.length);
        uint256 count;

        for (uint256 i = 0; i < allListings.length; i++) {
            active[count] = listings[allListings[i]];
        }

        return active;
    }

    function calculatePrice(bytes32 listingId) public view returns (uint256) {
        Listing memory listing = listings[listingId];
        Curve memory curve = curves[listing.nftContract];
        uint256 basePrice = factory.getBasePrice(listing.nftType, listing.tokenId);
        return basePrice * (curve.exponent ** (curve.totalMinted - curve.totalListed))
            * (allTotalListed + 1 / curve.totalListed + 1);
    }

    function _getContractByType(string memory nftType) private view returns (address) {
        if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("color"))) return factory.colorNFT();
        if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("star"))) return factory.starNFT();
        return address(0);
    }

    function _isSupportedContract(address nftContract) private view returns (bool) {
        return nftContract == factory.cardNFT() || nftContract == factory.colorNFT();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
