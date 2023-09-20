//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Initializable } from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import { OwnableUpgradeable } from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import { ERC1155Upgradeable } from '@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol';
import { PausableUpgradeable } from '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import { UUPSUpgradeable } from '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import { StringsUpgradeable } from '@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol';
import { ECDSAUpgradeable } from '@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol';
import { CountersUpgradeable } from '@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol';


contract Articles is Initializable, OwnableUpgradeable, ERC1155Upgradeable, UUPSUpgradeable, PausableUpgradeable {

    using CountersUpgradeable for CountersUpgradeable.Counter;

    
    string private constant NAME = 'Chainer'; 

    string private constant SYMBOL = 'CHR';

    mapping(uint256 => uint256) private _supply;
    mapping(address => CountersUpgradeable.Counter) private _nonces;

    uint256[] private _availTokens;

    event NewTokenListed(uint256[] ids);

    error ListedOrZero(uint256 id);

    error MintedOrOutofBond(uint256 id);

    error NonExistId(uint256 id);

    
    // solhint-disable-next-line func-name-mixedcase, func-param-name-mixedcase, var-name-mixedcase 
    function __Articles_init(string memory URI) public virtual initializer {
        __Ownable_init();
        __ERC1155_init(URI);
        __UUPSUpgradeable_init();
        __Pausable_init();
    }

    function pause() external virtual onlyOwner {
        _pause();
    }

    function unpause() external virtual onlyOwner {
        _unpause();
    }

    function updateURI(string memory newURI) external virtual onlyOwner whenNotPaused {
        _setURI(newURI);
    }

    function getAvailIds() external view virtual returns(uint256[] memory) {
        return _availTokens;
    }

    function getImplementation() external view virtual returns(address) {
        return _getImplementation();
    }

    function listTokens(uint256[] calldata ids) public virtual onlyOwner whenNotPaused {
        for (uint256 i = 0; i < ids.length; i++) {
            if(ids[i] == 0 || isListed(ids[i])) {
                revert ListedOrZero(ids[i]);
            }
            _availTokens.push(ids[i]);
        }
        emit NewTokenListed(ids);
    }

    function mint(uint256 id, bytes calldata signature) public payable virtual {
        require(_verifySignature(id, signature), 'invalid signature');

        if(id >= _availTokens.length || balanceOf(_msgSender(), id) != 0) {
            revert MintedOrOutofBond(id);
        }

        _mint(_msgSender(), id, 1, '');
    }

    function uri(uint256 id) public view virtual override returns (string memory) {
        if(!isListed(id)) {
            revert NonExistId(id);
        }
        return string(abi.encodePacked(super.uri(id), StringsUpgradeable.toString(id), '.json'));
    }

    function totalSupply(uint256 id) public view virtual returns(uint256) {
        return _supply[id];

    }

    function isListed(uint256 id) public view virtual returns (bool) {
        for (uint256 i = 0; i < _availTokens.length; i++) {
            if (_availTokens[i] == id) {
                return true;
            }
        }
        return false;
    }

    function isMinted(uint256 id) public view virtual returns (bool) {
        return Articles.totalSupply(id) > 0;
    }

    
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {
        _requirePaused();
    }

    function _beforeTokenTransfer (
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override{
        _requireNotPaused();

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _supply[ids[i]] += amounts[i];
            }
        } 
        if(to == address(0)) {
            revert();
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _verifySignature(uint256 id, bytes memory signature) private returns (bool) {

        bytes32 hash = keccak256(abi.encodePacked(_msgSender(), id, address(this), _incrementNonce(_msgSender()), block.chainid));
        bytes32 ethSignedMessage = ECDSAUpgradeable.toEthSignedMessageHash(hash);
        address signer = ECDSAUpgradeable.recover(ethSignedMessage, signature);
        return signer == _msgSender();
    }

     function _incrementNonce(address signer) private returns(uint256 current) {
        CountersUpgradeable.Counter storage nonce = _nonces[signer];
        current = nonce.current();
        nonce.increment();
    }

}