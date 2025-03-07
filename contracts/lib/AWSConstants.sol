// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Local imports
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";

library AWSRegions {
    /// https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html
    bytes32 public constant ASIA_MUMBAI = bytes32("ap-south-1");
    bytes32 public constant US_CALIFORNIA = bytes32("us-west-1");
}

library AWSInstanceTypes {
    /// @notice t2 series. https://aws.amazon.com/ec2/instance-types/
    bytes32 public constant T2_MICRO = bytes32("t2.micro");
    bytes32 public constant T2_SMALL = bytes32("t2.small");
    bytes32 public constant T2_MEDIUM = bytes32("t2.medium");
    bytes32 public constant T2_LARGE = bytes32("t2.large");
    bytes32 public constant T2_XLARGE = bytes32("t2.xlarge");

    function getInstanceInfo(
        bytes32 instance
    ) internal pure returns (IOrbitSphere.InstanceMetadata memory info) {
        if (instance == T2_MICRO) {
            return
                IOrbitSphere.InstanceMetadata({
                    iType: T2_MICRO,
                    hourlyRate: 20000, // 0.02 USDT
                    noOfCPUs: 1,
                    noOfGPUs: 0,
                    memoryGBs: 1
                });
        } else if (instance == T2_SMALL) {
            return
                IOrbitSphere.InstanceMetadata({
                    iType: T2_SMALL,
                    hourlyRate: 30000, // 0.03 USDT
                    noOfCPUs: 1,
                    noOfGPUs: 0,
                    memoryGBs: 2
                });
        } else if (instance == T2_MEDIUM) {
            return
                IOrbitSphere.InstanceMetadata({
                    iType: T2_MEDIUM,
                    hourlyRate: 50000, // 0.05 USDT
                    noOfCPUs: 2,
                    noOfGPUs: 0,
                    memoryGBs: 4
                });
        } else if (instance == T2_LARGE) {
            return
                IOrbitSphere.InstanceMetadata({
                    iType: T2_LARGE,
                    hourlyRate: 120000, // 0.12 USDT
                    noOfCPUs: 2,
                    noOfGPUs: 0,
                    memoryGBs: 8
                });
        } else if (instance == T2_XLARGE) {
            return
                IOrbitSphere.InstanceMetadata({
                    iType: T2_XLARGE,
                    hourlyRate: 220000, /// 0.22 USDT
                    noOfCPUs: 4,
                    noOfGPUs: 0,
                    memoryGBs: 16
                });
        }
    }
}
