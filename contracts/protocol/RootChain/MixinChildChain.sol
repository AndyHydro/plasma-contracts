pragma solidity 0.4.24;

import "./libs/LibChildChain.sol";

import "./mixins/MRootChainCore.sol";
import "./mixins/MChildChain.sol";


/**
 * @dev Child chain calls the functions in this contract, primarily used to
 *      submit plasma block roots.
 */
contract MixinChildChain is
    LibChildChain,
    MRootChainCore,
    MChildChain
{

    /**
     * @dev Submits a merkle root of a plasma block to the root chain.  The authority
     *      needs to call this after every plama block to ensure that the plasma chain
     *      maintains integrity and users don't mass exit.
     * @param root The merkle root for a plasma block chain.
     */
    function submitBlock(bytes32 root)
        public
    {
        // Rounding to next whole `childBlockInterval`
        currentBlock = currentBlock
            .add(childBlockInterval)
            .div(childBlockInterval)
            .mul(childBlockInterval);

        // Save the ChildBlock into the contract
        childChain[currentBlock] = ChildBlock({
            root: root,
            createdAt: block.timestamp
        });

        // Emit a SubmittedBlock event
        emit SubmittedBlock(
            currentBlock,
            root,
            block.timestamp
        );
    }
}
