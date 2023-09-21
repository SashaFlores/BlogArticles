# ArticlesProxy

*taken from OZ with a small change that inherit from ERC1967UpgradeUpgradeable instead of ERC1967Upgrade to enable upgradeability and adding `implementation` function.*

> ArticlesProxy



*Implementation address is stored in a predefined location in storage to avoid collision  with storage layout of impl. behind proxy as per https://eips.ethereum.org/EIPS/eip-1967 Storage slot 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc  (obtained as bytes32(uint256(keccak256(&#39;eip1967.proxy.implementation&#39;)) - 1)). and emits Upgraded event.*

## Methods

### implementation

```solidity
function implementation() external view returns (address impl)
```



*Returns the current implementation address.*


#### Returns

| Name | Type | Description |
|---|---|---|
| impl | address | undefined |



## Events

### AdminChanged

```solidity
event AdminChanged(address previousAdmin, address newAdmin)
```



*Emitted when the admin account has changed.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| previousAdmin  | address | undefined |
| newAdmin  | address | undefined |

### BeaconUpgraded

```solidity
event BeaconUpgraded(address indexed beacon)
```



*Emitted when the beacon is changed.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| beacon `indexed` | address | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```



*Triggered when the contract has been initialized or reinitialized.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### Upgraded

```solidity
event Upgraded(address indexed implementation)
```



*Emitted when the implementation is upgraded.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| implementation `indexed` | address | undefined |



