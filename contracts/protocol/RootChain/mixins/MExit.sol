pragma solidity 0.4.24;

import "../libs/LibChildChain.sol";


contract MExit {
    /**
     * Event for logging exit starts
     * @param slot The slot of the coin being exited
     * @param owner The user who claims to own the coin being exited
     */
    event StartedExit(
        uint64 indexed slot,
        address indexed owner
    );

    /**
     * Event for exit finalization logging
     * @param slot The slot of the coin whose exit has been finalized
     * @param owner The owner of the coin whose exit has been finalized
     */
    event FinalizedExit(
        uint64 indexed slot,
        address owner)
    ;

    /**
     * Event to log the withdrawal of a coin
     * @param from The address of the user who withdrew bonds
     * @param mode The type of coin that is being withdrawn (ERC20/ERC721/ETH)
     * @param contractAddress The contract address where the coin is being withdrawn from
              is same as `from` when withdrawing a ETH coin
     * @param uid The uid of the coin being withdrawn if ERC721, else 0
     * @param denomination The denomination of the coin which has been withdrawn (=1 for ERC721)
     * @param slot The slot of the coin which has just been withdrawn
     */
    event Withdrew(
        address indexed from,
        LibChildChain.Mode mode,
        address contractAddress,
        uint uid,
        uint denomination,
        uint64 slot
    );

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
        returns (uint256);
}
