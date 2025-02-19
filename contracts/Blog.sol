// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IBlog } from "./IBlog.sol";
import { ERC1155Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import { Initializable, UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { Arrays } from "@openzeppelin/contracts/utils/Arrays.sol";


contract Blog is IBlog, Initializable, Ownable2StepUpgradeable, ERC1155Upgradeable, PausableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable { 
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

    

    function _getBlogStorage() private pure returns (BlogStorage storage $) {
        assembly {
            $.slot := BlogStorageLocation
        }
    }
    

    function __Blog_init(string memory uri_, uint256 premiumFee) public virtual initializer {
        __ERC1155_init(uri_);
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __Pausable_init();    
        __ReentrancyGuard_init();
        __Blog_init_unchained(premiumFee);
    }

    function __Blog_init_unchained(uint256 premiumFee) internal virtual onlyInitializing {
        _setPremiumFee(premiumFee);
    }

    function version() public pure virtual returns(string memory) {
        return "1.0.0";
    }

    function contractName() public pure virtual returns(string memory) {
        return "Blog";
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Upgradeable) returns (bool) {
        return 
            interfaceId == type(IBlog).interfaceId || 
            super.supportsInterface(interfaceId);
    }

    function uri(uint256 id) public view virtual override returns (string memory) {
        return string(abi.encodePacked(super.uri(id), Strings.toString(id), '.json'));
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

    function updateURI(string memory newURI) external virtual onlyOwner {
        _setURI(newURI);
    }

    function withdraw(address payable des) external virtual onlyOwner nonReentrant {
        if(balance() == 0) revert EmptyBalance();

        (bool success, bytes memory why) = des.call{value: balance()}("");
        if(!success) {
            if(why.length > 0) {
                revert WithdrawalFailed(abi.decode(why, (string)));
            } else {
                revert WithdrawalFailedNoData();
            }
        }

        emit FundsWithdrawn(des, balance());
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

    function balance() public virtual override returns (uint256) {
        return address(this).balance;
    }


    function mint(uint256 id, uint256 articleId, bytes calldata signature) public payable virtual nonReentrant {
        BlogStorage storage $ = _getBlogStorage();

        bytes32 digest = _hashMintFn(id, articleId, $._nonce);
        if(!SignatureChecker.isValidSignatureNow(_msgSender(), digest, signature)) revert InvalidSignature();
       

        if(id == PREMIUM_ID) {
            require(msg.value == getPremiumFee(), InsufficientFee(msg.value, getPremiumFee()));

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

    function _authorizeUpgrade(address newImplementation) internal virtual override  onlyOwner {
        require(stringsEqual(IBlog(newImplementation).contractName(), this.contractName()), ContractNameChanged());
    }

    function stringsEqual(string memory a, string memory b) private pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

}