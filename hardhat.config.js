require("@chainlink/env-enc").config();
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-foundry");
require("@nomiclabs/hardhat-solhint");
require('@openzeppelin/hardhat-upgrades');
require("hardhat-contract-sizer");
require('hardhat-spdx-license-identifier');


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
};
