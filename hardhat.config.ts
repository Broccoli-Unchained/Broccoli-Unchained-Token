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
    },
    "polygon": {
      url: "https://polygon-bor-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 137
    },
    "WorldChain": {
      url: "https://worldchain.drpc.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 480
    },
    "Mantle": {
      url: "https://mantle-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 5000
    },
    "Ethereum": {
      url: "https://ethereum-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 1
    },
    "op-mainnet": {
      url: "https://optimism-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 10
    },
    "ArbitrumOne": {
      url: "https://arbitrum-one-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 42161
    },
    "Avalanche": {
      url: "https://avalanche-c-chain-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 43114
    },
    "Blast": {
      url: "https://blast-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 81457
    },
    "XLayer": {
      url: "https://xlayer.drpc.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 196
    },
    "Unichain": {
      url: "https://unichain-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 130
    },
    "Ink": {
      url: "https://ink.drpc.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 57073
    },
    "Soneium": {
      url: "https://soneium.drpc.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 1868
    },
    "Zora": {
      url: "https://rpc.zora.energy",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 7777777
    },
    "Mode": {
      url: "https://mode.drpc.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 34443
    },
    "MetalL2": {
      url: "https://metall2.drpc.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 1750
    },
    "Bob": {
      url: "https://bob.drpc.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 60808
    },
    "Shape": {
      url: "https://shape-mainnet.g.alchemy.com/public",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 360
    },
    "Cyber": {
      url: "https://cyber.alt.technology",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 7560
    }
  },
  etherscan: {
    apiKey: {
      bscTestnet: process.env.BSCSCAN_API_KEY ?? '',
      bsc: process.env.BSCSCAN_API_KEY ?? '',
      mainnet: process.env.BASESCAN_API_KEY ?? '',
      optimisticEthereum: process.env.OPSCAN_API_KEY ?? '',
      polygon: process.env.POLYGONSCAN_API_KEY ?? '',
      base: process.env.BASESCAN_API_KEY ?? '',
      mantle: process.env.MANTLESCAN_API_KEY ?? '',
      worldChain: process.env.WORLDSCAN_API_KEY ?? '',
    },
    customChains: [
      {
        network: "worldChain",
        chainId: 480,
        urls: {
          apiURL: "https://api.worldscan.org/api",
          browserURL: "https://worldscan.org/"
        }
      },
      {
        network: "mantle",
        chainId: 5000,
        urls: {
          apiURL: "https://api.mantlescan.xyz/api",
          browserURL: "https://mantlescan.xyz/"
        }
      }
    ]
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