//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Articles } from '../Articles.sol';

contract ArticlesV2 is Articles {

    function mintBatch(uint256[] memory ids) public {
        uint256[] memory amounts = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            amounts[i] = 1; 
        }
        _mintBatch(_msgSender(), ids, amounts, '');
    }

    function version() pure public returns(string memory) {
        return 'v2.0';
    }

}