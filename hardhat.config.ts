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
      chainId: 480
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
    "Celo": {
      url: "https://celo-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 42220
    },
    "Fantom": {
      url: "https://fantom-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 250
    },
    "Kaia": {
      url: "https://klaytn.drpc.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 8217
    },
    "Scroll": {
      url: "https://scroll-rpc.publicnode.com",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 534352
    },
    "SNAXChain": {
      url: "https://mainnet.snaxchain.io",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 2192
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
    "Lisk": {
      url: "https://lisk.drpc.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 1135
    },
    "Zora": {
      url: "https://zora.drpc.org",
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
      url: "https://rpc.cyber.co",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 7560
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