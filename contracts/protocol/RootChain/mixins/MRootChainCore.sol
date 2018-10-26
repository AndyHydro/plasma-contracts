pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "../../../libraries/SafeMath/SafeMath64.sol";
import "../../../libraries/Transaction/Transaction.sol";
import "../../../libraries/ECVerify.sol";
import "../../../libraries/ChallengeLib.sol";

import "../libs/LibChildChain.sol";

// SMT
import "../libs/LibSparseMerkleTree.sol";


contract MRootChainCore {
    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using Transaction for bytes;
    using ECVerify for bytes32;
    using ChallengeLib for ChallengeLib.Challenge[];

    // SMT
    LibSparseMerkleTree smt;

    // Block number
    uint256 public currentBlock = 0;

    // Tracking of coins deposited in each slot
    uint64 public numCoins = 0;
    mapping (uint64 => LibChildChain.Coin) public coins;
    mapping (uint64 => LibChildChain.Exit) public exits;

    // Mapping of block number to block struct
    mapping(uint256 => LibChildChain.ChildBlock) public childChain;

    uint256 constant BOND_AMOUNT = 0.1 ether;
    // An exit can be finalized after it has matured,
    // after T2 = T0 + MATURITY_PERIOD
    // An exit can be challenged in the first window
    // between T0 and T1 ( T1 = T0 + CHALLENGE_WINDOW)
    // A challenge can be responded to in the second window
    // between T1 and T2
    uint256 constant MATURITY_PERIOD = 7 days;

    // solium-disable-next-line zeppelin/no-arithmetic-operations
    uint256 constant CHALLENGE_WINDOW = 3 days + 12 hours;

    mapping (address => LibChildChain.Balance) public balances;

    // exits
    uint64[] public exitSlots;

    // challenges
    mapping (uint64 => ChallengeLib.Challenge[]) challenges;

    // child chain
    uint256 public childBlockInterval = 1000;

    // Used in startExit and challengeBefore
    modifier isBonded() {
        revert("Transaction is not bonded");
        _;
    }

    // startExit, withdraw, challengeBefore, challengeBetween, challengeAfter
    modifier isState(
        uint64 slot,
        LibChildChain.State state
    ) {
        revert("Slot is not in correct state");
        _;
    }

    // challengeBetween, challengeAfter
    modifier cleanupExit(uint64 slot) {
        revert("Unable to cleanup exit");
        _;
    }

    function checkMembership(
        bytes32 txHash,
        bytes32 root,
        uint64 slot,
        bytes proof
    )
        public
        view
        returns (bool);
}
