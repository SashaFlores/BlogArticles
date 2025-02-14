// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;


import { ERC1155Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { Arrays } from "@openzeppelin/contracts/utils/Arrays.sol";


contract Blog is Initializable, Ownable2StepUpgradeable, ERC1155Upgradeable, PausableUpgradeable, UUPSUpgradeable { 
    using Arrays for uint256[];


    /// @custom:storage-location erc7201:sashaflores.storage.Blog
    struct BlogStorage {
        uint256 _nonce;
        uint256 _premiumFee;
        mapping(uint256 tokenId => uint256) _totalSupply;
    }


 
    uint256 public constant STANDARD_ID = 1;

    uint256 public constant PREMIUM_ID = 2;


    // keccak256(abi.encode(uint256(keccak256("sashaflores.storage.Blog")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant BlogStorageLocation = 0xd8bb604eb75c19d7b5da195a10139ccc9ca74bf453bffef10737af641b552500;

    // keccak256("EIP712Domain(uint256 chainId,address verifyingContract)")
    bytes32 private constant DOMAIN_SEPARATOR_TYPEHASH = 0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;

    // keccak256("mint(uint256 id,uint256 articleId)")
    bytes32 private constant MINT_TYPEHASH = 0x6100155005036ded4fd7339498494e937c20d6c938a8ec6b7110ebeb97e3721c;

    event FeeUpdated(uint256 newFee);

    event FundsReceived(address indexed sender, uint256 value);

    event PremiumArticleMinted(uint256 indexed articleId, address indexed minter);

    error InvalidSignature();

    error InsufficientFee(uint256 sent, uint256 required);


    function _getBlogStorage() private pure returns (BlogStorage storage $) {
        assembly {
            $.slot := BlogStorageLocation
        }
    }
    

    function __Blog_init(string memory uri, uint256 premiumFee) public virtual initializer {
        __ERC1155_init(uri);
        __Ownable_init(_msgSender());
        //__UUPSUpgradeable_init();
        __Pausable_init();    
        __Blog_init_unchained(premiumFee);
    }

    function __Blog_init_unchained(uint256 premiumFee) internal virtual onlyInitializing {
        _setPremiumFee(premiumFee);
    }

    receive() external payable {
        emit FundsReceived(_msgSender(), msg.value);
    }

    function pause() external virtual onlyOwner {  
        _pause();
    }


    function unpause() external virtual onlyOwner {
        _unpause();
    }


    function updatePremiumFee(uint256 newFee) external virtual onlyOwner {
        _setPremiumFee(newFee);
    }


    function chainId() public view virtual returns(uint256 id) {
        assembly {
            id := chainid()
        }
    }

    function domainSeparator() public view virtual returns(bytes32) {
        return keccak256(abi.encode(DOMAIN_SEPARATOR_TYPEHASH, chainId(), address(this)));
    }


    function totalSupply(uint256 id) public view virtual returns(uint256) {
        BlogStorage storage $ = _getBlogStorage();
        return $._totalSupply[id];
    }


    function minted(uint256 id) public view virtual returns(bool) {
        return totalSupply(id) > 0;
    }


    function getPremiumFee() public view virtual returns(uint256) {
        BlogStorage storage $ = _getBlogStorage();
        return $._premiumFee;
    }


    function mint(uint256 id, uint256 articleId, bytes calldata signature) public payable virtual{
        BlogStorage storage $ = _getBlogStorage();

        bytes32 digest = _hashMintFn(id, articleId, $._nonce);
        require(SignatureChecker.isValidSignatureNow(_msgSender(), digest, signature), InvalidSignature());

        if(id == PREMIUM_ID) {
            require(msg.value == getPremiumFee(), InsufficientFee(msg.value, $._premiumFee));

            emit PremiumArticleMinted(articleId, _msgSender());
        }

        _mint(_msgSender(), id, 1, "");
        $._nonce++;
    }


    function _hashMintFn(uint256 id, uint256 articleId, uint256 nonce) internal view virtual returns(bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(MINT_TYPEHASH, id, articleId, nonce)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns(bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator(), structHash));
    }


    function _setPremiumFee(uint256 newFee) internal virtual {
        BlogStorage storage $ = _getBlogStorage();
        $._premiumFee = newFee;

        emit FeeUpdated(newFee);
    }


    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual whenNotPaused override {
        BlogStorage storage $ = _getBlogStorage();
        super._update(from, to, ids, amounts);

        if(from == address(0)) {
            for(uint256 i = 0; i < ids.length; i ++) {
                uint256 amount = amounts.unsafeMemoryAccess(i);
                $._totalSupply[ids.unsafeMemoryAccess(i)] += amount;
            }
            
        }
    }


    function _authorizeUpgrade(address newImplementation) internal virtual override  onlyOwner {}

}