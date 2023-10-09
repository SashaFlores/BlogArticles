const { ethers, network } = require('hardhat')
const { developmentChains } = require('../../helpers')

module.exports = async({ getNamedAccounts, deployments}) => {

    const { deploy } = deployments
    const { alex } = await getNamedAccounts()
    console.log({namedAccounts: await getNamedAccounts()})

    if (developmentChains.includes(network.name)) {

        const burn = await deploy('TestBurn', { from: alex, log: true  })
        console.log(`Test Burn Contract Address is ${burn.address}`)
        
    } else {
        console.log('This deployment script is meant for the Hardhat network only. Skipping...');
    }

}
module.exports.tags = ['burn']
module.exports.dependencies = ['articles']