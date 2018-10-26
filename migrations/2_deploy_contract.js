const SampleNFTs = artifacts.require('SampleNFTs');
const SampleToken = artifacts.require('SampleToken');
const RootChain = artifacts.require('RootChain');

module.exports = async function(deployer, network, accounts) {
  deployer.deploy(RootChain).then(async () => {
    await deployer.deploy(RootChain);
    const root = await RootChain.deployed();
    console.log(`RootChain deployed at address: ${root.address}`);

    await deployer.deploy(SampleNFTs, root.address);
    const sampleNFTs = await SampleNFTs.deployed();
    console.log(`SampleNFTs deployed at address: ${sampleNFTs.address}`);

    await deployer.deploy(SampleToken);
    const sampleToken = await SampleToken.deployed();
    console.log(`SampleToken deployed at address: ${sampleToken.address}`);
  });
};

