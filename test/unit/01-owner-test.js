const { ethers, deployments, getNamedAccounts, getUnnamedAccounts } = require('hardhat')
const { expect } = require('chai')
const { 
    ZeroAddress, 
    expectRevert, 
    expectRevertWithCustomError, 
    URI, 
    premiumId,
    PremiumFee,
    standardId,
    StandardFee,
    developmentChains,
    chainId,
    url
} = require('../../helpers')
const { NonceManager } = require('ethers')



describe('Articles Unit Testing', function() {

    let deployer, alex, minters, articles

    beforeEach(async function() {

        await deployments.fixture(['all'])
        deployer = (await getNamedAccounts()).deployer
        alex = (await getNamedAccounts()).alex
        minters = await getUnnamedAccounts()
        const deployedArticles = await deployments.get('Articles')
        articles = await ethers.getContractAt('Articles', deployedArticles.address)
    })

    describe('init function initiated properly', function(){
       
        it('initialize function not invoked twice', async function() {
            await expectRevert(articles.__Articles_init(URI), 'Initializable: contract is already initialized')
        })
        it('owner is the deployer', async function() {
            expect(await articles.owner()).to.equal(deployer)
        })
        it('is not paused', async function() {
            expect(await articles.paused()).to.equal(false)
        })
        it('emits transfer ownership event', async function() {
            
            const transferEvents = await articles.queryFilter('OwnershipTransferred')
            expect(transferEvents.length).to.be.greaterThan(0)
            const transferEvent = transferEvents[transferEvents.length - 1]
            const [previousOwner, newOwner] = transferEvent.args

            expect(await previousOwner).to.equal(ZeroAddress)
            expect(await newOwner).to.equal(deployer)
        
        })
        it('emits initialized event', async function() {
            const initializedEvents = await articles.queryFilter('Initialized');
            const initializedEvent = initializedEvents[initializedEvents.length - 1]
            const [version] = initializedEvent.args

            expect(await version).to.equal(1)
        })
        
        it('no tokens are minted yet', async function() {
            expect(await articles.totalSupply(standardId)).to.equal(0)
            expect(await articles.totalSupply(premiumId)).to.equal(0)
        })
    })

    describe('transfer ownership test', function() {
        let transfer
        beforeEach(async function () {
            transfer = await articles.transferOwnership(alex, { from: deployer })
        })
        it('only owner can transfer ownership', async function() {
            expect(await articles.owner()).to.equal(alex)
        })
        it('emits transfer event', async function () {
            await expect(transfer).to.emit(articles, 'OwnershipTransferred').withArgs(deployer, alex)
        })
    })

    describe('test owner functions', function () {
        it('pause when not paused', async function() {   
            
            await expect(articles.pause({ from: deployer })).to.emit(articles, 'Paused').withArgs(deployer)

            expect(await articles.paused()).to.equal(true)       

            await expectRevert(articles.pause({ from: deployer }), 'Pausable: paused')

            await expectRevert(articles.pause({ from: alex }), 'Ownable: caller is not the owner')
        })
        it('renounce Ownership', async function() {

            await expectRevert(await articles.renounceOwnership({ from: alex }), 'Ownable: caller is not the owner')

            await expect(await articles.renounceOwnership({ from: deployer })).to.emit(articles, 'OwnershipTransferred')
            .withArgs(deployer, ZeroAddress)
            
            expect(await articles.owner()).to.equal(ZeroAddress)  
        })
        it('update URI if not paused', async function() {

            const pause = await articles.pause({ from: deployer })

            expect(await articles.paused()).to.equal(true)

            await expectRevert(await articles.updateURI('test uri', { from: deployer }), 'Pausable: paused')

            const unpause = await articles.unpause({ from: deployer })

            expect(await articles.paused()).to.equal(false)

            await expectRevert(await articles.updateURI('test uri', { from: alex }), 'Ownable: caller is not the owner')
        })

        it('reverts transfer to zero address', async function () {

            const failedTransfer = articles.transferOwnership(ZeroAddress, { from: deployer })
   
            await expectRevert(failedTransfer, 'Ownable: new owner is the zero address')

            await expect(failedTransfer).to.not.emit(articles, 'OwnershipTransferred')
        })

    })

    describe('mint function test', function () {
        let signer, provider, nonces

        before(async function () {
            signer = null
            provider = new ethers.JsonRpcProvider()
            chainId = (await provider.getNetwork()).chainId
            nonces = new ethers.NonceManager(signer)
        })

        it('mint premium with valid parameters', async function () {

            const messageHash = ethers.solidityPackedKeccak256(
                // signer, id, contract, _incrementNonce(_msgSender()), chainId
        
                ['address', 'uint', 'address', 'uint', 'uint'],
                []
            )
        })
       

        
        

        
    })
    

})


