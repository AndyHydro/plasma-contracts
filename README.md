<a href="https://elph.com" target="_blank">
  <img src="https://s3.amazonaws.com/elph-static/logo.svg" height="85px">
</a>

[![GitHub license](https://img.shields.io/badge/license-GPLv2-blue.svg)](https://github.com/elphnetwork/block-explorer/blob/master/LICENSE.txt)
[![Node Version](https://img.shields.io/badge/node-v8.11.3-brightgreen.svg)](https://nodejs.org/en/)
[![Truffle Version](https://img.shields.io/badge/truffle-v4.1.14-green.svg)](https://truffleframework.com/)
[![SolC Version](https://img.shields.io/badge/solidity-v0.4.24-green.svg)](https://solidity.readthedocs.io/en/v0.4.24/installing-solidity.html)
[![Travis (.org)](https://img.shields.io/travis/elphnetwork/plasma-contracts.svg)](https://travis-ci.org/elphnetwork/plasma-contracts)
[![Telegram](https://img.shields.io/badge/telegram-join%20chat-blue.svg)](https://t.me/elphnetwork)

# Elph Network Plasma Contracts

> Elph Network's Plasma contracts are a full implementation of [Plasma Cash](https://ethresear.ch/t/plasma-cash-plasma-with-much-less-per-user-data-checking/1298).  With support for Ether, ERC20 & ERC721 tokens these contracts act as the root chain bridge allowing assets to be securely transfered to and from the Elph Network.

## Testnet

These contracts are [live on Rinkeby](https://rinkeby.etherscan.io/address/0x40af244c94e679aebf897512720a41d843954a29) and are being actively used on the Elph Network Testnet.

Further interactions with these contracts and the Elph Network can be done using the [Block Explorer](https://explorer.elph.com) or the [Plasma Demo](https://demo.elph.com), which both showcase the power a plasma network can have as a layer-2 solution.

## Key Features

- Plasma Cash security guarantees
- Ether, ERC20 and ERC721 Support
- Full challengable exit support
    - Challenge "Double Spend"
    - Challenge "Exit Spend"
    - Challenge "Invalid history"
- Bonding and slashing for challenges and exits

## Development

#### Installation

To clone and run this application, you'll need [Git](https://git-scm.com) and [Node.js](https://nodejs.org/en/download/). We also recommend using [Yarn](https://yarnpkg.com/en/) over NPM. From your command line:

```bash
# Clone this repository
$ git clone https://github.com/elphnetwork/plasma-contracts.git

# Go into the repository
$ cd plasma-contracts

# Install dependencies
$ yarn install
```

Note: If you're using Linux Bash for Windows, [see this guide](https://www.howtogeek.com/261575/how-to-run-graphical-linux-desktop-applications-from-windows-10s-bash-shell/) or use `node` from the command prompt.

#### Usage

In order to make changes or run tests, a local blockchain must be running.  Since we have `ganache-cli` as a dependency, that's the easiest way to run a local blockchain to deploy the contracts to.

```bash
# Start ganache-cli in the background
$ yarn blockchain:start
```

```bash
# Stop any ganache-cli
$ yarn blockchain:stop
```

#### Testing

With ganache running:

```bash
# Runs all tests in repository
$ yarn test
```

## Deployment

#### Local Ganache

```bash
# Deploy this repository
$ yarn deploy
```

#### Rinkeby

First create a `.env` file by copying `.env.sample` and fill in the appropriate values

```bash
INFURA_API_KEY=''    # Represents your Infura API Key
RINKEBY_ADDRESS=''   # Represents the address which will deploy the contract
RINKEBY_MNEMONIC=''  # Mnemonic phrase representing the seed phrase for the address
```

After the environment is setup, run:

```bash
# Deploy this repository to rinkeby
$ yarn deploy:rinkeby
```

Use the [Rinkeby Faucet](https://faucet.rinkeby.io) to get some testnet ETH to test out the deployed contract.

#### Mainnet

These contracts are still undergoing testing and security audits, therefore have not yet been deployed to mainnet.  However, if you choose to use/deploy, simply add the `mainnet` network to `truffle.js` and the deployment will be similar to Rinkeby.

## Testing

### RootChain Solidity Contract Tests
This section details the current set of tests in the repository to ensure the contract is working as intended.
More tests will be added to this repository over time.
- [x] Deposits
    - [x] Send ETH / ERC721 to the RootChain contract
        - [x] Ensure balance is updated accordingly on the original account
        - [x] A new slot is created and a deposit event is emitted
    - [x] Multi-deposits
        - [x] Two owners deposit a coin each, exchange it with each other and
              are able to withdraw the other coin.
- [x] Exit / Withdraw
    - [x] Associated events (i.e., StartExit, Withdrew) are emitted by the contract
    - [x] Should require bond for exiting (and challenging)
    - [x] Withdraw initial deposit transaction
    - [x] Exitor withdraws a coin that was deposited and sent to them
    - [x] Exitor withdraws a coin that was deposited (and sent to multiple
          participants) prior to being sent to them
    - [x] Inability for the exitor to withdraw a coin before the maturity period
    - [x] Inability for a random participant to withdraw your coin
    - [x] Inability for the exitor to withdraw a coin after sending it away to
          another participant
    - [x] Multiple participants should be able to withdraw coins they received from
          each other
    - [x] Bonds are slashed and routed to the correct recipient (challenger or exitor)
          accordingly.
- [x] General Flow
    - [x] Signature checks and transaction inclusion checks
    - [x] Authority should be able to submit blocks
    - [x] Correct Merkle Tree implementation (membership checks, proofs of inclusion)
- [x] Challenge: "Double Spend" multi-participant scenario
    - [x] Successful "double spend" scenario challenge
    - [x] "Double spend" scenario that is not challenged in time, hence a successful exit
    - [x] "Double spend" scenario that is challenged and fails (despite collusion with operator)
- [x] Challenge: "Exit Spend" multi-participant scenario
    - [x] Successful "exit spend" schenario challenge
    - [x] "Exit spend" scenario that is not challenged in time, hence a successful exit
    - [x] "Exit spend" scenario that and is challenged and fails (despite collusion with operator)
- [x] Challenge: "Invalid history" multi-participant scenario
    - [x] Invalid history scenario that is challenged successfully
    - [x] Invalid history scenario that is challenged and responded to with an invalid response (no exit)
    - [x] Invalid history scenario that is challenged by multiple participants, followed by an invalid
          response (no exit)
    - [x] Invalid history scenario that is challenged by multiple participants, followed by no response
          from the exitor
    - [x] Invalid history scenario that is not challenged in time (exit)
    - [x] Valid history scenario that is challenged but responded to with a valid response (exit)
    - [x] Ensure all guarantees hold even if operator is byzantine

## Roadmap

We're working on improving these contracts with the newest research coming out (including adding Plasma Debit / XT / Cashflow).

We're also looking to release our side chain implementation to allow for full local development.

## Related

- [elphnetwork/elph-sdk](https://github.com/elphnetwork/elph-sdk): Elph Javascript SDK to communicate with these contracts.
- [elphnetwork/block-explorer](https://github.com/elphnetwork/block-explorer): Elph Block Explorer that shows the Elph Plasma Chain testnet using these contracts on Rinkeby.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Contact

Interested in getting touch with the Elph team? Feel free to [join our Telegram](http://t.me/elphnetwork) to ask any questions or share any feedback!

## Acknowledgements

Our implementation was inspired from a lot of the research and work done by various organizations working on Plasma as well, including omisego, Loom, and many folks on ethresearch.


## License

[GPLv2](https://github.com/elphnetwork/plasma-contracts/blob/master/LICENSE.txt)
