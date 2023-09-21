const { expect } = require('chai')
const { ethers, run } = require('hardhat')


const developmentChains = ['hardhat', 'localDev']

const ZeroAddress = ethers.ZeroAddress

const verify = async (contractAddress, args) => {
    console.log('Verifying contract...')
    try {
        await run('verify:verify', {
            address: contractAddress,
            constructorArguments: args,     // replace wih real arguments
        })
    } catch (e) {
        if (e.message.toLowerCase().includes('already verified')) {
            console.log('Already verified!')
        } else {
            console.log(e)
        }
    }
}

async function expectRevert(promise, expectedErrorMessage) {
    try {
        await promise;
        throw new Error('Expected revert not received');
    } catch (error) {
        // Check if the error message matches the expected error message.
        if (error.message.includes(expectedErrorMessage)) {
            // Revert as expected
            return; 
        }
        // Revert message doesn't match the expectation
        throw error; 
    }
}


async function expectRevertWithCustomError(promise, expectedErrorName, ...expectedErrorArgs) {
    try {
        await promise;
        expect.fail('Expected custom revert not received');
    } catch (error) {
        if (expectedErrorName) {
            // Check if the error message includes the expected error name
            expect(error.message).to.include(expectedErrorName);

            if (expectedErrorArgs.length > 0) {
                // Check for custom error arguments if provided
                for (const arg of expectedErrorArgs) {
                    if (Array.isArray(arg)) {
                        // Handle array arguments
                        for (const item of arg) {
                            expect(error.message).to.include(item.toString());
                        }
                    } else {
                        // Handle single arguments
                        expect(error.message).to.include(arg.toString());
                    }
                }
            }
        } else {
            expect.fail('Revert error not handled');
        }
    }
}



module.exports = { developmentChains, ZeroAddress, verify, expectRevert, expectRevertWithCustomError }
