const { ethers, network } = require('hardhat')
const { assert } = require('chai')
const { developmentChains, verify } = require('../helpers')


module.exports = async({getNamedAccounts, deployments}) => {

    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    console.log({namedAccounts: await getNamedAccounts()})

    const deployedImp = await deploy('Articles', { from: deployer, log: true  })
    console.log(`Deployed Imp Address is ${deployedImp.address}`)

    const implementation = await ethers.getContractAt('Articles', deployedImp.address)

    const encodedFuncData = implementation.interface.encodeFunctionData('__Articles_init', ['test uri'])

    const deployedProxy = await deploy('ArticlesProxy', {
        from: deployer,
        args:[deployedImp.address, encodedFuncData],
        log: true
    })
    console.log(`Deployed Proxy Address is ${deployedProxy.address}`)

    const Articles = await ethers.getContractFactory('Articles')
    const articlesProxy = await ethers.getContractAt('ArticlesProxy', deployedProxy.address)

    const articles = Articles.attach(articlesProxy.target)
    console.log(`Articles Address is ${await articles.getAddress()}`)

    assert(await articles.owner() == deployer, 'Owner check failed: Owner is not the deployer')
    console.log('Owner check passed: Owner is the deployer')

    // Get the implementation address from the proxy contract
    const impFromArticles = await articles.getImplementation()
    console.log(`Implementation Address from Articles: ${impFromArticles}`) 

    const impFromProxy = await articlesProxy.implementation()
    console.log(`Implementation Address from Articles Proxy: ${impFromProxy}`) 
 

    if(!developmentChains.includes(network.name)) {
        console.log(`Verifying Implementation First on ${network.name}`)
        await verify(implementation)
        console.log(`Verifying Articles First on ${network.name}`)
        await verify(articles.address, args)
    }

}
module.exports.tags = ['articlesProxy', 'articles', 'implementation']