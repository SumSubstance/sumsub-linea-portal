/** @type import('hardhat/config').HardhatUserConfig */

require("@nomicfoundation/hardhat-verify");
const dotenv = require("dotenv");

dotenv.config({ path: "./.env" });

module.exports = {
  solidity: {
    version: "0.8.21",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      viaIR: true
    }
  },
  networks: {
    linea: {
      url: "https://rpc.linea.build"
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY ?? "",
    customChains: [
      {
        network: "linea",
        chainId: 59144,
        urls: {
          apiURL: "https://api.lineascan.build/api",
          browserURL: "https://lineascan.build"
        }
      }
    ]
  }
};
