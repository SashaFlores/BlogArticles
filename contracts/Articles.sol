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



    uint256 private constant STANDARD = 1;

    uint256 private constant PREMIUM =  2;

    mapping(uint256 => uint256) private _supply;

    mapping(address => CountersUpgradeable.Counter) private _nonces;

    event FundsReceived(address from, uint256 amount, address to);

    error InvalidSignature();

    error NonExistId(uint256 id);

    error Shame2Burn();



    // solhint-disable-next-line func-name-mixedcase, func-param-name-mixedcase, var-name-mixedcase 
    function __Articles_init(string memory URI) public virtual initializer {
        __Ownable_init();
        __ERC1155_init(URI);
        __UUPSUpgradeable_init();
        __Pausable_init();
    }

    receive() external payable {
        _transferFunds();
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

    function name() external pure virtual returns(string memory) {
        return 'CHAINER';
    }

    function symbol() external pure virtual returns(string memory) {
        return 'CHNR';
    }

    function mint(uint256 id, bytes calldata signature) public payable virtual whenNotPaused {

        if(!_verifySignature(id, signature)) {
            revert InvalidSignature();
        }
      
        if(id == 2) {
            require(msg.value >= 3200000 gwei, 'Premium fee required');
        } else if(id == 1) {
            require(msg.value >= 1000000 gwei, 'Standard fee required');
        } else {
            revert NonExistId(id);
        }
        _transferFunds();

        _mint(_msgSender(), id, 1, '');        
    }

    function uri(uint256 id) public view virtual override returns (string memory) {
        return string(abi.encodePacked(super.uri(id), StringsUpgradeable.toString(id), '.json'));
    }


    function totalSupply(uint256 id) public view returns(uint256){
        return _supply[id];
    }
    
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner whenPaused{}

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
            revert Shame2Burn();
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

    function _transferFunds() private {
        (bool success, ) = payable(owner()).call{value: msg.value}("");
        require(success, 'transfer failed');
       emit FundsReceived(_msgSender(), msg.value, owner());
    }

}