# Dss Add Ilk Spell

Spell contract to deploy a new collateral type in the DSS system.

## Additional Documentation

- `dss-deploy` [source code](https://github.com/makerdao/dss-deploy)
- `dss` [source code](https://github.com/makerdao/dss)

## Deployment

### Prerequisites:

- seth/dapp (https://dapp.tools/)
- Have a DSS instance running

### Steps:

1) Export contract variables

- `export TOKEN=<TOKEN ADDR>`
- `export PIP=<TOKEN/USD FEED ADDR>`
- `export ILK="$(seth --to-bytes32 "$(seth --from-ascii "<COLLATERAL NAME>")")"`
- `export MCD_VAT=<VAT ADDR>`
- `export MCD_CAT=<CAT ADDR>`
- `export MCD_JUG=<JUG ADDR>`
- `export MCD_SPOT=<SPOTTER ADDR>`
- `export MCD_MOM=<MOM ADDR>`
- `export MCD_MOM_LIB=<MOM LIB ADDR>`
- `export MCD_MOVE_DAI=<DAI MOVE ADDR>`
- `export MCD_ADM=<CHIEF ADDR>`

2) Deploy Adapter (e.g. [GemJoin](https://github.com/makerdao/dss/blob/master/src/join.sol#L35))

- `export JOIN=$(dapp create GemJoin $MCD_VAT $ILK $TOKEN)`

3) Deploy Move (e.g. [GemMove](https://github.com/makerdao/dss/blob/master/src/move.sol#L25))

- `export MOVE=$(dapp create GemMove $MCD_VAT $ILK)`

4) Deploy Flip Auction (e.g. [Flipper](https://github.com/makerdao/dss/blob/master/src/flip.sol#L44))

- `export FLIP=$(dapp create Flipper $MCD_MOVE_DAI $MOVE)`

5) Export New Collateral Types variables
- `export LINE=<DEBT CEILING VALUE>` (e.g. 5M DAI `"$(seth --to-uint256 "$(seth --to-wei 5000000 ETH)")"`)
- `export MAT=<LIQUIDATION RATIO VALUE>` (e.g. 150% `"$(seth --to-uint256 "$(seth --to-wei 1500000000 ETH)")"`)
- `export TAX=<STABILITY FEE VALUE>` (e.g. 1% yearly `"$(seth --to-uint256 1000000000315522921573372069)"`)
- `export CHOP=<LIQUIDATION PENALTY VALUE>` (e.g. 10% `"$(seth --to-uint256 "$(seth --to-wei 1100000000 ETH)")"`)
- `export LUMP=<LIQUIDATION QUANTITY VALUE>` (e.g. 1K DAI `"$(seth --to-uint256 "$(seth --to-wei 1000 ETH)")"`)

6) Deploy Spell

- `export SPELL=$(seth send --create out/DssAddIlkSpell.bin 'DssAddIlkSpell(bytes32,address[11] memory,uint256[5] memory)' $ILK ["${MCD_VAT#0x}","${MCD_CAT#0x}","${MCD_JUG#0x}","${MCD_SPOT#0x}","${MCD_MOM#0x}","${MCD_MOM_LIB#0x}","${JOIN#0x}","${MOVE#0x}","${PIP#0x}","${FLIP#0x}"] ["$LINE","$MAT","$TAX","$CHOP","$LUMP"])`

7) Create slate

- `seth send $MCD_ADM 'etch(address[] memory)' ["${SPELL#0x}"]'`

8) Wait for the Spell to be elected

9) Cast Spell

- `seth send $SPELL 'cast()'`
