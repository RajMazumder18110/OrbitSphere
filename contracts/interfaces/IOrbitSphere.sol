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

    /// @notice Emitted when a new server instance is rented.
    event OrbitSphereInstanceRented(
        /// @notice Instance details ///
        /// @param region The AWS region where the instance is rented.
        bytes32 indexed region,
        /// @param nftId The unique NFT ID representing the rented instance.
        uint256 indexed nftId,
        /// @param instanceType The type of AWS instance rented.
        bytes32 indexed instanceType,
        /// @param sshPublicKey The SSH public key provided by the tenant for secure access.
        bytes sshPublicKey,
        /// @param rentedOn The timestamp when the instance was rented.
        uint128 rentedOn,
        /// @param willBeEndOn The timestamp when the rental period will end.
        uint128 willBeEndOn,
        /// @notice Tenant details ///
        /// @param tenant The address of the tenant renting the instance.
        address tenant,
        /// @param totalCost The total cost paid for the rental.
        uint256 totalCost,
        /// @param costPerHour The hourly price of the rented instance.
        uint256 costPerHour
    );

    /// @notice Emitted when a rented OrbitSphere instance is terminated.
    event OrbitSphereInstanceTerminated(
        /// @param tenant The address of the user who rented the instance.
        address indexed tenant,
        /// @param nftId The NFT ID representing the rented instance.
        uint256 indexed nftId,
        /// @param actualCost The final cost incurred by the tenant based on usage.
        uint256 actualCost,
        /// @param timeConsumed The total time (in seconds) the instance was used.
        uint256 timeConsumed,
        /// @param refundAmount The amount refunded to the tenant, if applicable.
        uint256 refundAmount
    );

    /// @notice Emitted when a rented OrbitSphere instance is temporarily stopped.
    event OrbitSphereInstanceStopped(
        /// @param nftId The NFT ID representing the rented instance.
        uint256 indexed nftId,
        /// @param tenant The address of the user who rented the instance.
        address indexed tenant
    );

    /** @notice CUSTOM ERRORS */

    /// @notice Error thrown when transfers are not allowed.
    error OrbitSphere__TransfersNotAllowed();

    /// @dev Thrown when the provided AWS region is not available or inactive.
    /// @param region The unavailable AWS region provided by the user.
    error OrbitSphere__UnavailableRegion(bytes32 region);

    /// @dev Thrown when the requested instance type is not available.
    /// @param instanceType The unavailable instance type requested by the user.
    error OrbitSphere__UnavailableInstanceType(bytes32 instanceType);

    /// @dev Thrown when the rental duration is below the required minimum.
    /// @param provided The duration (in seconds) provided by the user.
    /// @param required The minimum rental duration (in seconds) required.
    error OrbitSphere__RentalDurationTooShort(
        uint256 provided,
        uint256 required
    );
}
