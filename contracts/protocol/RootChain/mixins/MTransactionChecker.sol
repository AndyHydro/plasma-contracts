pragma solidity 0.4.24;


contract MTransactionChecker {
    function doInclusionChecks(
        bytes prevTxBytes,
        bytes exitingTxBytes,
        bytes prevTxInclusionProof,
        bytes exitingTxInclusionProof,
        bytes signature,
        uint256[2] blocks
    )
        internal
        view;

    function checkIncludedAndSigned(
        bytes exitingTxBytes,
        bytes exitingTxInclusionProof,
        bytes signature,
        uint256 blk
    )
        internal
        view;

    function checkBothIncludedAndSigned(
        bytes prevTxBytes,
        bytes exitingTxBytes,
        bytes prevTxInclusionProof,
        bytes exitingTxInclusionProof,
        bytes signature,
        uint256[2] blocks
    )
        internal
        view;

    function checkTxIncluded(
        uint64 slot,
        bytes32 txHash,
        uint256 blockNumber,
        bytes proof
    )
        internal
        view;
}