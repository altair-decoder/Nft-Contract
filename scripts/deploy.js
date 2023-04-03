const hre = require("hardhat");

async function main() {
  const Quirkies = await hre.ethers.getContractFactory("Quirkies");
  const _QuirkiesDeployed = await Quirkies.deploy(
    "Quirkies Goerli",
    "QRKSG",
    "https://meebits.larvalabs.com/meebit/"
  );

  await _QuirkiesDeployed.deployed();
  console.log("Quirkies Nft was deployed to:", _QuirkiesDeployed.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
