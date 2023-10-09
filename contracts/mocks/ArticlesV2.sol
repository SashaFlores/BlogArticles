//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Articles } from '../Articles.sol';

contract ArticlesV2 is Articles {

    function version() public pure virtual returns(string memory) {
        return 'v2.0';
    }

}