pragma solidity 0.4.24;


contract MChallenge {
    /**
     * Event for exit challenge logging
     * @notice This event only fires if `challengeBefore` is called. Other
     *         types of challenges cannot be responded to and thus do not
     *         require an event.
     * @param slot The slot of the coin whose exit was challenged
     * @param txHash The hash of the tx used for the challenge
     */
    event ChallengedExit(
        uint64 indexed slot,
        bytes32 txHash
    );

    /**
     * Event for exit response logging
     * @notice This only logs responses to `challengeBefore`, other challenges
     *         do not require responses.
     * @param slot The slot of the coin whose challenge was responded to
     */
    event RespondedExitChallenge(uint64 indexed slot);
}
