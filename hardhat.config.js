require("@chainlink/env-enc").config();
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-foundry");
require("@nomiclabs/hardhat-solhint");
require('@openzeppelin/hardhat-upgrades');
require("hardhat-contract-sizer");
require('hardhat-exposed');
require('hardhat-spdx-license-identifier');


const ETHEREUM_SEPOLIA_RPC_URL = process.env.ETHEREUM_SEPOLIA_RPC_URL
const BINANCE_TESTNET_RPC_URL = process.env.BINANCE_TESTNET_RPC_URL
const POLYGON_AMOY_RPC_URL = process.env.POLYGON_AMOY_RPC_URL
const BASE_SEPOLIA_RPC_URL = process.env.BASE_SEPOLIA_RPC_URL

const ETHEREUM_MAINNET_RPC_URL = process.env.ETHEREUM_MAINNET_RPC_URL
const POLYGON_MAINNET_RPC_URL = process.env.POLYGON_MAINNET_RPC_URL
const BINANCE_MAINNET_RPC_URL = process.env.BINANCE_MAINNET_RPC_URL
const BASE_MAINNET_RPC_URL = process.env.BASE_MAINNET_RPC_URL

const FIRST_ACCOUNT = process.env.FIRST_ACCOUNT
const SECOND_ACCOUNT = process.env.SECOND_ACCOUNT
const THIRD_ACCOUNT = process.env.THIRD_ACCOUNT




/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337
    },
    amoy: {
      url: POLYGON_AMOY_RPC_URL || "undefined",
      chainId: 80002,
      nativeCurrency: "POL",
      accounts: [FIRST_ACCOUNT, SECOND_ACCOUNT, THIRD_ACCOUNT].filter(Boolean)
    },
    sepolia: {
      url: ETHEREUM_SEPOLIA_RPC_URL || "undefined",
      chainId: 11155111,
      nativeCurrency: "ETH",
      accounts: [FIRST_ACCOUNT, SECOND_ACCOUNT, THIRD_ACCOUNT].filter(Boolean)
    },
    baseSepolia: {
      url: BASE_SEPOLIA_RPC_URL || "undefined",
      chainId: 84532,
      nativeCurrency: "ETH",
      accounts: [FIRST_ACCOUNT, SECOND_ACCOUNT, THIRD_ACCOUNT].filter(Boolean)
    },
    binanceTestnet: {
      url: BINANCE_TESTNET_RPC_URL || "undefined",
      chainId: 97,
      nativeCurrency: "BNB",
      accounts: [FIRST_ACCOUNT, SECOND_ACCOUNT, THIRD_ACCOUNT].filter(Boolean)
    },
    ethereum: {
      url: ETHEREUM_MAINNET_RPC_URL || "undefined",
      chainId: 1,
      nativeCurrency: "ETH",
      accounts: [FIRST_ACCOUNT, SECOND_ACCOUNT, THIRD_ACCOUNT].filter(Boolean)
    },
    polygon: {
      url: POLYGON_MAINNET_RPC_URL || "undefined",
      chainId: 137,
      nativeCurrency: "POL",
      accounts: [FIRST_ACCOUNT, SECOND_ACCOUNT, THIRD_ACCOUNT].filter(Boolean)
    },
    binance: {
      url: BINANCE_MAINNET_RPC_URL || "undefined",
      chainId: 56,
      nativeCurrency: "BNB",
      accounts: [FIRST_ACCOUNT, SECOND_ACCOUNT, THIRD_ACCOUNT].filter(Boolean)
    },
    base: {
      url: BASE_MAINNET_RPC_URL || "undefined",
      chainId: 8453,
      nativeCurrency: "ETH",
      accounts: [FIRST_ACCOUNT, SECOND_ACCOUNT, THIRD_ACCOUNT].filter(Boolean)
    }
  },
  solidity: {
    version: "0.8.28",
    settings: {
      evmVersion: "prague"
    }
  },
  contractSizer: {
    runOnCompile: true,
    unit: "B",
    strict: true,
    only: [':Blog$'],
  },
  spdxLicenseIdentifier: {
    runOnCompile: true,
    only: ['contracts/']
  },
  exposed: {
    // exclude: ['mockV2/**/**', 'proxy/**/**'],
    outDir: 'contracts-exposed',
    prefix: '$',
  },
  paths: {
    sources: './contracts',
    tests: './test',
    artifacts: './artifacts',
    cache: './cache',
    slither: './slither'
  },
  etherscan: {
    apiKey: {
      amoy: process.env.POLYGONSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
      sepolia: process.env.ETHERSCAN_API_KEY,
      ethereum: process.env.ETHERSCAN_API_KEY,
      binanceTestnet: process.env.BSCSCAN_API_KEY,
      binance: process.env.BSCSCAN_API_KEY,
      baseSepolia: process.env.BASESCAN_API_KEY,
      base: process.env.BASESCAN_API_KEY
    }
  },
};
