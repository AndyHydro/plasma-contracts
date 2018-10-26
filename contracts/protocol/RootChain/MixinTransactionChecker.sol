pragma solidity 0.4.24;

import "../../Libraries/Transaction/Transaction.sol";

import "./mixins/MRootChainCore.sol";
import "./mixins/MTransactionChecker.sol";



/**
 * @dev Handles checking transaction bytes for includion in merkle roots.  Heavily used
 *      in order to validate challenges and make sure the integrity of the chain is
 *      being maintained.
 */
contract MixinTransactionChecker is
    MRootChainCore,
    MTransactionChecker
{
    using Transaction for bytes;

   /**
    * @dev Verifies that consecutive two transaction involving the same coin
    *      are valid
    * @notice If exitingTxBytes corresponds to a deposit transaction,
    *         prevTxBytes cannot have a meaningul value and thus it is ignored.
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
    function doInclusionChecks(
        bytes prevTxBytes,
        bytes exitingTxBytes,
        bytes prevTxInclusionProof,
        bytes exitingTxInclusionProof,
        bytes signature,
        uint256[2] blocks
    )
        internal
        view
    {
        if (blocks[1] % childBlockInterval != 0) {
            // The block being exited from is a deposit block
            checkIncludedAndSigned(
                exitingTxBytes,
                exitingTxInclusionProof,
                signature,
                blocks[1]
            );
        } else {
            // The block being exited from is a plasma block
            checkBothIncludedAndSigned(
                prevTxBytes,
                exitingTxBytes,
                prevTxInclusionProof,
                exitingTxInclusionProof,
                signature,
                blocks
            );
        }
    }

    // Helper function used when checking an exiting transaction from a deposit block
    function checkIncludedAndSigned(
        bytes exitingTxBytes,
        bytes exitingTxInclusionProof,
        bytes signature,
        uint256 blk
    )
        internal
        view
    {
        Transaction.TX memory txData = exitingTxBytes.getTx();

        // Deposit transactions need to be signed by their owners
        // e.g. Alice signs a transaction to Alice
        require(
            txData.hash.ecverify(signature, txData.owner),
            "Invalid signature"
        );

        checkTxIncluded(
            txData.slot,
            txData.hash,
            blk,
            exitingTxInclusionProof
        );
    }

    // Helper function used when checking an exiting transaction from a plasma block
    function checkBothIncludedAndSigned(
        bytes prevTxBytes,
        bytes exitingTxBytes,
        bytes prevTxInclusionProof,
        bytes exitingTxInclusionProof,
        bytes signature,
        uint256[2] blocks
    )
        internal
        view
    {
        require(
            blocks[0] < blocks[1],
            "Previous block is after exiting block"
        );

        Transaction.TX memory exitingTxData = exitingTxBytes.getTx();
        Transaction.TX memory prevTxData = prevTxBytes.getTx();

        // Both transactions need to be referring to the same slot
        require(
            exitingTxData.slot == prevTxData.slot,
            "Exiting transaction slot is not the same slot as previous transaction"
        );

        // The exiting transaction must be signed by the previous transaciton's owner
        require(
            exitingTxData.hash.ecverify(signature, prevTxData.owner),
            "Invalid signature"
        );

        // Both transactions must be included in their respective blocks
        checkTxIncluded(
            prevTxData.slot,
            prevTxData.hash,
            blocks[0],
            prevTxInclusionProof
        );

        checkTxIncluded(
            exitingTxData.slot,
            exitingTxData.hash,
            blocks[1],
            exitingTxInclusionProof
        );
    }

    /**
     * @dev Checks if a transaction has is part of a merkle root
     * @notice Call to this function will fail if transaction is not part of the block in question
     * @param slot Slot for the coin that is part of the transaction
     * @param txHash Transaction hash to check membership against
     * @param blockNumber Block number for the block to check if the transaction is in
     * @param proof Bytes used to prove transaction presence in root
     */
    function checkTxIncluded(
        uint64 slot,
        bytes32 txHash,
        uint256 blockNumber,
        bytes proof
    )
        internal
        view
    {
        bytes32 root = childChain[blockNumber].root;

        if (blockNumber % childBlockInterval != 0) {
            // Check against block root for deposit block numbers
            require(
                txHash == root,
                "Transaction hash is equal to the block root hash"
            );
        } else {
            // Check against merkle tree for all other block numbers
            require(
                checkMembership(
                    txHash,
                    root,
                    slot,
                    proof
                ),
                "Tx not included in claimed block"
            );
        }
    }
}
