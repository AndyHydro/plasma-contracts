pragma solidity 0.4.24;

import "./MixinRootChainCore.sol";
import "./MixinDeposit.sol";
import "./MixinTransactionChecker.sol";
import "./MixinBond.sol";
import "./MixinExit.sol";
import "./MixinChallenge.sol";
import "./MixinTokenReceiver.sol";
import "./MixinChildChain.sol";


/**
 * @dev Base contract that contains most of the root chain logic.
 */
contract RootChain is
    MixinRootChainCore,
    MixinDeposit,
    MixinTransactionChecker,
    MixinBond,
    MixinExit,
    MixinChallenge,
    MixinTokenReceiver,
    MixinChildChain
{
    constructor ()
        public
    {}
}
