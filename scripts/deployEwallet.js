// imports
const { ethers, run, network } = require("hardhat");

// async main
async function main() {
  const EwalletContractFactory = await ethers.getContractFactory("Ewallet");
  console.log("Deploying contract...");
  const ewalletContract = await EwalletContractFactory.deploy();
  await ewalletContract.deployed();
  // what's the private key?
  // what's the rpc url?
  console.log(`Deployed contract to: ${ewalletContract.address}`);
  // what happens when we deploy to our hardhat network

  if(network.config.chainId === 80001 && process.env.POLYGONSCAN_API_KEY){
    console.log("Waiting for block txes...");
    await ewalletContract.deployTransaction.wait(20);
    await verify(ewalletContract.address, []);
  }

// Add Team
for(var i = 1; i <= 6; i++){
  let teamName = "Team " + i.toString();
  let transactionResponse = await ewalletContract.addTeam(teamName);
  await transactionResponse.wait(1);
  console.log("\n Add Team Transaction Hash:")
  console.log(transactionResponse.hash);
}


// // Add Retailer
// let retailerName = "Adidas";
// let transactionResponse = await membershipToken.addRetailer(retailerName);
// await transactionResponse.wait(1);
// console.log("\n Add Retailer Transaction Hash:")
// console.log(transactionResponse.hash);

// // Get Token ID by Retailer Name
// let tokenId = await membershipToken.getTokenIdByRetailerName(retailerName);
// console.log("Token ID for Retailer: " + retailerName);
// console.log(tokenId);



// // Mint Tokens
// let tokenQuantity = 21;
// let ipfsURL = 'ipfs://bafyreie5k4fycgqef6hfphpplrfixvnz44fgvdffi5wsbq2m7ivi5yqr4m/metadata.json';
// let transactionResponse2 = await membershipToken.mintTokens(retailerName, tokenQuantity, ipfsURL);
// await transactionResponse2.wait(1);
// console.log("\n Mint Tokens Transaction Hash:")
// console.log(transactionResponse2.hash);
}

async function verify(contractAddress, args){
  // async (contractAddress, args) => {
    console.log("Verifying contract...");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args
    });
  }
  catch(e) {
    if(e.message.toLowerCase().includes("already verified")){
      console.log("Already Verified!");
    }
    else{
      console.log(e);
    }
  }

}

// main
main().then(() => {
  process.exit(0);
}).catch((error) => {
  console.error(error);
  process.exit(1);
})