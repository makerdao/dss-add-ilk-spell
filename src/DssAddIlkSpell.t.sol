pragma solidity ^0.5.4;

import "ds-test/test.sol";

import "dss-deploy/DssDeploy.t.base.sol";

import "./DssAddIlkSpell.sol";

import {PipLike} from "dss-deploy/poke.sol";

contract DssAddIlkSpellTest is DssDeployTestBase {
    DssAddIlkSpell spell;

    bytes32 constant ilk = "NCT"; // New Collateral Type
    DSToken nct;
    GemJoin nctJoin;
    GemMove nctMove;
    Flipper nctFlip;
    DSValue nctPip;

    function setUp() public {
        super.setUp();
        deploy();

        nct = new DSToken(ilk);
        nct.mint(1 ether);
        nctJoin = new GemJoin(address(vat), ilk, address(nct));
        nctMove = new GemMove(address(vat), ilk);
        nctPip = new DSValue();
        nctPip.poke(bytes32(uint(300 ether)));
        nctFlip = flipFab.newFlip(address(daiMove), address(nctMove));

        spell = new DssAddIlkSpell(
            ilk,
            [
                address(vat),
                address(cat),
                address(jug),
                address(spotter),
                address(mom),
                address(momLib),
                address(nctJoin),
                address(nctMove),
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
        assertEq(vat.wards(address(nctMove)), 1);
    }

    function testFrob() public {
        assertEq(dai.balanceOf(address(this)), 0);
        nctJoin.join(bytes32(bytes20(address(this))), 1 ether);

        vat.frob(ilk, bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 1 ether, 100 ether);

        daiJoin.exit(bytes32(bytes20(address(this))), address(this), 100 ether);
        assertEq(dai.balanceOf(address(this)), 100 ether);
    }

    function testFlip() public {
        nctJoin.join(bytes32(bytes20(address(this))), 1 ether);
        vat.frob(ilk, bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 0.5 ether, 100 ether); // Maximun DAI generated
        nctPip.poke(bytes32(uint(300 ether - 1))); // Decrease price in 1 wei
        spotter.poke(ilk);
        uint nflip = cat.bite(ilk, bytes32(bytes20(address(this))));
        assertEq(vat.gem(ilk, bytes32(bytes20(address(nctFlip)))), 0);
        uint batchId = cat.flip(nflip, 100 ether);
        assertEq(vat.gem(ilk, bytes32(bytes20(address(nctFlip)))), 0.5 ether);

        address(user1).transfer(10 ether);
        user1.doEthJoin(weth, ethJoin, bytes32(bytes20(address(user1))), 10 ether);
        user1.doFrob(vat, "ETH", bytes32(bytes20(address(user1))), bytes32(bytes20(address(user1))), bytes32(bytes20(address(user1))), 10 ether, 1000 ether);

        address(user2).transfer(10 ether);
        user2.doEthJoin(weth, ethJoin, bytes32(bytes20(address(user2))), 10 ether);
        user2.doFrob(vat, "ETH", bytes32(bytes20(address(user2))), bytes32(bytes20(address(user2))), bytes32(bytes20(address(user2))), 10 ether, 1000 ether);

        user1.doHope(daiMove, address(nctFlip));
        user2.doHope(daiMove, address(nctFlip));

        user1.doTend(address(nctFlip), batchId, 0.5 ether, 50 ether);
        user2.doTend(address(nctFlip), batchId, 0.5 ether, 70 ether);
        user1.doTend(address(nctFlip), batchId, 0.5 ether, 90 ether);
        user2.doTend(address(nctFlip), batchId, 0.5 ether, 100 ether);

        user1.doDent(address(nctFlip), batchId, 0.4 ether, 100 ether);
        user2.doDent(address(nctFlip), batchId, 0.35 ether, 100 ether);
        hevm.warp(nctFlip.ttl() - 1);
        user1.doDent(address(nctFlip), batchId, 0.3 ether, 100 ether);
        hevm.warp(now + nctFlip.ttl() + 1);
        user1.doDeal(address(nctFlip), batchId);
    }
}
