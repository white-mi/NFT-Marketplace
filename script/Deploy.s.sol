// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {NFTFactory} from "../src/FactoryNFT.sol";
import {CardNFT} from "../src/CardNFT.sol";
import {StarNFT} from "../src/StarNFT.sol";
import {ColorNFT} from "../src/ColorNFT.sol";

contract DeploySepolia is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address public owner = msg.sender;
        vm.startBroadcast(deployerKey);
        cardNFT = new CardNFT(owner);
        colorNFT = new ColorNFT(owner);
        starNFT = new StarNFT(owner);

        factory = new NFTFactory(address(cardNFT), address(colorNFT), address(starNFT), owner);

        marketplace = new Marketplace(payable(address(factory)), );
        factory.transferOwnership(address(marketplace));
        cardNFT.transferOwnership(address(factory));
        colorNFT.transferOwnership(address(factory));
        starNFT.transferOwnership(address(factory));
        vm.stopBroadcast();
    }
}