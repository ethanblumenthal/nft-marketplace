const CryptoKitties = artifacts.require('CryptoKitties');

module.exports = function (deployer) {
  deployer.deploy(CryptoKitties);
};
