pragma solidity 0.4.24;

import "./libs/LibChildChain.sol";

import "./mixins/MDeposit.sol";
import "./mixins/MRootChainCore.sol";


/**
 * @dev Handles the block creation after funds have been sent to the contract
 */
contract MixinDeposit is
    LibChildChain,
    MRootChainCore,
    MDeposit
{
   /**
    * @dev Allows anyone to deposit funds into the Plasma chain, called when
    *       contract receives ERC721, or ERC20/ERC721 tokens are directly deposited
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
        Mode mode
    )
        internal
    {
        currentBlock = currentBlock.add(1);
        uint64 slot = uint64(
            bytes8(
                keccak256(
                    abi.encodePacked(
                        numCoins,
                        msg.sender,
                        from
                    )
                )
            )
        );

        // Update state. Leave `exit` empty
        Coin storage coin = coins[slot];
        coin.uid = uid;
        coin.contractAddress = contractAddress;
        coin.denomination = denomination;
        coin.depositBlock = currentBlock;
        coin.owner = from;
        coin.state = State.DEPOSITED;
        coin.mode = mode;

        childChain[currentBlock] = ChildBlock({
            // save signed transaction hash as root
            // hash for deposit transactions is the hash of its slot
            root: keccak256(abi.encodePacked(slot)),
            createdAt: block.timestamp
        });

        // create a utxo at `slot`
        emit Deposit(
            slot,
            currentBlock,
            denomination,
            from,
            contractAddress
        );

        numCoins = numCoins.add(1);
    }
}
