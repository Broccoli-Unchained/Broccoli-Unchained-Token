import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomicfoundation/hardhat-verify";
import * as dotenv from "dotenv";

dotenv.config();

if (!process.env.PRIVATE_KEY) {
  throw new Error("PRIVATE_KEY not set in .env file");
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    "base-sepolia": {
      url: "https://sepolia.base.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 84532
    },
    "ink-sepolia": {
      url: "https://rpc-gel-sepolia.inkonchain.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 763373
    },
    "unichain-sepolia": {
      url: "https://sepolia.unichain.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 1301
    },
    "op-sepolia": {
      url: "https://optimism-sepolia-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 11155420
    },
    "sepolia": {
      url: "https://ethereum-sepolia-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 11155111
    },
    "bscTestnet": {
      url: "https://bsc-testnet-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 97
    },
    "base": {
      url: "https://base-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 8453
    },
    "bsc": {
      url: "https://bsc-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 56
    }
  },
  etherscan: {
    apiKey: {
      bscTestnet: process.env.BSCSCAN_API_KEY ?? '',
      bsc: process.env.BSCSCAN_API_KEY ?? '',
      // bnb: process.env.BSCSCAN_API_KEY ?? ''
    },
    // customChains: [
    //   {
    //     network: "bnb",
    //     chainId: 56,
    //     urls: {
    //       apiURL: "https://api.bscscan.com/api",
    //         browserURL: "https://bscscan.com/"
    //     }
    //   }
    // ]
  },
  ignition: {
    strategyConfig: {
      create2: {
        // To learn more about salts, see the CreateX documentation
        salt: process.env.SALT ?? "0x0000000000000000000000000000000000000000000000000000000000000000",
      },
    },
  },
};

export default config;