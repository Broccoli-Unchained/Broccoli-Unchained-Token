import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("BroccoliUnchained", (m) => {
  const BroccoliUnchained = m.contract("BroccoliUnchained");

  return { BroccoliUnchained };
}); 