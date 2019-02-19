pragma solidity ^0.5.4;

import "ds-test/test.sol";

import "./DssAddIlkSpell.sol";

contract DssAddIlkSpellTest is DSTest {
    DssAddIlkSpell spell;

    function setUp() public {
        spell = new DssAddIlkSpell();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
