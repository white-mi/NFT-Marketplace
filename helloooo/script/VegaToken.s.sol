// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VegaToken} from "../src/VegaToken.sol";

contract CounterScript is Script {
    VegaToken public vt;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        vt = new VegaToken();

        vm.stopBroadcast();
    }
}
