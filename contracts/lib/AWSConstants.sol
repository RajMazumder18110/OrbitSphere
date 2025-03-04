// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

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
}
