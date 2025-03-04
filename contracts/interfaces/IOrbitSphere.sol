// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IOrbitSphere {
    /** @notice EVENTS */
    /// @notice Emitted when a new AWS region is added.
    /// @param region The AWS region that was added.
    event AWSRegionAdded(bytes32 indexed region);

    /// @notice Emitted when a new AWS instance type is added.
    /// @param instanceType The AWS instance type that was added.
    event AWSInstanceTypeAdded(bytes32 indexed instanceType);
}
