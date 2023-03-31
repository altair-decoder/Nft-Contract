const hre = require("hardhat");

async function main() {
  const Nakamigos = await hre.ethers.getContractFactory("Nakamigos");
  const _NakamigosDeployed = await Nakamigos.deploy(
    "Nakamigos Goerli",
    "Nakamigos",
    "ipfs://QmaN1jRPtmzeqhp6s3mR1SRK4q1xWPvFvwqW1jyN6trir9/"
  );

  await _NakamigosDeployed.deployed();
  console.log("Nakamigos Nft was deployed to:", _NakamigosDeployed.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
