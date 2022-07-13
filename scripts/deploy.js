async function main() {
  const NFTMarketPlace = await ethers.getContractFactory("NFTMarketPlace")
  const nftMarketPlace = await NFTMarketPlace.deploy()
  await nftMarketPlace.deployed()
  console.log("nftMarketPlace deployed to address:", nftMarketPlace.address)

  const Nft= await ethers.getContractFactory("Nft");
  const nft = await Nft.deploy(nftMarketPlace.address)
  await nft.deployed()
  console.log("nft deployed to address:", nft.address)

}








main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })