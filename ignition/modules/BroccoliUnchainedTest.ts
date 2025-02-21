import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("BroccoliUnchainedTest", (m) => {
  const BroccoliUnchainedTest = m.contract("BroccoliUnchainedTest");

  return { BroccoliUnchainedTest };
}); 