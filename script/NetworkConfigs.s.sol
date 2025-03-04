// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Script} from "forge-std/Script.sol";
/// @notice Local imports
import {MockTetherUSD} from "@OrbitSphere-scripts/mocks/MockTetherUSD.sol";

/**
 * @notice Stores configuration details for a blockchain network.
 * @dev Contains essential contract addresses.
 */
struct Config {
    /// @param tetherUSDAddress of the Tether USD (USDT) contract for the network.
    address tetherUSD;
}

contract NetworkConfigs is Script {
    /// @notice Stores the currently active network configuration.
    Config private s_activeConfig;

    constructor() {
        if (block.chainid == 1) {
            s_activeConfig = getEthereumNetworkConfigs();
        }
        /// @notice Fallback to Anvil chain
        else {
            s_activeConfig = getAnvilNetworkConfigs();
        }
    }

    /** @notice READ METHODS */
    /**
     * @notice Returns the currently active network configuration.
     * @dev Fetches the `s_activeConfig` struct, which contains the contract addresses for the active blockchain network.
     * @return configs A `Config` struct with the active network settings.
     */
    function getActiveChainConfigs()
        public
        view
        returns (Config memory configs)
    {
        return s_activeConfig;
    }

    /**
     * @notice Returns the configuration settings for the Ethereum network.
     * @dev Provides the address of the Tether USD (USDT) contract on Ethereum.
     * @return config A `Config` struct containing the Ethereum network settings.
     */
    function getEthereumNetworkConfigs()
        private
        pure
        returns (Config memory config)
    {
        return Config({tetherUSD: 0xdAC17F958D2ee523a2206206994597C13D831ec7});
    }

    /** @notice WRITE METHODS */

    /**
     * @notice Deploys a mock Tether USD (USDT) contract and returns its configuration for the Anvil test environment.
     * @return config A `Config` struct containing the deployed mock USDT contract address.
     */
    function getAnvilNetworkConfigs() private returns (Config memory config) {
        /// @notice Starting transaction
        vm.startBroadcast();
        MockTetherUSD tether = new MockTetherUSD();
        /// @notice Ending transaction
        vm.stopBroadcast();

        return Config({tetherUSD: address(tether)});
    }
}
