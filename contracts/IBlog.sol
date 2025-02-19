// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;


interface IBlog  {

    event FeeUpdated(uint256 newFee);

    event FundsReceived(address indexed sender, uint256 value);

    event PremiumArticleMinted(uint256 indexed articleId, address indexed minter);

    event FundsWithdrawn(address indexed to, uint256 value);

    error InvalidSignature();

    error InsufficientFee(uint256 sent, uint256 required);

    error EmptyBalance();

    error WithdrawalFailed(string reason);

    error WithdrawalFailedNoData();

    error ContractNameChanged();

    
    /******************* Read Functions **********************************/

    function version() external pure returns(string memory);

    function contractName() external pure returns(string memory);

    function chainId() external view returns(uint256 id);

    function domainSeparator() external view returns(bytes32);

    function totalSupply(uint256 id) external view returns(uint256);

    function minted(uint256 id) external view returns(bool);

    function getPremiumFee() external view returns(uint256);

    function balance() external returns (uint256);

    /************************** Write Functions ************************************/

    function __Blog_init(string memory uri, uint256 premiumFee) external;

    function pause() external;

    function unpause() external;

    function updatePremiumFee(uint256 newFee) external;

    function mint(uint256 id, uint256 articleId, bytes calldata signature) external payable;

    function withdraw(address payable des) external;

    function updateURI(string memory newURI) external;
}