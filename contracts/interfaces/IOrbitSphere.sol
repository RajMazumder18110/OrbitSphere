// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IOrbitSphere {
    /** @notice STRUCTS */

    /// @notice Represents metadata for an AWS instance type.
    struct InstanceMetadata {
        /// @param iType The identifier for the instance type.
        bytes32 iType;
        /// @param hourlyRate The hourly rental cost of the instance.
        uint64 hourlyRate;
        /// @param noOfCPUs The number of CPU cores available in the instance.
        uint16 noOfCPUs;
        /// @param noOfGPUs The number of GPUs available in the instance.
        uint16 noOfGPUs;
        /// @param memoryGBs The total memory (RAM) available in the instance, in gigabytes.
        uint32 memoryGBs;
    }

    /** @notice EVENTS */

    /// @notice Emitted when a new AWS region is added.
    /// @param region The AWS region that was added.
    event AWSRegionAdded(bytes32 indexed region);

    /// @notice Emitted when a new AWS region is removed.
    /// @param region The AWS region that was removed.
    event AWSRegionRemoved(bytes32 indexed region);

    /// @notice Emitted when a new AWS instance type is added.
    /// @param instanceType The AWS instance type that was added.
    event AWSInstanceTypeAdded(bytes32 indexed instanceType);

    /// @notice Emitted when a new AWS instance type is removed.
    /// @param instanceType The AWS instance type that was removed.
    event AWSInstanceTypeRemoved(bytes32 indexed instanceType);

    /** @notice CUSTOM ERRORS */
    /// @notice Error thrown when transfers are not allowed.
    error OrbitSphere__TransfersNotAllowed();
}
