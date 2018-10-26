pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";


// Sample ERC721 token to use in tests
contract SampleNFTs is
    ERC721Token("SampleNFTs", "NFT")
{
    address plasma;

    constructor (address _plasma)
        public
    {
        plasma = _plasma;
    }

    function register()
        external
    {
        // Give each new player 5 nfts
        for (int j = 0; j < 5; j++) {
            create();
        }
    }

    function create() private {
        uint256 tokenId = allTokens.length.add(1);
        _mint(msg.sender, tokenId);
    }
}
