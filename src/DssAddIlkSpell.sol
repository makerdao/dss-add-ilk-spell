pragma solidity ^0.5.12;

contract SpotterLike {
    function poke(bytes32) public;
}

contract PauseLike {
    function delay() public returns (uint);
    function exec(address, bytes32, bytes memory, uint256) public;
    function plot(address, bytes32, bytes memory, uint256) public;
}

contract ConfigLike {
    function init(bytes32) public;
    function file(bytes32, bytes32, address) public;
    function file(bytes32, bytes32, uint) public;
    function rely(address) public;
}

contract IlkDeployer {
    function deploy(bytes32 ilk_, address[8] calldata addrs, uint[5] calldata values) external {
        // addrs[0] = vat
        // addrs[1] = cat
        // addrs[2] = jug
        // addrs[3] = spotter
        // addrs[4] = end
        // addrs[5] = join
        // addrs[6] = pip
        // addrs[7] = flip
        // values[0] = line
        // values[1] = mat
        // values[2] = duty
        // values[3] = chop
        // values[4] = lump

        ConfigLike(addrs[3]).file(ilk_, "pip", address(addrs[6])); // vat.file(ilk_, "pip", pip);

        ConfigLike(addrs[1]).file(ilk_, "flip", addrs[7]); // cat.file(ilk_, "flip", flip);
        ConfigLike(addrs[0]).init(ilk_); // vat.init(ilk_);
        ConfigLike(addrs[2]).init(ilk_); // jug.init(ilk_);

        ConfigLike(addrs[0]).rely(addrs[5]); // vat.rely(join);
        ConfigLike(addrs[7]).rely(addrs[1]); // flip.rely(cat);
        ConfigLike(addrs[7]).rely(addrs[4]); // flip.rely(end);

        ConfigLike(addrs[0]).file(ilk_, "line", values[0]); // vat.file(ilk_, "line", line);
        ConfigLike(addrs[1]).file(ilk_, "lump", values[4]); // cat.file(ilk_, "lump", lump);
        ConfigLike(addrs[1]).file(ilk_, "chop", values[3]); // cat.file(ilk_, "chop", chop);
        ConfigLike(addrs[2]).file(ilk_, "duty", values[2]); // jug.file(ilk_, "duty", duty);
        ConfigLike(addrs[3]).file(ilk_, "mat", values[1]); // spotter.file(ilk_, "mat", mat);

        SpotterLike(addrs[3]).poke(ilk_); // spotter.poke(ilk_);
    }
}

contract DssAddIlkSpell {
    bool      public done;
    address   public pause;

    address   public action;
    bytes32   public tag;
    uint256   public eta;
    bytes     public sig;

    constructor(bytes32 ilk_, address pause_, address[8] memory addrs, uint[5] memory values) public {
        pause = pause_;
        address ilkDeployer = address(new IlkDeployer());
        sig = abi.encodeWithSignature("deploy(bytes32,address[8],uint256[5])", ilk_, addrs, values);
        bytes32 _tag; assembly { _tag := extcodehash(ilkDeployer) }
        action = ilkDeployer;
        tag = _tag;
    }

    function schedule() external {
        require(eta == 0, "spell-already-scheduled");
        eta = now + PauseLike(pause).delay();
        PauseLike(pause).plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        PauseLike(pause).exec(action, tag, sig, eta);
    }
}
