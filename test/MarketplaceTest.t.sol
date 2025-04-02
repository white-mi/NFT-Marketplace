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
    uint64 subID = 1000;

    function setUp() public {
        vm.startPrank(owner);

        cardNFT = new CardNFT(owner);
        colorNFT = new ColorNFT(owner);
        starNFT = new StarNFT(owner);

        factory = new NFTFactory(address(cardNFT), address(colorNFT), address(starNFT), owner);

        marketplace = new Marketplace(payable(address(factory)), subID);
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

}
