// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {VRFCoordinatorV2Interface} from "../lib/chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "../lib/chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {ConfirmedOwner} from "../lib/chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {Math} from "../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {UUPSUpgradeable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";

import {NFTFactory} from "./FactoryNFT.sol";

contract Marketplace is VRFConsumerBaseV2, ReentrancyGuard, UUPSUpgradeable, ConfirmedOwner {
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

    struct MintRequest {
        address user;
        string nftType;
        uint256 paidAmount;
    }

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }

    bytes32 internal keyHash;
    uint256 public randomResult;
    uint64 internal s_subscriptionId;
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint32 internal callbackGasLimit = 100000;
    uint16 internal requestConfirmations = 3;
    uint32 internal numWords = 2;
    VRFCoordinatorV2Interface public COORDINATOR;
    mapping(uint256 => MintRequest) public mintRequests;
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    NFTFactory public factory;
    mapping(address => Curve) public curves;
    mapping(bytes32 => Listing) public listings;
    mapping(bytes32 => uint256) public listingIndex;
    mapping(string => uint256) public mintprice;
    bytes32[] public allListings;
    uint256 public platformFee = 250;
    uint256 public totalListed = 0;

    event MintStarted(uint256 requestId, address indexed user);
    event NFTMinted(address indexed owner, string nftType, uint256 tokenId);
    event NFTListed(bytes32 listingId, address indexed seller, string nftType, uint256 tokenId, uint256 price);
    event NFTBought(bytes32 listingId, address indexed buyer, uint256 price);
    event NFTReturned(bytes32 listingId, address indexed keeper);

    constructor(address payable _factory, uint64 subscriptionId)
        VRFConsumerBaseV2(
            0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B // VRF Coordinator
        )
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B
        );
        s_subscriptionId = subscriptionId;
        factory = NFTFactory(_factory);
        _initCurves();
        _initMints();
    }

    function _initCurves() internal {
        curves[factory.colorNFT()] = Curve(200, 0, 0);
        curves[factory.cardNFT()] = Curve(180, 0, 0);
        curves[factory.starNFT()] = Curve(160, 0, 0);
    }

    function _initMints() internal {
        mintprice["color"] = 16764450 * curves[factory.colorNFT()].exponent / (curves[factory.colorNFT()].exponent - 2);
        mintprice["card"] = 31000000 * curves[factory.cardNFT()].exponent / (curves[factory.cardNFT()].exponent - 2);
        mintprice["star"] = 20000000 * curves[factory.starNFT()].exponent / (curves[factory.starNFT()].exponent - 2);
    }

    function mintNFT(string memory nftType) external payable nonReentrant {
        require(msg.value == mintprice[nftType], "Incorrect payment");

        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });

        requestIds.push(requestId);
        lastRequestId = requestId;

        mintRequests[requestId] = MintRequest(msg.sender, nftType, msg.value);

        emit MintStarted(requestId, msg.sender);
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        MintRequest memory req = mintRequests[_requestId];
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        uint256 randomness = _randomWords[0]+_randomWords[1];
        uint256 tokenId = factory.createNFT(req.nftType, req.user, randomness);

        payable(owner()).transfer(req.paidAmount);
        delete mintRequests[_requestId];

        emit NFTMinted(req.user, req.nftType, tokenId);
    }

    function listNFT(address nftContract, uint256 tokenId, string memory nftType) external {
        require(_isSupportedContract(nftContract), "Unsupported NFT");
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not owner");

        bytes32 listingId = keccak256(abi.encodePacked(block.timestamp, nftContract, tokenId));
        listings[listingId] =
            Listing({seller: msg.sender, nftContract: nftContract, tokenId: tokenId, nftType: nftType});

        allListings.push(listingId);
        listingIndex[listingId] = allListings.length - 1;
        curves[nftContract].totalListed += 1;
        totalListed += 1;

        emit NFTListed(listingId, msg.sender, nftType, tokenId, calculatePrice(listingId));
    }

    function buyNFT(bytes32 listingId) external payable nonReentrant {
        require(listings[listingId].seller != address(0), "Listing not found");
        Listing memory listing = listings[listingId];

        uint256 currentPrice = calculatePrice(listingId);
        require(msg.value == currentPrice, "Insufficient funds");

        curves[listing.nftContract].totalListed -= 1;
        totalListed -= 1;

        uint256 index = listingIndex[listingId];
        bytes32 lastListingId = allListings[allListings.length - 1];
        allListings[index] = lastListingId;
        listingIndex[lastListingId] = index;
        allListings.pop();
        delete listings[listingId];
        delete listingIndex[listingId];

        IERC721(listing.nftContract).transferFrom(listing.seller, msg.sender, listing.tokenId);

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

        require(msg.sender == address(listing.seller), "Not the owner");

        curves[listing.nftContract].totalListed -= 1;
        totalListed -= 1;

        uint256 index = listingIndex[listingId];
        bytes32 lastListingId = allListings[allListings.length - 1];
        allListings[index] = lastListingId;
        listingIndex[lastListingId] = index;
        allListings.pop();
        delete listings[listingId];
        delete listingIndex[listingId];

        emit NFTReturned(listingId, msg.sender);
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
        uint256 exp = 1000000;
        for (uint256 i = 0; i < curve.totalMinted - curve.totalListed; i++) {
            exp = exp * curve.exponent;
            exp = exp / (curve.exponent - 2);
            if (exp > 10000000) {
                exp = 10000000;
                break;
            }
        }
        return basePrice * exp / 1000000;
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    function _getContractByType(string memory nftType) internal view returns (address) {
        if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("card"))) return factory.cardNFT();
        if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("color"))) return factory.colorNFT();
        if (keccak256(abi.encodePacked(nftType)) == keccak256(abi.encodePacked("star"))) return factory.starNFT();
        return address(0);
    }

    function _isSupportedContract(address nftContract) internal view returns (bool) {
        return nftContract == factory.cardNFT() || nftContract == factory.colorNFT() || nftContract == factory.starNFT();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
