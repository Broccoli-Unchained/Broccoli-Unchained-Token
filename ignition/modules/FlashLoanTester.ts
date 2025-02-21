import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("FlashLoanTester", (m) => {
  // Replace with the actual deployed ERC20FlashMint token address
  const flashLoanProviderAddress = "0xd34e1f4E3F7B53413DE108feB876716Ee77Cc065";

  // Pass the constructor argument to the contract
  const FlashLoanTester = m.contract("FlashLoanTester", [flashLoanProviderAddress]);

  return { FlashLoanTester };
});
