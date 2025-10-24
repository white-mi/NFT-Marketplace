// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from '../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol';

contract VegaToken is ERC20 {
    constructor() ERC20('Vega Token', 'Vega') {}

    function mint(uint256 amount) external {
        _mint(msg.sender, amount);
    }
}
 