const { ethers, deployments, getNamedAccounts, getUnnamedAccounts } = require('hardhat')
const { expect } = require('chai')
const { ZeroAddress, expectRevert, expectRevertWithCustomError } = require('../helpers')



describe('Articles Testing', function() {

    let deployer, articles, minters

    beforeEach(async function() {

        await deployments.fixture('articles')
        deployer = (await getNamedAccounts()).deployer
        minters = await getUnnamedAccounts()
        articles = await ethers.getContract('Articles')
    })

    describe('init function initiated properly', function(){
        it('initialize function not invoked twice', async function() {
            await expectRevert(articles.__Articles_init('test uri'), 'Initializable: contract is already initialized')
        })
        it('owner is the deployer', async function() {
            expect(await articles.owner()).to.equal(deployer)
        })
        // it('emits transfer ownership event', async function() {
        //     const init = articles.__Articles_init('sasha.com/{id}.js')
        //     expect(await init).to.emit(articles, 'OwnershipTransferred').withArgs(ZeroAddress, deployer)
        // })
        // it('emits initialized event', async function() {
        //     expect(articles.__Articles_init('sasha.com/{id}.js')).to.emit(articles, 'Initialized').withArgs(1)
        // })
        it('pause is false', async function() {
            expect(await articles.paused()).to.equal(false)
        })
        it('no tokens are listed yet', async function() {
            const availIds = await articles.getAvailIds()
            expect(availIds.length).to.equal(0)
        })

    })

    describe('list function test', function() {
    
        beforeEach(async function() {
            await articles.listTokens([1,2, 3], { from: deployer})
        })
        it('tokens are listed', async function() {
            const listed = await articles.getAvailIds()
            expect(listed.length).to.equal(3)
            expect(listed).to.deep.equal([1, 2, 3])
        })
        it('emits new tokens listed event', async function() {
            expect(articles.listTokens([1,2,3])).to.emit(articles, 'NewTokenListed').withArgs([1, 2, 3])
        })
        it('reject relisting ids and zero id', async function() {
            await expectRevertWithCustomError(articles.listTokens([1]), 'ListedOrZero', 1)
            await expectRevertWithCustomError(articles.listTokens([0]), 'ListedOrZero', 0)
        })        
    })

    describe('owner functions test', function() {
        it('only owner can transfer ownership', async function() {
            await expect(articles.transferOwnership(minters[0], { from: deployer })).to.emit(articles, 'OwnershipTransferred').withArgs(deployer, minters[0])

            expect(await articles.owner()).to.equal(minters[0])     

            await expectRevert(articles.transferOwnership(ZeroAddress), 'Ownable: new owner is the zero address')
            
            await expect(articles.transferOwnership(ZeroAddress)).to.not.emit(articles, 'OwnershipTransferred')
        })
        it('only owner can renounce Ownership', async function() {
            await expect(articles.renounceOwnership()).to.emit(articles, 'OwnershipTransferred').withArgs(deployer, ZeroAddress)
            
            expect(await articles.owner()).to.equal(ZeroAddress)  
        })
        it('only owner can pause when not paused', async function() {
            expect(await articles.paused()).to.equal(false)       
            
            await expect(articles.pause()).to.emit(articles, 'Paused').withArgs(deployer)

            expect(await articles.paused()).to.equal(true)       
        })
    })
    

})


