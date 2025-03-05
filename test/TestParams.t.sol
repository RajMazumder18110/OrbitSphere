// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Local imports
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";
import {AWSRegions, AWSInstanceTypes} from "@OrbitSphere-contracts/lib/AWSConstants.sol";

library TestParams {
    function getMockRegionParams()
        public
        pure
        returns (bytes32[] memory regions)
    {
        /// Prepare
        regions = new bytes32[](1);
        regions[0] = AWSRegions.ASIA_MUMBAI;
    }

    function getMockInstanceTypeParams()
        public
        pure
        returns (IOrbitSphere.InstanceMetadata[] memory instances)
    {
        /// Prepare
        instances = new IOrbitSphere.InstanceMetadata[](2);
        instances[0] = AWSInstanceTypes.getInstanceInfo(
            AWSInstanceTypes.T2_MICRO
        );
        instances[1] = AWSInstanceTypes.getInstanceInfo(
            AWSInstanceTypes.T2_SMALL
        );
    }
}
