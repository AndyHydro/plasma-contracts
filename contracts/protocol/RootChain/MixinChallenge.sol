pragma solidity 0.4.24;

import "./libs/LibChildChain.sol";

import "./mixins/MRootChainCore.sol";
import "./mixins/MTransactionChecker.sol";
import "./mixins/MBond.sol";
import "./mixins/MChallenge.sol";


/**
 * @dev Contains all logic for the different types of challenges. Everything
 *      from challenging double spends, to invalid history, to spent exits.
 */
contract MixinChallenge is
    LibChildChain,
    MRootChainCore,
    MTransactionChecker,
    MBond,
    MChallenge
{
   /**
    * @dev Submits proof of a transaction before prevTx as an exit challenge.
    *      Also makes sure that the user submitting the challenge has bonded
    *      funds, and the exit is in an EXITING state.
    * @notice Exitor has to call respondChallengeBefore and submit a
    *         transaction before prevTx or prevTx itself.
    * @param slot The slot corresponding to the coin whose exit is being challenged
    * @param prevTxBytes The RLP-encoded transaction involving a particular
    *        coin which took place directly before exitingTxBytes
    * @param txBytes The RLP-encoded transaction involving a particular
    *        coin which an exiting owner of the coin claims to be the latest
    * @param prevTxInclusionProof An inclusion proof of prevTx
    * @param txInclusionProof An inclusion proof of exitingTx
    * @param signature The signature of the txBytes by the coin
    *        owner indicated in prevTx
    * @param blocks An array of two block numbers, at index 0, the block
    *        containing the prevTx and at index 1, the block containing
    *        the exitingTx
    */
    function challengeBefore(
        uint64 slot,
        bytes prevTxBytes,
        bytes txBytes,
        bytes prevTxInclusionProof,
        bytes txInclusionProof,
        bytes signature,
        uint256[2] blocks
    )
        external
        payable
        isBonded
        isState(slot, State.EXITING)
    {
        doInclusionChecks(
            prevTxBytes,
            txBytes,
            prevTxInclusionProof,
            txInclusionProof,
            signature,
            blocks
        );

        setChallenged(
            slot,
            txBytes.getOwner(),
            blocks[1],
            txBytes.getHash()
        );
    }

   /**
    * @dev Submits proof of a later transaction that corresponds to a challenge
    * @notice Can only be called in the second window of the exit period.
    * @param slot The slot corresponding to the coin whose exit is being challenged
    * @param challengingTxHash The hash of the transaction
    *        corresponding to the challenge we're responding to
    * @param respondingBlockNumber The block number which included the transaction
    *        we are responding with
    * @param respondingTransaction The RLP-encoded transaction involving a particular
    *        coin which took place directly after challengingTransaction
    * @param proof An inclusion proof of respondingTransaction
    * @param signature The signature which proves a direct spend from the challenger
    */
    function respondChallengeBefore(
        uint64 slot,
        bytes32 challengingTxHash,
        uint256 respondingBlockNumber,
        bytes respondingTransaction,
        bytes proof,
        bytes signature
    )
        external
    {
        // Check that the transaction being challenged exists
        require(
            challenges[slot].contains(challengingTxHash),
            "Responding to non existing challenge"
        );

        // Get index of challenge in the challenges array
        uint256 index = uint256(challenges[slot].indexOf(challengingTxHash));

        checkResponse(
            slot,
            index,
            respondingBlockNumber,
            respondingTransaction,
            signature,
            proof
        );

        // If the exit was actually challenged and responded, penalize the challenger and award the
        // responder
        slashBond(challenges[slot][index].challenger, msg.sender);

        // Put coin back to the exiting state
        coins[slot].state = State.EXITING;

        challenges[slot].remove(challengingTxHash);
        emit RespondedExitChallenge(slot);
    }

    /**
     * @dev Submits proof of a transaction that challenges an exit, under the assumption
     *      of a double-spent coin.
     *      Also makes sure that the user submitting the challenge has bonded
     *      funds, and the exit is in an EXITING state.
     * @param slot The slot corresponding to the coin whose exit is being challenged
     * @param challengingBlockNumber The block number with the challengingTransaction
     *        was mined in.
     * @param challengingTransaction The RLP-encoded transaction involving a particular
     *        coin which shows a coin has been double spent.
     * @param proof An inclusion proof of prevTx
     * @param signature The signature of the txBytes by the coin
     *        owner indicated in challengingTransaction
     */
    function challengeBetween(
        uint64 slot,
        uint256 challengingBlockNumber,
        bytes challengingTransaction,
        bytes proof,
        bytes signature
    )
        external
        isState(slot, State.EXITING)
        cleanupExit(slot)
    {
        checkBetween(
            slot,
            challengingTransaction,
            challengingBlockNumber,
            signature,
            proof
        );

        applyPenalties(slot);
    }

    /**
     * @dev Submits proof of a transaction that challenges an exit, under the assumption 
     *      that the slot being exited has already been spent.
     * @param slot The slot corresponding to the coin whose exit is being challenged
     * @param challengingBlockNumber The block number with the challengingTransaction
     *        was mined in.
     * @param challengingTransaction The RLP-encoded transaction involving a particular
     *        coin which shows a coin has been double spent.
     * @param proof An inclusion proof of prevTx
     * @param signature The signature of the txBytes by the coin
     *        owner indicated in challengingTransaction
     */
    function challengeAfter(
        uint64 slot,
        uint256 challengingBlockNumber,
        bytes challengingTransaction,
        bytes proof,
        bytes signature
    )
        external
        isState(slot, State.EXITING)
        cleanupExit(slot)
    {
        checkAfter(
            slot,
            challengingTransaction,
            challengingBlockNumber,
            signature,
            proof
        );

        applyPenalties(slot);
    }

    // Helper method to check if the slot has an invalid double spend
    function checkBetween(
        uint64 slot,
        bytes txBytes,
        uint blockNumber,
        bytes signature,
        bytes proof
    )
        private
        view
    {
        require(
            exits[slot].exitBlock > blockNumber &&
            exits[slot].prevBlock < blockNumber,
            "Tx should be between the exit's blocks"
        );

        Transaction.TX memory txData = txBytes.getTx();

        require(
            txData.hash.ecverify(signature, exits[slot].prevOwner),
            "Invalid signature"
        );

        require(
            txData.slot == slot,
            "Tx is referencing another slot"
        );

        checkTxIncluded(
            slot,
            txData.hash,
            blockNumber,
            proof
        );
    }

    // Helper function to check if a slot being exited has been spent already
    function checkAfter(
        uint64 slot,
        bytes txBytes,
        uint blockNumber,
        bytes signature,
        bytes proof
    )
        private
        view
    {
        Transaction.TX memory txData = txBytes.getTx();

        require(
            txData.hash.ecverify(signature, exits[slot].owner),
            "Invalid signature"
        );

        require(
            txData.slot == slot,
            "Tx is referencing another slot"
        );

        require(
            txData.prevBlock == exits[slot].exitBlock,
            "Not a direct spend"
        );

        checkTxIncluded(
            slot,
            txData.hash,
            blockNumber,
            proof
        );
    }

    function checkResponse(
        uint64 slot,
        uint256 index,
        uint256 blockNumber,
        bytes txBytes,
        bytes signature,
        bytes proof
    )
        private
        view
    {
        Transaction.TX memory txData = txBytes.getTx();

        require(
            txData.hash.ecverify(signature, challenges[slot][index].owner),
            "Invalid signature"
        );

        require(
            txData.slot == slot,
            "Tx is referencing another slot"
        );

        require(
            blockNumber > challenges[slot][index].challengingBlockNumber,
            "Chalenging block number is after block number"
        );

        checkTxIncluded(
            txData.slot,
            txData.hash,
            blockNumber,
            proof
        );
    }

    function applyPenalties(uint64 slot)
        private
    {
        // Apply penalties and change state
        slashBond(exits[slot].owner, msg.sender);
        coins[slot].state = State.DEPOSITED;
    }

   /**
    * @param slot The slot of the coin being challenged
    * @param owner The user claimed to be the true ower of the coin
    */
    function setChallenged(
        uint64 slot,
        address owner,
        uint256 challengingBlockNumber,
        bytes32 txHash
    )
        private
    {
        // Require that the challenge is in the first half of the challenge window
        require(
            block.timestamp <= exits[slot].createdAt.add(CHALLENGE_WINDOW),
            "Challenge is not in the first half of the window"
        );

        require(
            !challenges[slot].contains(txHash),
            "Transaction used for challenge already"
        );

        // Need to save the exiting transaction's owner, to verify
        // that the response is valid
        challenges[slot].push(
            ChallengeLib.Challenge({
                owner: owner,
                challenger: msg.sender,
                txHash: txHash,
                challengingBlockNumber: challengingBlockNumber
            })
        );

        emit ChallengedExit(slot, txHash);
    }
}
