var NewtouchToken = artifacts.require("./NewtouchToken.sol");

module.exports = function(deployer) {
  deployer.deploy(NewtouchToken, "NewtouchToken", "NT", '0x35C78D189755094A1A32A9d64860489D3FaFf309', 500000000000, {from: '0xD29EeeA848E554876D392FD44889c8a688e7cc0c'});
};
