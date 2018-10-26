pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Receiver.sol";

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

import "./libs/LibChildChain.sol";
import "./mixins/MRootChainCore.sol";
import "./mixins/MDeposit.sol";


/**
 * @dev Contains public functions that external users will call in order to move funds
 *      into the plasma chain.
 */
contract MixinTokenReceiver is
    ERC721Receiver,
    LibChildChain,
    MRootChainCore,
    MDeposit
{

    function()
        public
        payable
    {
        deposit(
            msg.sender,
            msg.sender,
            0,
            msg.value,
            Mode.ETH
        );
    }

    /**
     *  @dev Direct function an end user can call to transfer ERC20 tokens onto the plasma chain
     *  @notice Necessitates `approve` being called on the specified ERC20 contract first
     *  @param amount Amonunt of tokens being deposited to the plasma chain
     *  @param contractAddress Contract address for the token
     */
    function depositERC20(uint256 amount, address contractAddress) external {
        require(
            ERC20(contractAddress)
                .transferFrom(
                    msg.sender,
                    address(this),
                    amount
                ),
            "Transfer failed"
        );
        
        deposit(
            msg.sender,
            contractAddress,
            0,
            amount,
            Mode.ERC20
        );
    }

    /**
     *  @dev Direct function an end user can call to transfer ERC721 tokens onto the plasma chain
     *  @notice Necessitates `approve` being called on the specified ERC721 contract first
     *  @param uid Unique identifier of the token being deposited
     *  @param contractAddress Contract address for the token
     */
    function depositERC721(uint256 uid, address contractAddress) external {
        ERC721(contractAddress)
            .safeTransferFrom(
                msg.sender,
                address(this),
                uid
            );
            
        deposit(
            msg.sender,
            contractAddress,
            uid,
            1,
            Mode.ERC721
        );
    }

   /**
    *  @dev This is called from an ERC721 compliant contract.  This is the function that
    *       will depsoit the token into the plasma sidechain
    *  @param _from Owner of the token that wanted to deposit it
    *  @param _uid Unique token UID to identify the 721
    */
    function onERC721Received(
        address _from,
        uint256 _uid,
        bytes
    )
        public
        returns (bytes4)
    {
        deposit(
            _from,
            msg.sender,
            _uid,
            1,
            Mode.ERC721
        );

        return ERC721_RECEIVED;
    }
}
