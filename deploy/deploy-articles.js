const { ethers, network } = require('hardhat')
const { assert } = require('chai')
const { developmentChains, verify } = require('../helpers')


module.exports = async({getNamedAccounts, deployments}) => {

    const { deploy, save } = deployments;
    const { deployer } = await getNamedAccounts();

    console.log({namedAccounts: await getNamedAccounts()})

    const deployedImp = await deploy('Articles', { from: deployer, log: true  })
    console.log(`Deployed Imp Address is ${deployedImp.address}`)

    const implementation = await ethers.getContractAt('Articles', deployedImp.address)

    const encodedFuncData = implementation.interface.encodeFunctionData('__Articles_init', ['https://www.sashaflores.xyz/metadata/'])

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

    const artifacts = await deployments.getExtendedArtifact('Articles')
    let deployedArticles = { address: articlesProxy.target, artifact: artifacts}
    await save('Articles', deployedArticles)
    const testDeployGet = await deployments.get('Articles')
    console.log(`Test saved Deployment: ${testDeployGet.address}`)


    assert(await articles.owner() == deployer, 'Owner check failed: Owner is not the deployer')
    console.log('Owner check passed: Owner is the deployer')



    
    if(!developmentChains.includes(network.name)) {
        console.log(`Verifying Implementation First on ${network.name}`)
        await verify(implementation)
        console.log(`Verifying Articles First on ${network.name}`)
        await verify(articles.address, args)
    }

}
module.exports.tags = ['all', 'articlesProxy', 'articles', 'implementation']