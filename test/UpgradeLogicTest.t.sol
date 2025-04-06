// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {MockMarketplace} from "../src/MockMarketplace.sol";
import {NFTFactory} from "../src/FactoryNFT.sol";
import {CardNFT} from "../src/CardNFT.sol";
import {ColorNFT} from "../src/ColorNFT.sol";
import {StarNFT} from "../src/StarNFT.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract MarketplaceTest is Test {
    MockMarketplace public marketplace;
    NFTFactory public factory;
    CardNFT public cardNFT;
    ColorNFT public colorNFT;
    StarNFT public starNFT;

    address owner = makeAddr("owner");
    address seller = makeAddr("seller");
    address buyer = makeAddr("buyer");

    function setUp() public {
        vm.startPrank(owner);

        cardNFT = new CardNFT("card", "CARD", 1800, 33000000, owner);
        colorNFT = new ColorNFT("color", "COLOR", 2000, 16764450, owner);
        starNFT = new StarNFT("star", "STAR", 1600, 20000000, owner);

        address[] memory nfts = new address[](2);
        nfts[0] = address(cardNFT);
        nfts[1] = address(starNFT);

        factory = new NFTFactory(nfts, owner);

        marketplace = new MockMarketplace(address(factory));
        factory.transferOwnership(address(marketplace));
        cardNFT.transferOwnership(address(factory));
        starNFT.transferOwnership(address(factory));

        vm.stopPrank();
        vm.deal(address(seller), 1000 ether);
        vm.deal(address(buyer), 1000 ether);
    }

    function testMain() public {
        vm.startPrank(seller);
        uint256 mintprice = marketplace.getMintPrice("card");
        marketplace.mintNFT{value: mintprice}("card");
        IERC721(address(cardNFT)).approve(address(marketplace), 0);
        marketplace.listNFT(0, "card");

        mintprice = marketplace.getMintPrice("star");
        marketplace.mintNFT{value: mintprice}("star");
        IERC721(address(starNFT)).approve(address(marketplace), 0);
        marketplace.listNFT(0, "star");
        vm.stopPrank();

        vm.startPrank(owner);
        marketplace.addNewNftToMarket(address(colorNFT));
        colorNFT.transferOwnership(address(factory));
        vm.stopPrank();

        vm.startPrank(seller);
        mintprice = marketplace.getMintPrice("color");
        marketplace.mintNFT{value: mintprice}("color");
        IERC721(address(colorNFT)).approve(address(marketplace), 0);
        marketplace.listNFT(0, "color");
        vm.stopPrank();

        vm.startPrank(buyer);
        bytes32[] memory Ids = new bytes32[](3);
        Ids[0] = marketplace.allListings(0);
        Ids[1] = marketplace.allListings(1);
        Ids[2] = marketplace.allListings(2);

        uint256 price = marketplace.calculatePrice(Ids[0]);
        marketplace.buyNFT{value: price}(Ids[0]);

        price = marketplace.calculatePrice(Ids[1]);
        marketplace.buyNFT{value: price}(Ids[1]);

        price = marketplace.calculatePrice(Ids[2]);
        marketplace.buyNFT{value: price}(Ids[2]);
        vm.stopPrank();

        assertEq(colorNFT.ownerOf(0), buyer, "NFT not transferred");
        assertEq(cardNFT.ownerOf(0), buyer, "NFT not transferred");
        assertEq(starNFT.ownerOf(0), buyer, "NFT not transferred");
    }
}