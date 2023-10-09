//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Articles } from '../Articles.sol';

contract TestBurn is Articles {

    function burn(uint256 id) public {
        _burn(msg.sender, id, 1);
    }

    function transferZeroAddress(address from, uint256 id) public {
        _safeTransferFrom(from, address(0), id, 1, '');
    }
}