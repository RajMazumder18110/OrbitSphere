// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Script} from "forge-std/Script.sol";
/// @notice Local imports
import {OrbitSphere} from "@OrbitSphere-contracts/OrbitSphere.sol";
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";
import {NetworkConfigs, Config} from "@OrbitSphere-scripts/NetworkConfigs.s.sol";
import {AWSRegions, AWSInstanceTypes} from "@OrbitSphere-contracts/lib/AWSConstants.sol";

contract OrbitSphereDeploy is Script {
    /**
     * @notice Deploys the `OrbitSphere` contract using the active network configuration.
     * @return sphere The deployed `OrbitSphere` contract instance.
     */
    function run() external returns (OrbitSphere sphere) {
        /// @notice Initializes the contract by fetching the active network configuration.
        /// @dev Creates an instance of `NetworkConfigs` and assigns the active configuration to `configs`.
        NetworkConfigs networkConfigs = new NetworkConfigs();
        Config memory configs = networkConfigs.getActiveChainConfigs();

        /// @notice Preparing regions
        bytes32[] memory regions = new bytes32[](1);
        regions[0] = AWSRegions.ASIA_MUMBAI;

        /// @notice Preparing instance types
        IOrbitSphere.InstanceMetadata[]
            memory instances = new IOrbitSphere.InstanceMetadata[](1);
        instances[0] = AWSInstanceTypes.getInstanceInfo(
            AWSInstanceTypes.T2_MICRO
        );

        /// @notice Starting transaction
        vm.startBroadcast();
        /// @notice Deploying OrbitSphere
        sphere = new OrbitSphere(configs.tetherUSD);

        /// @notice Adding region
        sphere.addRegions(regions);
        /// @notice Adding instance types
        sphere.addInstanceTypes(instances);

        /// @notice Ending transaction
        vm.stopBroadcast();
    }
}
