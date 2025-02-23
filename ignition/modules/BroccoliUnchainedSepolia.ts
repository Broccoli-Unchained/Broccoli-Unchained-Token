import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("BroccoliUnchainedSepolia", (m) => {
  const BroccoliUnchainedSepolia = m.contract("BroccoliUnchainedSepolia");

  return { BroccoliUnchainedSepolia };
}); 