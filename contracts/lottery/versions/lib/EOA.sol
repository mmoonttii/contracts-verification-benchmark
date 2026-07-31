// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.36;

contract EOA {
    receive() external payable {
        // do nothing, just accept the ETH
    }
}