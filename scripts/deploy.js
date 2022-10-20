
const { ethers } = require("hardhat")

async function main() {
  const SuperMarket = await hre.ethers.getContractFactory("SuperMarket");
  const superMarket = await SuperMarket.deploy();
  await superMarket.deployed();
  console.log("supermarket deployed to:", superMarket.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
