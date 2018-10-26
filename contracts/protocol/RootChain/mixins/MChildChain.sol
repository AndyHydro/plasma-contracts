pragma solidity 0.4.24;


contract MChildChain {
    /**
     * Event for block submission logging
     * @notice The event indicates the addition of a new Plasma block
     * @param blockNumber The block number of the submitted block
     * @param root The root hash of the Merkle tree containing all of a block's
     *             transactions.
     * @param timestamp The time when a block was added to the Plasma chain
     */
    event SubmittedBlock(
        uint256 blockNumber,
        bytes32 root,
        uint256 timestamp
    );
}
