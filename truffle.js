require('@babel/register');
require('@babel/polyfill');
require('dotenv').config();

const HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {
  networks: {
    development: {
      network_id: '15',
      host: 'localhost',
      port: 8545
    },
    rinkeby: {
      provider: () => new HDWalletProvider(process.env.RINKEBY_MNEMONIC, `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`),
      from: (process.env.RINKEBY_ADDRESS || '').toLowerCase(),
      network_id: 4,
      gas: 7.5e6,
      gasPrice: 5e9  // 5 gwei
    }
  },
  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      currency: 'USD'
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};
