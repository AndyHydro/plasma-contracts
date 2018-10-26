pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

import "./libs/LibChildChain.sol";

import "./mixins/MRootChainCore.sol";
import "./mixins/MTransactionChecker.sol";
import "./mixins/MBond.sol";
import "./mixins/MExit.sol";


/**
 * @dev Contains all logic to finalize operation on a plasma chain. The actions available
 *      are to start/finalize exits or withdraw the funds themselves.  Challenges may interrupt
 *      the exits, however challenges are handled by MixinChallenge
 */
contract MixinExit is
    LibChildChain,
    MRootChainCore,
    MTransactionChecker,
    MBond,
    MExit
{

   /**
    * @dev Starts the exit game on a specified slot, with appropriate proofs and transactions
    * @param prevTxBytes The RLP-encoded transaction involving a particular
    *        coin which took place directly before exitingTxBytes
    * @param exitingTxBytes The RLP-encoded transaction involving a particular
    *        coin which an exiting owner of the coin claims to be the latest
    * @param prevTxInclusionProof An inclusion proof of prevTx
    * @param exitingTxInclusionProof An inclusion proof of exitingTx
    * @param signature The signature of the exitingTxBytes by the coin
    *        owner indicated in prevTx
    * @param blocks An array of two block numbers, at index 0, the block
    *        containing the prevTx and at index 1, the block containing
    *        the exitingTx
    */
    function startExit(
        uint64 slot,
        bytes prevTxBytes,
        bytes exitingTxBytes,
        bytes prevTxInclusionProof,
        bytes exitingTxInclusionProof,
        bytes signature,
        uint256[2] blocks
    )
        external
        payable
        isBonded
        isState(slot, State.DEPOSITED)
    {
        require(
            msg.sender == exitingTxBytes.getOwner(),
            "Sender is not owner of exiting transaction"
        );

        doInclusionChecks(
            prevTxBytes,
            exitingTxBytes,
            prevTxInclusionProof,
            exitingTxInclusionProof,
            signature,
            blocks
        );

        pushExit(
            slot,
            prevTxBytes.getOwner(),
            blocks
        );
    }

   /**
    * @dev Iterates through all of the initiated exits and finalizes those which have matured
    *      without being successfully challenged
    */
    function finalizeExits()
        external
    {
        uint256 exitSlotsLength = exitSlots.length;
        for (uint256 i = 0; i < exitSlotsLength; i++) {
            finalizeExit(exitSlots[i]);
        }
    }

   /**
    * @dev Withdraw a UTXO that has been exited
    * @param slot The slot of the coin being withdrawn
    */
    function withdraw(uint64 slot)
        external
        isState(slot, State.EXITED)
    {
        require(
            coins[slot].owner == msg.sender,
            "You do not own that UTXO"
        );

        uint256 uid = coins[slot].uid;
        uint256 denomination = coins[slot].denomination;

        // Delete the coin that is being withdrawn
        Coin memory c = coins[slot];
        delete coins[slot];

        if (c.mode == Mode.ETH) {
            msg.sender.transfer(denomination);
        } else if (c.mode == Mode.ERC20) {
            require(ERC20(c.contractAddress).transfer(msg.sender, denomination), "transfer failed");
        } else if (c.mode == Mode.ERC721) {
            ERC721(c.contractAddress).safeTransferFrom(
                address(this),
                msg.sender,
                uid
            );
        } else {
            revert("Invalid coin mode");
        }

        emit Withdrew(
            msg.sender,
            c.mode,
            c.contractAddress,
            uid,
            denomination,
            slot
        );
    }

   /**
    * @dev Finalizes an exit, i.e. puts the exiting coin into the EXITED
    *      state which will allow it to be withdrawn, provided the exit has
    *      matured and has not been successfully challenged
    */
    function finalizeExit(uint64 slot)
        public
    {
        Coin storage coin = coins[slot];

        // If a coin is not under exit/challenge, then ignore it
        if (coin.state != State.EXITING) {
            return;
        }

        Exit storage exit = exits[slot];

        // If an exit is not matured, ignore it
        if ((block.timestamp.sub(exit.createdAt)) <= MATURITY_PERIOD) {
            return;
        }

        // Check if there are any pending challenges for the coin.
        // `checkPendingChallenges` will also penalize
        // for each challenge that has not been responded to
        bool hasChallenges = checkPendingChallenges(slot);

        if (!hasChallenges) {
            // Update coin's owner
            coin.owner = exit.owner;
            coin.state = State.EXITED;

            // Allow the exitor to withdraw their bond
            freeBond(coin.owner);

            emit FinalizedExit(slot, coin.owner);
        } else {
            // Reset coin state since it was challenged
            coin.state = State.DEPOSITED;
        }

        delete exits[slot];
        delete exitSlots[getExitIndex(slot)];
    }

    /**
     * Returns the index of the exit slot for the specified slot
     * @notice If the slot's exit is not found, a large number is returned to
     *         ensure the exit array access fails
     * @param slot The slot being exited
     * @return The index of the slot's exit in the exitSlots array
     */
    function getExitIndex(uint64 slot)
        internal
        view
        returns (uint256)
    {
        uint256 len = exitSlots.length;
        for (uint256 i = 0; i < len; i++) {
            if (exitSlots[i] == slot) {
                return i;
            }
        }

        // a default value to return larger than the possible number of coins
        return 2**65;
    }

    function checkPendingChallenges(uint64 slot)
        private
        returns (bool hasChallenges)
    {
        uint256 length = challenges[slot].length;
        bool slashed;

        for (uint i = 0; i < length; i++) {
            if (challenges[slot][i].txHash != 0x0) {
                // Penalize the exitor and reward the first valid challenger.
                if (!slashed) {
                    slashBond(exits[slot].owner, challenges[slot][i].challenger);
                    slashed = true;
                }

                // Also free the bond of the challenger.
                freeBond(challenges[slot][i].challenger);

                // Challenge resolved, delete it
                delete challenges[slot][i];
                hasChallenges = true;
            }
        }
    }

    // Needed to bypass stack limit errors
    function pushExit(
        uint64 slot,
        address prevOwner,
        uint256[2] blocks
    )
        private
    {
        // Push exit to list
        exitSlots.push(slot);

        // Create exit
        exits[slot] = Exit({
            prevOwner: prevOwner,
            owner: msg.sender,
            createdAt: block.timestamp,
            bond: msg.value,
            prevBlock: blocks[0],
            exitBlock: blocks[1]
        });

        // Update coin state
        Coin storage c = coins[slot];
        c.state = State.EXITING;

        emit StartedExit(slot, msg.sender);
    }
}
