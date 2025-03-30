// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {NFTFactory} from "../src/FactoryNFT.sol";
import {CardNFT} from "../src/CardNFT.sol";
import {ColorNFT} from "../src/ColorNFT.sol";
import {StarNFT} from "../src/StarNFT.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract MarketplaceTest is Test {
    Marketplace public marketplace;
    NFTFactory public factory;
    CardNFT public cardNFT;
    ColorNFT public colorNFT;
    StarNFT public starNFT;

    address owner = makeAddr("owner");
    address seller1 = makeAddr("seller1");
    address seller2 = makeAddr("seller2");
    address seller3 = makeAddr("seller3");
    address buyer1 = makeAddr("buyer1");
    address buyer2 = makeAddr("buyer2");

    function setUp() public {
        vm.startPrank(owner);

        cardNFT = new CardNFT(owner);
        colorNFT = new ColorNFT(owner);
        starNFT = new StarNFT(owner);

        factory = new NFTFactory(address(cardNFT), address(colorNFT), address(starNFT), owner);

        marketplace = new Marketplace(payable(address(factory)));
        factory.transferOwnership(address(marketplace));
        cardNFT.transferOwnership(address(factory));
        colorNFT.transferOwnership(address(factory));
        starNFT.transferOwnership(address(factory));

        vm.stopPrank();
        vm.deal(address(seller1), 1000 ether);
        vm.deal(address(seller2), 1000 ether);
        vm.deal(address(seller3), 1000 ether);
        vm.deal(address(buyer1), 1000 ether);
        vm.deal(address(buyer2), 1000 ether);
    }

    function testMintNFT() public {
        vm.startPrank(seller1);
        marketplace.mintNFT{value: marketplace.mintprice("color")}("color");
        (,, uint256 totalMinted) = marketplace.curves(address(colorNFT));
        assertEq(totalMinted, 1, "Total minted should increment");
        assertEq(colorNFT.ownerOf(0), seller1, "NFT ownership mismatch");
        console.log(seller1.balance);
        console.log(colorNFT.tokenURI(0));

        vm.startPrank(seller2);
        marketplace.mintNFT{value: marketplace.mintprice("card")}("card");
        (,, totalMinted) = marketplace.curves(address(cardNFT));
        assertEq(totalMinted, 1, "Total minted should increment");
        assertEq(cardNFT.ownerOf(0), seller2, "NFT ownership mismatch");
        console.log(seller2.balance);
        console.log(cardNFT.tokenURI(0));

        vm.startPrank(seller3);
        marketplace.mintNFT{value: marketplace.mintprice("star")}("star");
        (,, totalMinted) = marketplace.curves(address(starNFT));
        assertEq(totalMinted, 1, "Total minted should increment");
        assertEq(starNFT.ownerOf(0), seller3, "NFT ownership mismatch");
        console.log(seller3.balance);
        console.log(starNFT.tokenURI(0));
    }

    function testListAndBuyNFT() public {
        uint256 initialBalance = seller1.balance;
        uint256 tokenId = 0;

        vm.startPrank(seller1);
        marketplace.mintNFT{value: marketplace.mintprice("color")}("color");
        IERC721(address(colorNFT)).approve(address(marketplace), 0);
        marketplace.listNFT(address(colorNFT), tokenId, "color");

        bytes32 listingId = marketplace.allListings(0);

        (address lSeller, address lContract, uint256 lId,) = marketplace.listings(listingId);
        assertEq(lSeller, seller1, "Seller mismatch");
        assertEq(lContract, address(colorNFT), "Contract mismatch");
        assertEq(lId, tokenId, "Token ID mismatch");
        vm.stopPrank();

        vm.startPrank(buyer1);
        uint256 price = marketplace.calculatePrice(listingId);
        marketplace.buyNFT{value: price}(listingId);

        assertEq(colorNFT.ownerOf(tokenId), buyer1, "NFT not transferred");

        uint256 fee = (price * marketplace.platformFee()) / 10000;
        uint256 mintprice = marketplace.mintprice("color");
        assertEq(seller1.balance, initialBalance + price - mintprice - fee, "Seller payment mismatch");
        assertEq(owner.balance, fee + mintprice, "Owner balance mismatch");
    }

    function testCancelListing() public {
        vm.startPrank(seller1);
        marketplace.mintNFT{value: marketplace.mintprice("color")}("color");
        IERC721(address(colorNFT)).approve(address(marketplace), 0);
        marketplace.listNFT(address(colorNFT), 0, "color");
        vm.stopPrank();

        bytes32 id = marketplace.allListings(0);

        vm.startPrank(buyer1);
        uint256 price = marketplace.calculatePrice(id);
        console.log("ColorNFT price is ", price);
        vm.stopPrank();

        vm.startPrank(seller1);
        marketplace.returnNFT(id);
        vm.stopPrank();

        vm.startPrank(buyer1);
        vm.expectRevert();
        price = marketplace.calculatePrice(id);
        vm.stopPrank();
    }

    function testPriceDynamics() public {
        vm.startPrank(seller1);
        for (uint256 i = 0; i < 15; i++) {
            marketplace.mintNFT{value: marketplace.mintprice("color")}("color");
            IERC721(address(colorNFT)).approve(address(marketplace), i);
            marketplace.listNFT(address(colorNFT), i, "color");
        }

        for (uint256 i = 0; i < 15; i++) {
            marketplace.mintNFT{value: marketplace.mintprice("card")}("card");
            IERC721(address(cardNFT)).approve(address(marketplace), i);
            marketplace.listNFT(address(cardNFT), i, "card");
        }

        for (uint256 i = 0; i < 15; i++) {
            marketplace.mintNFT{value: marketplace.mintprice("star")}("star");
            IERC721(address(starNFT)).approve(address(marketplace), i);
            marketplace.listNFT(address(starNFT), i, "star");
        }
        vm.stopPrank();

        vm.warp(block.timestamp + 666);

        vm.startPrank(seller2);
        for (uint256 i = 15; i < 30; i++) {
            marketplace.mintNFT{value: marketplace.mintprice("color")}("color");
            IERC721(address(colorNFT)).approve(address(marketplace), i);
            marketplace.listNFT(address(colorNFT), i, "color");
        }

        for (uint256 i = 15; i < 30; i++) {
            marketplace.mintNFT{value: marketplace.mintprice("card")}("card");
            IERC721(address(cardNFT)).approve(address(marketplace), i);
            marketplace.listNFT(address(cardNFT), i, "card");
        }

        for (uint256 i = 15; i < 30; i++) {
            marketplace.mintNFT{value: marketplace.mintprice("star")}("star");
            IERC721(address(starNFT)).approve(address(marketplace), i);
            marketplace.listNFT(address(starNFT), i, "star");
        }
        vm.stopPrank();

        vm.warp(block.timestamp + 1111);

        vm.startPrank(seller3);
        for (uint256 i = 30; i < 45; i++) {
            marketplace.mintNFT{value: marketplace.mintprice("color")}("color");
            IERC721(address(colorNFT)).approve(address(marketplace), i);
            marketplace.listNFT(address(colorNFT), i, "color");
        }

        for (uint256 i = 30; i < 45; i++) {
            marketplace.mintNFT{value: marketplace.mintprice("card")}("card");
            IERC721(address(cardNFT)).approve(address(marketplace), i);
            marketplace.listNFT(address(cardNFT), i, "card");
        }

        for (uint256 i = 30; i < 45; i++) {
            marketplace.mintNFT{value: marketplace.mintprice("star")}("star");
            IERC721(address(starNFT)).approve(address(marketplace), i);
            marketplace.listNFT(address(starNFT), i, "star");
        }
        vm.stopPrank();

        bytes32[] memory colorsId = new bytes32[](100);
        for (uint256 i = 0; i < 15; i++) {
            colorsId[i] = marketplace.allListings(i);
        }
        for (uint256 i = 45; i < 60; i++) {
            colorsId[i - 30] = marketplace.allListings(i);
        }
        for (uint256 i = 90; i < 105; i++) {
            colorsId[i - 60] = marketplace.allListings(i);
        }

        bytes32[] memory cardsId = new bytes32[](100);
        for (uint256 i = 15; i < 30; i++) {
            cardsId[i - 15] = marketplace.allListings(i);
        }
        for (uint256 i = 60; i < 75; i++) {
            cardsId[i - 45] = marketplace.allListings(i);
        }
        for (uint256 i = 105; i < 120; i++) {
            cardsId[i - 75] = marketplace.allListings(i);
        }

        bytes32[] memory starsId = new bytes32[](100);
        for (uint256 i = 30; i < 45; i++) {
            starsId[i - 30] = marketplace.allListings(i);
        }
        for (uint256 i = 75; i < 90; i++) {
            starsId[i - 60] = marketplace.allListings(i);
        }
        for (uint256 i = 120; i < 135; i++) {
            starsId[i - 90] = marketplace.allListings(i);
        }

        console.log("COLOR DYNAMICS:");

        vm.startPrank(buyer1);
        uint256 price = 0;
        for (uint256 i = 0; i < 44; i++) {
            price = marketplace.calculatePrice(colorsId[i]);
            console.log(marketplace.calculatePrice(colorsId[44]));
            marketplace.buyNFT{value: price}(colorsId[i]);
        }
        vm.stopPrank();

        vm.startPrank(buyer2);

        console.log();
        console.log("CARDS DYNAMICS:");
        console.log();

        for (uint256 i = 0; i < 44; i++) {
            price = marketplace.calculatePrice(cardsId[i]);
            console.log(marketplace.calculatePrice(cardsId[44]));
            marketplace.buyNFT{value: price}(cardsId[i]);
        }

        console.log();
        console.log("STARS DYNAMICS:");
        console.log();

        for (uint256 i = 0; i < 44; i++) {
            price = marketplace.calculatePrice(starsId[i]);
            console.log(marketplace.calculatePrice(starsId[44]));
            marketplace.buyNFT{value: price}(starsId[i]);
        }
        vm.stopPrank();

        console.log("Owner balance:", owner.balance, ")))");
    }
}