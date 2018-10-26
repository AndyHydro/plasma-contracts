pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";


/**
* @title ChallengeLib
* @notice ChallengeLib is a helper library for constructing challenges
*/
library ChallengeLib {
    using SafeMath for uint256;

    struct Challenge {
        address owner;
        address challenger;
        bytes32 txHash;
        uint256 challengingBlockNumber;
    }

    function contains(Challenge[] storage _array, bytes32 txHash)
        internal
        view
        returns (bool)
    {
        int index = indexOf(_array, txHash);
        return index != -1;
    }

    function remove(Challenge[] storage _array, bytes32 txHash)
        internal
        returns (bool)
    {
        int index = indexOf(_array, txHash);
        if (index == -1) {
            return false; // Tx not in challenge arraey
        }

        // Replace element with last element
        uint256 lastIndex = _array.length.sub(1);
        Challenge memory lastChallenge = _array[lastIndex];
        _array[uint(index)] = lastChallenge;

        // Reduce array length
        delete _array[lastIndex];
        _array.length = lastIndex;
        return true;
    }

    function indexOf(Challenge[] storage _array, bytes32 txHash)
        internal
        view
        returns (int)
    {
        for (uint i = 0; i < _array.length; i++) {
            if (_array[i].txHash == txHash) {
                return int(i);
            }
        }

        return -1;
    }
}
