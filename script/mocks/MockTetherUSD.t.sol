// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Script} from "forge-std/Script.sol";
/// @notice Local imports
import {MockTetherUSD} from "./MockTetherUSD.sol";

contract MockTetherUSDDeployer is Script {
    /**
     * @notice Deploys the `MockTetherUSD` contract
     * @return tether The deployed `OrbitSphere` contract instance.
     */
    function run() external returns (MockTetherUSD tether) {
        /// @notice Starting transaction
        vm.startBroadcast();
        /// @notice Deploying MockTetherUSD
        tether = new MockTetherUSD();
        /// @notice Ending transaction
        vm.stopBroadcast();
    }
}
