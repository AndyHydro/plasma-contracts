pragma solidity 0.4.24;

import "./mixins/MRootChainCore.sol";
import "./mixins/MBond.sol";


/**
 * @dev Contains all the logic around depositing, withdrawing, and slashing bonds
 *      for users.
 */
contract MixinBond is
    MRootChainCore,
    MBond
{
   /**
    *  @dev Allows all funds that are withdrawable to be transferred to the
    *       caller.
    */
    function withdrawBonds()
        external
    {
        // Can only withdraw bond if the msg.sender
        uint256 amount = balances[msg.sender].withdrawable;
        balances[msg.sender].withdrawable = 0; // no reentrancy!
        msg.sender.transfer(amount);

        emit WithdrewBonds(msg.sender, amount);
    }

    /**
     *  @dev Unlocks bonded funds allowing them to be withdrawn
     *  @param from Address of user to unlock funds
     */
    function freeBond(address from)
        internal
    {
        balances[from].bonded = balances[from].bonded.sub(BOND_AMOUNT);
        balances[from].withdrawable = balances[from].withdrawable.add(BOND_AMOUNT);

        emit FreedBond(from, BOND_AMOUNT);
    }

    /**
     *  @dev Takes the current locked up funds and unlocks them for another user
     *  @param from Address of user to take bond away from
     *  @param to Address of user that is allowed to withdraw these funds
     */
    function slashBond(
        address from,
        address to
    )
        internal
    {
        balances[from].bonded = balances[from].bonded.sub(BOND_AMOUNT);
        balances[to].withdrawable = balances[to].withdrawable.add(BOND_AMOUNT);

        emit SlashedBond(
            from,
            to,
            BOND_AMOUNT
        );
    }
}
