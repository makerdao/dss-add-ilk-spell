pragma solidity ^0.5.4;

import "ds-test/test.sol";

import "dss-deploy/DssDeploy.t.base.sol";

import "./DssAddIlkSpell.sol";

import {PipLike} from "dss/spot.sol";

contract DssAddIlkSpellTest is DssDeployTestBase {
    DssAddIlkSpell spell;

    bytes32 constant ilk = "NCT"; // New Collateral Type
    DSToken nct;
    GemJoin nctJoin;
    Flipper nctFlip;
    DSValue nctPip;

    function setUp() public {
        super.setUp();
        deploy();

        nct = new DSToken(ilk);
        nct.mint(1 ether);
        nctJoin = new GemJoin(address(vat), ilk, address(nct));
        nctPip = new DSValue();
        nctPip.poke(bytes32(uint(300 ether)));
        nctFlip = flipFab.newFlip(address(vat), ilk);
        nctFlip.rely(address(pause.proxy()));
        nctFlip.deny(address(this));

        spell = new DssAddIlkSpell(
            ilk,
            address(pause),
            [
                address(vat),
                address(cat),
                address(jug),
                address(spotter),
                address(end),
                address(nctJoin),
                address(nctPip),
                address(nctFlip)
            ],
            [
                10000 * 10 ** 45, // line
                1500000000 ether, // mat
                1.05 * 10 ** 27, // tax
                ONE, // chop
                10000 ether // lump
            ]
        );

        authority.setRootUser(address(spell), true);

        spell.schedule();
        spell.cast();

        nct.approve(address(nctJoin), 1 ether);
    }

    function testVariables() public {
        (,,,uint line,) = vat.ilks(ilk);
        assertEq(line, uint(10000 * 10 ** 45));
        (PipLike pip, uint mat) = spotter.ilks(ilk);
        assertEq(address(pip), address(nctPip));
        assertEq(mat, uint(1500000000 ether));
        (uint tax,) = jug.ilks(ilk);
        assertEq(tax, uint(1.05 * 10 ** 27));
        (address flip, uint chop, uint lump) = cat.ilks(ilk);
        assertEq(flip, address(nctFlip));
        assertEq(chop, ONE);
        assertEq(lump, uint(10000 ether));
        assertEq(vat.wards(address(nctJoin)), 1);
    }

    function testFrob() public {
        assertEq(dai.balanceOf(address(this)), 0);
        nctJoin.join(address(this), 1 ether);

        vat.frob(ilk, address(this), address(this), address(this), 1 ether, 100 ether);

        vat.hope(address(daiJoin));
        daiJoin.exit(address(this), 100 ether);
        assertEq(dai.balanceOf(address(this)), 100 ether);
    }

    function testFlip() public {
        this.file(address(cat), ilk, "lump", 1 ether); // 1 unit of collateral per batch
        this.file(address(cat), ilk, "chop", ONE);
        nctJoin.join(address(this), 1 ether);
        vat.frob(ilk, address(this), address(this), address(this), 1 ether, 200 ether); // Maximun DAI generated
        nctPip.poke(bytes32(uint(300 ether - 1))); // Decrease price in 1 wei
        spotter.poke(ilk);
        assertEq(vat.gem(ilk, address(nctFlip)), 0);
        uint batchId = cat.bite(ilk, address(this));
        assertEq(vat.gem(ilk, address(nctFlip)), 1 ether);

        address(user1).transfer(10 ether);
        user1.doEthJoin(address(weth), address(ethJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "ETH", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        address(user2).transfer(10 ether);
        user2.doEthJoin(address(weth), address(ethJoin), address(user2), 10 ether);
        user2.doFrob(address(vat), "ETH", address(user2), address(user2), address(user2), 10 ether, 1000 ether);

        user1.doHope(address(vat), address(nctFlip));
        user2.doHope(address(vat), address(nctFlip));

         user1.doTend(address(nctFlip), batchId, 1 ether, rad(100 ether));
        user2.doTend(address(nctFlip), batchId, 1 ether, rad(140 ether));
        user1.doTend(address(nctFlip), batchId, 1 ether, rad(180 ether));
        user2.doTend(address(nctFlip), batchId, 1 ether, rad(200 ether));

        user1.doDent(address(nctFlip), batchId, 0.8 ether, rad(200 ether));
        user2.doDent(address(nctFlip), batchId, 0.7 ether, rad(200 ether));
        hevm.warp(nctFlip.ttl() - 1);
        user1.doDent(address(nctFlip), batchId, 0.6 ether, rad(200 ether));
        hevm.warp(now + nctFlip.ttl() + 1);
        user1.doDeal(address(nctFlip), batchId);
    }
}
