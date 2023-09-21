require('dotenv').config()
require('@nomicfoundation/hardhat-ethers')
require('hardhat-deploy')
require('hardhat-deploy-ethers')
require('@nomicfoundation/hardhat-chai-matchers')
// require('@nomicfoundation/hardhat-foundry')
require('@nomiclabs/hardhat-solhint')
require('solidity-coverage')
require('hardhat-gas-reporter')
require('@nomicfoundation/hardhat-verify')
require('hardhat-spdx-license-identifier')
// require('hardhat-exposed')
require('@primitivefi/hardhat-dodoc')
require('@openzeppelin/hardhat-upgrades')

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      chainId: 31337
    },
    polygonMumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${process.env.INFURA_API_KEY}`,
      chainId: 80001,
      saveDeployments: true,
      tags: ['staging'],
      blockConfirmations: 1,
      accounts: [`0x${process.env.MUMBAI_DEPLOYER}`]
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
      chainId: 11155111,
      saveDeployments: true,
      tags: ['staging'],
      blockConfirmations: 1
    },
    eth: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      chainId: 1,
      saveDeployments: true,
      tags: ['live'],
      blockConfirmations: 5
    },
    polygon: {
      url: `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      chainId: 137,
      saveDeployments: true,
      tags: ['live'],
      blockConfirmations: 5
    },
    base: {
      url: `https://mainnet.base.org`, //needs edit
      chainId: 8453,
      saveDeployments: true,
      tags: ['live'],
      blockConfirmations: 5
    },
    astar: {
      url: `https://astar-mainnet.g.alchemy.com/v2/your-alchemy-api-key`, //needs edit
      chainId: 592,
      saveDeployments: true,
      tags: ['live'],
      blockConfirmations: 5
    },
    optimism: {
      url: `https://optimism-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      chainId: 10,
      saveDeployments: true,
      tags: ['live'],
      blockConfirmations: 5
    }
  },
  namedAccounts: {
    deployer: {
      default: 0,
      mumbai: 0,
    },
  },
  gasReporter: {
    enabled: true,
    coinmarketcap: process.env.COINMARKETCAP,
    outputFile: "gasReporter.txt",
    noColors: false,
    currency: "USD", 
  },
  solidity: {
    compilers: [
      {
        version: '0.8.20',
      }, 
      {
        version: '0.8.0',
      }
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      }
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.POLYGON_SCAN_API,
      // polygon: process.env.POLYGON_SCAN_API,
      // sepolia: process.env.SEPOLIA_API,
      // optimisticEthereum: privateKey,
    }
  },
  // exposed: {
  //   exclude: ['mockV2/**/**', 'proxy/**/**'],
  //   outDir: '@contracts-exposed',
  //   prefix: '$',
  // },
  paths: {
    sources: './contracts',
    deploy: './deploy',
    deployments: './deployments',
    scripts: './scripts',
    tests: './test',
    artifacts: './artifacts',
    cache: './cache',
    slither: './slither'
  },
  
};
