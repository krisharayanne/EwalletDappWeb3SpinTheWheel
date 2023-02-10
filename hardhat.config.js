require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
// require("./tasks/block-number");
require("hardhat-gas-reporter");
require("solidity-coverage");

/** @type import('hardhat/config').HardhatUserConfig */

const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL || "https://eth-rinkeby/example";
const POLYGON_MUMBAI_RPC_URL = process.env.POLYGON_MUMBAI_RPC_URL || "https://eth-polygon-mumbai/example";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "0xkey";
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY || "key";
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || "key";

module.exports = {
  defaultNetwork: "hardhat",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
  networks: {
    rinkeby: {
        url: RINKEBY_RPC_URL,
        accounts: [PRIVATE_KEY],
        chainId: 4
    },
    polygonMumbai: {
      url: POLYGON_MUMBAI_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 80001
    },
    localhost: {
      url: "http://127.0.0.1:8545/",
      // accounts: Thanks hardhat!
      chainId: 31337
  }
  },
  solidity: "0.8.9",
  etherscan: {
    apiKey: POLYGONSCAN_API_KEY
  },
  gasReporter: {
    enabled: true,
    outputFile: "gas-report.txt",
    noColors: true,
    currency: "USD",
    coinmarketcap: COINMARKETCAP_API_KEY,
    token: "MATIC"
  }
};