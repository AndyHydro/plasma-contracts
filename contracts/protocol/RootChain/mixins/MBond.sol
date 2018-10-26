pragma solidity 0.4.24;


contract MBond {
    /**
     * Event to log the freeing of a bond
     * @param from The address of the user whose bonds have been freed
     * @param amount The bond amount which can now be withdrawn
     */
    event FreedBond(
        address indexed from,
        uint256 amount
    );

    /**
     * Event to log the slashing of a bond
     * @param from The address of the user whose bonds have been slashed
     * @param to The recipient of the slashed bonds
     * @param amount The bound amount which has been forfeited
     */
    event SlashedBond(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    /**
     * Event to log the withdrawal of a bond
     * @param from The address of the user who withdrew bonds
     * @param amount The bond amount which has been withdrawn
     */
    event WithdrewBonds(
        address indexed from,
        uint256 amount
    );

    function withdrawBonds()
        external;

    function freeBond(address from)
        internal;

    function slashBond(
        address from,
        address to
    )
        internal;
}
