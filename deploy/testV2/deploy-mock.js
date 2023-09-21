const { ethers } = require('hardhat')
const { developmentChains } = require('../../helpers')

module.exports = async({getNamedAccounts, deployments}) => {

    // deploy only on hardhat 
    if (!developmentChains.includes(network.name)) {
        console.log('This deployment script is meant for the Hardhat network only. Skipping...');
        return;
    }

    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    console.log({namedAccounts: await getNamedAccounts()})

    
    const Articles = await ethers.getContractFactory('Articles')
    const articlesProxy = await ethers.getContract('ArticlesProxy')
    const articles = Articles.attach(articlesProxy.target)
    console.log(`Articles V1 Address is: ${await articles.getAddress()}`)        
   

    const deployedImp = await deploy('ArticlesV2', { from: deployer, log: true })
    const secondImp = await ethers.getContractAt('ArticlesV2', deployedImp.address)
    console.log(`Implementation V2 Address is: ${secondImp.target}`)


    await articles.pause()
    console.log(`Is Paused: ${await articles.paused()}`)


    const upgrade = await articles.upgradeTo(secondImp.target)
    const upgradeTx = await upgrade.wait(1)
    if (upgradeTx.status === 1) {
        console.log("Upgrade was successful!");
    } else {
        console.error("Upgrade failed or was reverted!");
    }

    const upgradedArticles = await ethers.getContractAt('ArticlesV2', articles.target)
    console.log(`Deployed Version 2 address is: ${upgradedArticles.target}`)

    
    console.log(`check upgrade: ${await upgradedArticles.version()}`)
    console.log(`check owner: ${await upgradedArticles.owner()}`)

    // Shane Todd
}
module.exports.tags = ['mock']
module.exports.dependencies = ['articles']