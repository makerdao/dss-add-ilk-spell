pragma solidity ^0.5.4;

contract SpotterLike {
    function poke(bytes32) public;
}

contract MomLike {
    function execute(address, bytes memory) public;
}

contract DssAddIlkSpell {
    bool public done;
    bytes32 public ilk;
    address public vat;
    address public cat;
    address public jug;
    address public spotter;
    address public mom;
    address public momLib;
    address public adapter;
    address public mover;
    address public pip;
    address public flip;
    uint public line;
    uint public mat;
    uint public tax;
    uint public chop;
    uint public lump;

    uint constant ONE = 10 ^ 27;

    constructor(bytes32 ilk_, address[10] memory addrs, uint[5] memory values) public {
        ilk = ilk_;
        vat = addrs[0];
        cat = addrs[1];
        jug = addrs[2];
        spotter = addrs[3];
        mom = addrs[4];
        momLib = addrs[5];
        adapter = addrs[6];
        mover = addrs[7];
        pip = addrs[8];
        flip = addrs[9];
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
            abi.encodeWithSignature("file(address,bytes32,bytes32,uint256)", address(vat), ilk, bytes32("line"), line)
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
