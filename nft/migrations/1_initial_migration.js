const CuddleToys = artifacts.require('CuddleToys')

module.exports = function (deployer) {
  deployer.deploy(CuddleToys)
}
