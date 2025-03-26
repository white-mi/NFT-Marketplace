// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {VRFConsumerBase} from "../lib/chainlink/contracts/src/v0.8/vrf/VRFConsumerBase.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

contract RandomNumberConsumer is VRFConsumerBase, Ownable {
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Sepolia
     * Chainlink VRF Coordinator address: 0x271682DEB8C4E0901D1a1550aD2e64D568E69909
     * LINK token address: 0x779877A7B0D9E8603169DdbD7836e478b4624789
     * Key Hash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c
     */
    constructor()
        VRFConsumerBase(
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625, // VRF Coordinator
            0x779877A7B0D9E8603169DdbD7836e478b4624789 // LINK Token
        ) Ownable(msg.sender)
    {
        keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    }

    /**
     * Requests randomness
     */
    function getRandomNumber() public onlyOwner returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(
        bytes32 ,
        uint256 randomness
    ) internal override {
        randomResult = randomness;
    }

    function withdrawLINK(address to) external onlyOwner {
        LINK.transfer(to, LINK.balanceOf(address(this)));
    }
}
