// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;

import { Proxy } from '@openzeppelin/contracts/proxy/Proxy.sol';
import { ERC1967UpgradeUpgradeable } from '@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol';

/**
 * @title ArticlesProxy
 * @author taken from OZ with a small change that inherit from ERC1967UpgradeUpgradeable
 * instead of ERC1967Upgrade to enable upgradeability and adding `implementation` function.
 * @dev Implementation address is stored in a predefined location in storage to avoid collision 
 * with storage layout of impl. behind proxy as per https://eips.ethereum.org/EIPS/eip-1967
 * Storage slot 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc 
 * (obtained as bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)).
 * and emits Upgraded event.
 */

contract ArticlesProxy is Proxy, ERC1967UpgradeUpgradeable {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        /**
         * https://docs.soliditylang.org/en/latest/control-structures.html#error-handling-assert-require-revert-and-exceptions
         * assert: Panic exception code 0x22: If you access a storage byte array that is incorrectly encoded.
         * 
         * see ERC1976Upgradeable
         * keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
         */
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function implementation() public view returns(address impl) {
        return _implementation();
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967UpgradeUpgradeable._getImplementation();
    }
}
