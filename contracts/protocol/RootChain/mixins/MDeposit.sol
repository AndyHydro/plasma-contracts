pragma solidity 0.4.24;

import "../libs/LibChildChain.sol";


contract MDeposit {
    /**
     * Event for coin deposit logging.
     * @notice The Deposit event indicates that a deposit block has been added
     *         to the Plasma chain
     * @param slot Plasma slot, a unique identifier, assigned to the deposit
     * @param blockNumber The index of the block in which a deposit transaction
     *                    is included
     * @param denomination Quantity of a particular coin deposited
     * @param from The address of the depositor
     * @param contractAddress The address of the contract making the deposit
     */
    event Deposit(
        uint64 indexed slot,
        uint256 blockNumber,
        uint256 denomination,
        address indexed from,
        address indexed contractAddress
    );

   /**
    * @dev Allows anyone to deposit funds into the Plasma chain, called when
    *      contract receives ERC721
    * @notice Appends a deposit block to the Plasma chain
    * @param from The address of the user who is depositing a coin
    * @param contractAddress The address of the contract making the deposit
    * @param uid The uid of the ERC721 coin being deposited. This is an
    *            identifier allocated by the ERC721 token contract; it is not
    *            related to `slot`. If the coin is ETH or ERC20 the uid is 0
    * @param denomination The quantity of a particular coin being deposited
    * @param mode The type of coin that is being deposited (ETH/ERC721/ERC20)
    */
    function deposit(
        address from,
        address contractAddress,
        uint256 uid,
        uint256 denomination,
        LibChildChain.Mode mode
    )
        internal;
}
