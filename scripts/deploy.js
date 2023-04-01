const hre = require("hardhat");

async function main() {
  const HoshiboshiGoerli = await hre.ethers.getContractFactory(
    "HoshiboshiGoerli"
  );
  const _HoshiboshiGoerliDeployed = await HoshiboshiGoerli.deploy(
    "Hoshiboshi Goerli",
    "hoshichan",
    "https://arweave.net/6K3w3rK8LdFIryzm9wmSTIrDTnPbnyYjXJGvDZxxTEU/"
  );

  await _HoshiboshiGoerliDeployed.deployed();
  console.log(
    "HoshiboshiGoerli Nft was deployed to:",
    _HoshiboshiGoerliDeployed.address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
