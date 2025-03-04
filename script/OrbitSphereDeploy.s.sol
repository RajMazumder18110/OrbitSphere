// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Script} from "forge-std/Script.sol";
/// @notice Local imports
import {OrbitSphere} from "@OrbitSphere-contracts/OrbitSphere.sol";

contract OrbitSphereDeploy is Script {
    function run() external returns (OrbitSphere sphere) {
        /// @notice Starting transaction
        vm.startBroadcast();
        /// @notice Deploying OrbitSphere
        sphere = new OrbitSphere();
        /// @notice Ending transaction
        vm.stopBroadcast();
    }
}
