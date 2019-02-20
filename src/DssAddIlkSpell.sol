pragma solidity ^0.5.4;

contract SpotterLike {
    function poke(bytes32) public;
}

contract MomLike {
    function execute(address, bytes memory) public;
}

contract DssAddIlkSpell {
    bool done;
    bytes32 ilk;
    address vat;
    address pit;
    address cat;
    address jug;
    address spotter;
    address mom;
    address momLib;
    address adapter;
    address mover;
    address pip;
    address flip;
    uint line;
    uint mat;
    uint tax;
    uint lump;
    uint chop;

    uint constant ONE = 10 ^ 27;

    constructor(bytes32 ilk_, address[11] memory addrs, uint[5] memory values) public {
        ilk = ilk_;
        vat = addrs[0];
        pit = addrs[1];
        cat = addrs[2];
        jug = addrs[3];
        spotter = addrs[4];
        mom = addrs[5];
        momLib = addrs[6];
        adapter = addrs[7];
        mover = addrs[8];
        pip = addrs[9];
        flip = addrs[10];
        line = values[0];
        mat = values[1];
        tax = values[2];
        chop = values[3];
        lump = values[4];
    }

    function momExecute(bytes memory data) internal {
        MomLike(mom).execute(
            momLib,
            data
        );
    }

    function cast() public {
        require(!done, "already-deployed");

        momExecute(
            abi.encodeWithSignature("init(address,bytes32)", address(vat), bytes32(ilk))
        );

        momExecute(
            abi.encodeWithSignature("file(address,bytes32,bytes32,uint256)", address(pit), ilk, bytes32("line"), line)
        );

        momExecute(
            abi.encodeWithSignature("file(address,bytes32,address)", address(spotter), ilk, address(pip))
        );
        momExecute(
            abi.encodeWithSignature("file(address,bytes32,bytes32,uint256)", address(spotter), ilk, bytes32("mat"), mat)
        );
        SpotterLike(spotter).poke(ilk);

        momExecute(
            abi.encodeWithSignature("file(address,bytes32,bytes32,address)", address(cat), ilk, bytes32("flip"), address(flip))
        );
        momExecute(
            abi.encodeWithSignature("file(address,bytes32,bytes32,uint256)", address(cat), ilk, bytes32("lump"), lump)
        );
        momExecute(
            abi.encodeWithSignature("file(address,bytes32,bytes32,uint256)", address(cat), ilk, bytes32("chop"), chop)
        );

        momExecute(
            abi.encodeWithSignature("init(address,bytes32)", address(jug), bytes32(ilk))
        );
        momExecute(
            abi.encodeWithSignature("file(address,bytes32,bytes32,uint256)", address(jug), ilk, bytes32("tax"), tax)
        );

        // Internal auth
        momExecute(
            abi.encodeWithSignature("rely(address,address)", address(vat), address(adapter))
        );
        momExecute(
            abi.encodeWithSignature("rely(address,address)", address(vat), address(mover))
        );

        done = true;
    }
}
