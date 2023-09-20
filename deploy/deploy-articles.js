const { ethers } = require('hardhat')
const { assert } = require('chai')


module.exports = async({getNamedAccounts, deployments}) => {

    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    console.log({namedAccounts: await getNamedAccounts()})

    const deployedArticles = await deploy('Articles', {
        from: deployer,
        log: true,
        args:[],
        proxy: {
            proxyContract: 'UUPS',
            execute: {
                init: {
                    methodName: '__Articles_init',
                    args:['sasha.com/{id}.js']
                }
            }
        },
        save: true,
        waitConfirmations: network.config.blockConfirmations || 1
    })


    const articlesProxy = await ethers.getContractAt('Articles', deployedArticles.address)
    console.log(`Articles Proxy Address is: ${articlesProxy.target}`)              

    const Articles = await ethers.getContractFactory('Articles')
    const articles = Articles.attach(articlesProxy.target)
       
    assert(await articles.owner() == deployer, 'Owner check failed: Owner is not the deployer')
    console.log('Owner check passed: Owner is the deployer')

    // Get the implementation address from the proxy contract
    const implementation = await articles.getImplementation();
    console.log(`Articles Implementation Address is: ${implementation}`) 


    if (developmentChains.includes(network.name)) {
        
        const testUpdate = await articles.listTokens([1])
        console.log(`test list tokens: ${await articles.isListed(1)}`) 
    }

}
module.exports.tags = ['all', 'articles']