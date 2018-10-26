pragma solidity 0.4.24;


/**
 * @title Library for Child Chain
 * @dev Contains the structures and enums needed to run a child chain
 */
contract LibChildChain {
    // Specific state the coin is currently in
    enum State {
        DEPOSITED,
        EXITING,
        EXITED
    }

    // Specifies the type for the Coin (Ether or token)
    enum Mode {
        ETH,
        ERC20,
        ERC721
    }

    // Keep track of individuals funds deposited or locked up by the contract
    struct Balance {
        uint256 bonded;
        uint256 withdrawable;
    }

    // Track owners of txs that are pending a response
    struct Challenge {
        address owner;
        uint256 blockNumber;
    }

    // Each exit can only be challenged by a single challenger at a time
    struct Exit {
        address prevOwner;
        address owner;
        uint256 createdAt;
        uint256 bond;
        uint256 prevBlock;
        uint256 exitBlock;
    }

    // Representation of each coin in a slot in the SMT
    struct Coin {
        Mode mode;
        State state;
        address owner;
        address contractAddress; // Which contract the coin belongs to
        uint256 uid;
        uint256 denomination;
        uint256 depositBlock;
    }

    // Representation of a block on the plasma chain
    struct ChildBlock {
        bytes32 root;
        uint256 createdAt;
    }
}
