// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* 
    ---------------------------------------------------------
    OpenZeppelin Imports
    ---------------------------------------------------------
*/
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20FlashMint} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

// Wormhole libraries
import "wormhole-solidity-sdk/interfaces/IWormholeRelayer.sol";
import "wormhole-solidity-sdk/interfaces/IWormholeReceiver.sol";

// OP Superchain libraries
import {IERC7802, IERC165} from "./libs/IERC7802.sol";
import {Predeploys} from "./libs/Predeploys.sol";
import {Unauthorized} from "./libs/CommonErrors.sol";

/* 
    ---------------------------------------------------------
    Library for Extended Math (limitLessThan)
    ---------------------------------------------------------
*/
library ExtendedMath {
    function limitLessThan(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }
}

/*
    ---------------------------------------------------------
    Broccoli Unchained with PoW, Difficulty Adjustment and Superchain
    ---------------------------------------------------------
*/
contract BroccoliUnchained is
    ERC20,
    ERC20Permit,
    ERC20Burnable,
    ERC20FlashMint,
    IERC7802
{
    using ExtendedMath for uint;

    // --------------------------------------------
    // Mining & Difficulty Variables
    // --------------------------------------------
    uint public constant MAX_LIMIT =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;
    uint public latestDifficultyPeriodStarted;
    uint public epochCount;

    uint public constant _BLOCKS_PER_READJUSTMENT = 1024;
    uint public constant _MINIMUM_TARGET = 2 ** 16; // Hardest
    uint public constant _MAXIMUM_TARGET = 2 ** 234; // Easiest

    uint public miningTarget; // Current target
    bytes32 public challengeNumber; // PoW challenge
    uint public rewardEra; // Tracks how many halvings have happened
    uint public currentMiningReward;
    uint public tokensMinted;

    // --------------------------------------------
    // Time-based Halving Schedule
    // --------------------------------------------
    // Halve every 7 months (approx. 210 days) in seconds
    uint256 public constant HALVING_PERIOD = 210 days;
    uint256 public nextHalvingTime;

    // --------------------------------------------
    // Flash Loan Settings
    // --------------------------------------------
    uint256 private constant FLASH_FEE_BASIS_POINTS = 1; // 0.01% fee
    uint256 private constant FLASH_FEE_MIN = 1; // Min Fee for flashloan
    uint256 private constant FLASH_FEE_MIN_THRESHOLD = 10000; // Amt in wei below where min fee is charged

    // --------------------------------------------
    // PoW Reward Stats
    // --------------------------------------------
    address public lastRewardTo;
    uint public lastRewardAmount;
    uint public lastRewardEthBlockNumber;

    // --------------------------------------------
    // Allowed Chains
    // --------------------------------------------
    mapping(uint => bool) public allowedChains; // Mapping to track allowed chains

    // --------------------------------------------
    // Wormhole Relays
    // --------------------------------------------
    mapping(uint => address) private wormholeRelayers;
    IWormholeRelayer public wormholeRelayer;
    uint256 constant GAS_LIMIT = 100000; // Adjust the gas limit as needed

    // --------------------------------------------
    // Events
    // --------------------------------------------
    event Mint(
        address indexed from,
        uint rewardAmount,
        uint epochCount,
        bytes32 newChallengeNumber
    );
    event DifficultyAdjusted(
        uint256 newTarget,
        uint256 newDifficulty,
        uint256 ethBlocksSinceLastDifficultyPeriod
    );
    event RewardUpdated(uint256 newReward, uint256 rewardEra);
    event NewEpochStarted(uint256 epochCount, bytes32 challengeNumber);

    event CrossChainReceived(uint256 amount, address owner, uint16 sourceChain);

    /*
        ---------------------------------------------------------
        Constructor
        ---------------------------------------------------------
    */
    constructor()
        ERC20("Broccoli Unchained", "BROCU")
        ERC20Permit("Broccoli Unchained")
    {
        tokensMinted = 0;
        rewardEra = 0;
        // Starting PoW reward
        currentMiningReward = 896 * 10 ** decimals();

        miningTarget = _MAXIMUM_TARGET;
        latestDifficultyPeriodStarted = block.number;
        challengeNumber = blockhash(block.number - 1);

        // Set the time of next halving to be 6 months from now
        nextHalvingTime = block.timestamp + HALVING_PERIOD;

        // Initialize allowed chains (example: 1 for Ethereum mainnet, 2 for Binance Smart Chain)
        allowedChains[8453] = true; // Coinbase Base
        allowedChains[5000] = true; // Bybit Mantle
        allowedChains[480] = true; // World Chain Mainnet
        allowedChains[137] = true; // Polygon (MATIC) Mainnet
        allowedChains[56] = true; // BNB Mainnet
        allowedChains[10] = true; // OP Mainnet
        allowedChains[1] = true; // ETH Mainnet
        // Add more chains as needed

        wormholeRelayers[1] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // ETH Mainnet
        wormholeRelayers[42161] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // Arbitrum One
        wormholeRelayers[43114] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // Avalanche
        wormholeRelayers[8453] = address(
            0x706F82e9bb5b0813501714Ab5974216704980e31
        ); // Base Mainnet
        wormholeRelayers[81457] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // Blast Mainnet
        wormholeRelayers[56] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // BNB Mainnet
        wormholeRelayers[42220] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // Celo Mainnet
        wormholeRelayers[250] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // Fantom Mainnet
        wormholeRelayers[8217] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // Kaia Mainnet
        wormholeRelayers[5000] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // Mantle Mainnet
        wormholeRelayers[1284] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // Moonbeam Mainnet
        wormholeRelayers[10] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // OP Mainnet
        wormholeRelayers[137] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // Polygon Mainnet
        wormholeRelayers[534352] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // Scroll Mainnet
        wormholeRelayers[2192] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // SNAXchain Mainnet
        wormholeRelayers[480] = address(
            0x1520cC9e779c56dab5866BEbFb885C86840c33d3
        ); // World Chain Mainnet
        wormholeRelayers[196] = address(
            0x27428DD2d3DD32A4D7f7C497eAaa23130d894911
        ); // X Layer Mainnet

        wormholeRelayer = IWormholeRelayer(wormholeRelayers[block.chainid]);
    }

    /*
        ---------------------------------------------------------
        Wormhole Implementation
        ---------------------------------------------------------
    */

    function quoteWormholeCrossChainCost(
        uint16 targetChain
    ) public view returns (uint256 cost) {
        (cost, ) = wormholeRelayer.quoteEVMDeliveryPrice(
            targetChain,
            0,
            GAS_LIMIT
        );
    }

    // Initiates a Cross-Chain Bridge Txn - moves tokens across chains
    function sendWormholeCrossChainBridge(
        uint16 targetChain,
        uint256 amount
    ) external payable {
        uint256 cost = quoteWormholeCrossChainCost(targetChain); // Dynamically calculate the cross-chain cost
        address owner = msg.sender;

        require(
            msg.value >= cost,
            "Insufficient funds for cross-chain delivery"
        );

        // Burns the tokens from the sender's account balance.
        _burn(owner, amount);

        wormholeRelayer.sendPayloadToEvm{value: cost}(
            targetChain,
            address(this),
            abi.encode(amount, owner), // Payload contains the message and sender address
            0, // No receiver value needed
            GAS_LIMIT // Gas limit for the transaction
        );
    }

    // Modifier to check if the sender is registered for the source chain
    modifier isRegisteredSender(bytes32 sourceAddress) {
        require(
            bytes32(uint256(uint160(address(this)))) == sourceAddress,
            "Not registered sender"
        );
        _;
    }

    // Update receiveWormholeMessages to include the source address check
    function receiveWormholeMessages(
        bytes memory payload,
        bytes[] memory, // additional VAAs (optional, not needed here)
        bytes32 sourceAddress,
        uint16 sourceChain,
        bytes32 // delivery hash
    ) public payable isRegisteredSender(sourceAddress) {
        require(
            msg.sender == address(wormholeRelayer),
            "Only the Wormhole relayer can call this function"
        );

        // Decode the payload to extract the message
        (uint256 amount, address owner) = abi.decode(
            payload,
            (uint256, address)
        );

        // Mints tokens to the sender's wallet on the destination chain
        _mint(owner, amount);

        // Emit an event with the received message
        emit CrossChainReceived(amount, owner, sourceChain);
    }

    /*
        ---------------------------------------------------------
        Flash Loan Implementation
        ---------------------------------------------------------
    */

    // Override the _flashFee function to set a custom fee
    function _flashFee(
        address token,
        uint256 amount
    ) internal view virtual override returns (uint256) {
        require(token == address(this), "ERC20FlashMint: Unsupported token");
        return
            amount > FLASH_FEE_MIN_THRESHOLD
                ? (amount * FLASH_FEE_BASIS_POINTS) / 10000
                : FLASH_FEE_MIN; // 0.01% fee or min
    }

    // --------------------------------------------
    // Modifier to check if mining is allowed
    // --------------------------------------------
    modifier onlyAllowedChain() {
        require(
            allowedChains[block.chainid],
            "Mining not allowed on this chain"
        );
        _;
    }

    /*
        ---------------------------------------------------------
        Proof-of-Work Minting
        ---------------------------------------------------------
    */

    function mint(
        uint256 nonce,
        bytes32
    ) external onlyAllowedChain returns (bool success) {
        return mintTo(nonce, msg.sender);
    }

    function mintTo(
        uint256 nonce,
        address minter
    ) public onlyAllowedChain returns (bool success) {
        // PoW requirement: digest = keccak256(challengeNumber, minter, nonce)
        if (
            totalSupply() + currentMiningReward <
            MAX_LIMIT - currentMiningReward
        ) {
            bytes32 digest = keccak256(
                abi.encodePacked(challengeNumber, minter, nonce)
            );
            require(uint256(digest) <= miningTarget, "Digest exceeds target");
            require(
                lastRewardEthBlockNumber != block.number,
                "Already rewarded in this block"
            );

            _mint(minter, currentMiningReward);
            tokensMinted += currentMiningReward;

            lastRewardTo = minter;
            lastRewardAmount = currentMiningReward;
            lastRewardEthBlockNumber = block.number;

            _startNewMiningEpoch();
            emit Mint(minter, currentMiningReward, epochCount, challengeNumber);
            return true;
        } else {
            return false;
        }
    }

    function _startNewMiningEpoch() internal {
        // ---------------------------------------------------------
        // TIME-BASED HALVING: Check if 6-month interval has passed
        // ---------------------------------------------------------
        if (block.timestamp >= nextHalvingTime) {
            rewardEra++;
            // Recalculate the halved reward
            uint256 calculatedReward = (896 * 10 ** decimals()) /
                (2 ** rewardEra);

            // Hard-limit the reward to a minimum of 7 * 10^decimals()
            if (calculatedReward < 7 * 10 ** decimals()) {
                rewardEra--;
                currentMiningReward = 7 * 10 ** decimals();
            } else {
                currentMiningReward = calculatedReward;
            }

            // Set the next halving time to an additional 6 months
            nextHalvingTime += HALVING_PERIOD;

            emit RewardUpdated(currentMiningReward, rewardEra);
        }

        if (epochCount >= MAX_LIMIT) {
            epochCount = 0; // Reset epochCount to zero
        } else {
            epochCount++; // Increment epochCount
        }

        // Difficulty readjustment
        if (epochCount % _BLOCKS_PER_READJUSTMENT == 0) {
            uint ethBlocksSinceLastDifficultyPeriod = block.number -
                latestDifficultyPeriodStarted;
            _reAdjustDifficulty(ethBlocksSinceLastDifficultyPeriod);
        }

        // New challenge number
        challengeNumber = blockhash(block.number - 1);
        emit NewEpochStarted(epochCount, challengeNumber);
    }

    function _reAdjustDifficulty(
        uint ethBlocksSinceLastDifficultyPeriod
    ) internal {
        uint targetEthBlocksPerDiffPeriod = _BLOCKS_PER_READJUSTMENT * 60;

        if (ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod) {
            uint excess_block_pct = (targetEthBlocksPerDiffPeriod * 100) /
                ethBlocksSinceLastDifficultyPeriod;
            uint excess_block_pct_extra = (excess_block_pct - 100)
                .limitLessThan(1000);
            miningTarget =
                miningTarget -
                ((miningTarget / 2000) * excess_block_pct_extra);
        } else {
            uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod *
                100) / targetEthBlocksPerDiffPeriod;
            uint shortage_block_pct_extra = (shortage_block_pct - 100)
                .limitLessThan(1000);
            miningTarget =
                miningTarget +
                ((miningTarget / 2000) * shortage_block_pct_extra);
        }

        latestDifficultyPeriodStarted = block.number;

        if (miningTarget < _MINIMUM_TARGET) {
            miningTarget = _MINIMUM_TARGET;
        }
        if (miningTarget > _MAXIMUM_TARGET) {
            miningTarget = _MAXIMUM_TARGET;
        }

        emit DifficultyAdjusted(
            miningTarget,
            (_MAXIMUM_TARGET / miningTarget),
            ethBlocksSinceLastDifficultyPeriod
        );
    }

    /*
        ---------------------------------------------------------
        Public Getters (Difficulty, Targets, Supply, etc.)
        ---------------------------------------------------------
    */
    function getChallengeNumber() external view returns (bytes32) {
        return challengeNumber;
    }

    function getMiningDifficulty() external view returns (uint) {
        return _MAXIMUM_TARGET / miningTarget;
    }

    function getMiningTarget() external view returns (uint) {
        return miningTarget;
    }

    function minedSupply() external view returns (uint) {
        return tokensMinted;
    }

    /*
        ---------------------------------------------------------
        Superchain
        ---------------------------------------------------------
    */
    /// @notice Allows the SuperchainTokenBridge to mint tokens.
    /// @param _to     Address to mint tokens to.
    /// @param _amount Amount of tokens to mint.
    function crosschainMint(address _to, uint256 _amount) external {
        // Only the `SuperchainTokenBridge` has permissions to mint tokens during crosschain transfers.
        if (msg.sender != Predeploys.SUPERCHAIN_TOKEN_BRIDGE)
            revert Unauthorized();

        // Mint tokens to the `_to` account's balance.
        _mint(_to, _amount);

        // Emit the CrosschainMint event included on IERC7802 for tracking token mints
        emit CrosschainMint(_to, _amount, msg.sender);
    }

    /// @notice Allows the SuperchainTokenBridge to burn tokens.
    /// @param _from   Address to burn tokens from.
    /// @param _amount Amount of tokens to burn.
    function crosschainBurn(address _from, uint256 _amount) external {
        // Only the `SuperchainTokenBridge` has permissions to burn tokens during crosschain transfers.
        if (msg.sender != Predeploys.SUPERCHAIN_TOKEN_BRIDGE)
            revert Unauthorized();

        // Burn the tokens from the `_from` account's balance.
        _burn(_from, _amount);

        // Emit the CrosschainBurn event included on IERC7802 for tracking token burns
        emit CrosschainBurn(_from, _amount, msg.sender);
    }

    /// IERC165
    function supportsInterface(
        bytes4 _interfaceId
    ) public view virtual returns (bool) {
        return
            _interfaceId == type(IERC7802).interfaceId ||
            _interfaceId == type(IERC20).interfaceId ||
            _interfaceId == type(IERC165).interfaceId;
    }

    /*
        ---------------------------------------------------------
        Fallback: Reject ETH
        ---------------------------------------------------------
    */
    receive() external payable {
        revert("No direct ETH deposits");
    }
}
