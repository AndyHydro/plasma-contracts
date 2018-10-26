pragma solidity 0.4.24;

import "./libs/LibChildChain.sol";
import "./libs/LibSparseMerkleTree.sol";
import "./mixins/MRootChainCore.sol";
import "./mixins/MExit.sol";


/**
 * @dev Core functions that are needed throughout the contract, many utility functions
 *      around slots, and accessing global datastructures
 */
contract MixinRootChainCore is
    LibChildChain,
    MRootChainCore,
    MExit
{
    // Used in startExit and challengeBefore
    modifier isBonded() {
        require(
            msg.value == BOND_AMOUNT,
            "Transaction does not have the correct bond amount"
        );

        // Save challenger's bond
        balances[msg.sender].bonded = balances[msg.sender].bonded.add(msg.value);
        _;
    }

    // startExit, withdraw, challengeBefore, challengeBetween, challengeAfter
    modifier isState(
        uint64 slot,
        State state
    ) {
        require(
            coins[slot].state == state,
            "Wrong state"
        );
        _;
    }

    // challengeBetween, challengeAfter
    modifier cleanupExit(uint64 slot) {
        _; //solium-disable-line security/enforce-placeholder-last
        delete exits[slot];
        delete exitSlots[getExitIndex(slot)];
    }

    constructor ()
        public
    {
        smt = new LibSparseMerkleTree();
    }

    /**
     * @dev Returns the full coin information for a given slot
     * @param slot Slot for the coin trying to be retrieved
     * @return The full coin object including, uid, depsoit block, denomination
     *         owner, state, mode, and contract address
     */
    function getPlasmaCoin(uint64 slot)
        external
        view
        returns (uint256, uint256, uint256, address, State, Mode, address)
    {
        Coin storage c = coins[slot];
        return (
            c.uid,
            c.depositBlock,
            c.denomination,
            c.owner,
            c.state,
            c.mode,
            c.contractAddress
        );
    }

    /**
     * @dev Returns the exit object for a specified slot. Available for anybody
     *      to query the root contract when challenging slots.
     * @param slot Slot for the coin that is being exited
     * @return The full exit object including owner, previous block, exit block
     *         and state.
     */
    function getExit(uint64 slot)
        external
        view
        returns (address, uint256, uint256, State)
    {
        Exit storage e = exits[slot];
        return (e.owner, e.prevBlock, e.exitBlock, coins[slot].state);
    }

    /**
     * @dev Returns the block root for a specified block number
     * @param blockNumber The block number for which which the root is requested
     * @return The bytes of the merkle root
     */
    function getBlockRoot(uint256 blockNumber)
        public
        view
        returns (bytes32)
    {
        return childChain[blockNumber].root;
    }

    /**
     * @dev Checks if a transaction has is part of a merkle root.
     * @param txHash Transaction hash to check membership against
     * @param root Merkle root for the block to check against
     * @param slot Slot for the coin
     * @param proof Bytes used to prove transaction presence in root
     * @return Boolean about whether or not the transaction and proof was part of the root
     *         provided
     */
    function checkMembership(
        bytes32 txHash,
        bytes32 root,
        uint64 slot,
        bytes proof
    )
        public
        view
        returns (bool)
    {
        return smt.checkMembership(
            txHash,
            root,
            slot,
            proof
        );
    }
}
