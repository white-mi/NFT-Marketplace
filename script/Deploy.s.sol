// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {NFTFactory} from "../src/FactoryNFT.sol";
import {CardNFT} from "../src/CardNFT.sol";
import {StarNFT} from "../src/StarNFT.sol";
import {ColorNFT} from "../src/ColorNFT.sol";
import {ERC1967Proxy} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeploySepolia is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        CardNFT cardNFT = new CardNFT("card", "CARD",1800,33000000,deployerAddress);
        ColorNFT colorNFT = new ColorNFT("color", "COLOR", 2000, 16764450,deployerAddress);
        StarNFT starNFT = new StarNFT("star","STAR",1600,20000000,deployerAddress);

        address[] memory nfts = new address[](3);
        nfts[0] = address(cardNFT);
        nfts[1] = address(colorNFT);
        nfts[2] = address(starNFT);

        NFTFactory factory = new NFTFactory(nfts, deployerAddress);
        
        uint256 subID = 42764270243560745292635787825164619464046406123037783646417796868185212121936;
        Marketplace marketplace = new Marketplace(address(factory), subID);
        factory.transferOwnership(address(marketplace));
        cardNFT.transferOwnership(address(factory));
        colorNFT.transferOwnership(address(factory));
        starNFT.transferOwnership(address(factory));

        vm.stopBroadcast();

        console.log("CardNFT address is ", address(cardNFT));
        console.log("StarNFT address is ", address(starNFT));
        console.log("ColorNFT address is ", address(colorNFT));
        console.log("Marketplace address is ", address(marketplace));
        console.log("FactoryNFT address is ", address(factory));
    }
}

contract DeploySepoliaFinal is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        CardNFT cardNFT = new CardNFT("card", "CARD",1800,33000000,deployerAddress);
        ColorNFT colorNFT = new ColorNFT("color", "COLOR", 2000, 16764450,deployerAddress);
        StarNFT starNFT = new StarNFT("star","STAR",1600,20000000,deployerAddress);

        address[] memory nfts = new address[](3);
        nfts[0] = address(cardNFT);
        nfts[1] = address(colorNFT);
        nfts[2] = address(starNFT);

        NFTFactory factory = new NFTFactory(nfts, deployerAddress);

        uint256 subID = 42764270243560745292635787825164619464046406123037783646417796868185212121936;
        Marketplace marketplace = new Marketplace(address(factory), subID);
        factory.transferOwnership(address(marketplace));
        cardNFT.transferOwnership(address(factory));
        colorNFT.transferOwnership(address(factory));
        starNFT.transferOwnership(address(factory));

        ERC1967Proxy proxy = new ERC1967Proxy(address(marketplace), "");

        vm.stopBroadcast();

        console.log("CardNFT address is ", address(cardNFT));
        console.log("StarNFT address is ", address(starNFT));
        console.log("ColorNFT address is ", address(colorNFT));
        console.log("Marketplace address is ", address(marketplace));
        console.log("FactoryNFT address is ", address(factory));
        console.log("Proxy address is ", address(proxy));
    }
}
