pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";


// Sample ERC20 token to use in tests
contract SampleToken is
    StandardToken
{
    string public name    = "SampleToken";
    string public symbol  = "TKN";
    uint8 public decimals = 18;

    // one billion in initial supply
    uint256 public constant INITIAL_SUPPLY = 1000000000;

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY.mul(10 ** uint256(decimals));
        balances[msg.sender] = totalSupply_;
        
        emit Transfer(
            0x0,
            msg.sender,
            totalSupply_
        );
    }
}
