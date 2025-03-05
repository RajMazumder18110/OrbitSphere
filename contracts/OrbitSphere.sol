// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
/// @notice Local imports
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";

contract OrbitSphere is IOrbitSphere, Ownable, ERC721 {
    /// @notice Using libraries
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /// @notice Stores the list of supported AWS regions for server rentals
    /// to efficiently manage and check available regions.
    EnumerableSet.Bytes32Set private s_awsRegions;

    /// @notice Stores the list of supported AWS instance types for rentals.
    /// Uses EnumerableSet to efficiently manage and check available instance types.
    EnumerableSet.Bytes32Set private s_awsInstanceTypes;

    /// @notice Stores the contract instance of the Tether USD (USDT) token.
    /// Used for handling payments and transactions within the platform.
    IERC20Metadata public immutable TETHER_USD;

    /// @notice Stores metadata for each AWS instance type.
    /// Maps an instance type identifier to its corresponding metadata.
    mapping(bytes32 instanceType => InstanceMetadata metadata)
        private s_instanceTypeMetadata;

    /// @notice Mapping to store token IDs held by each address.
    /// @dev Uses UintSet to efficiently manage address-to-tokenID relationships.
    /// Stores token IDs mapped to their respective owners.
    mapping(address holder => EnumerableSet.UintSet metadata)
        private s_tokenIdsByHolder;

    /**
     * @notice Deploys the OrbitSphere contract and initializes the ERC721 token.
     * @dev Sets the name and symbol of the ERC721 token, Ownership and initializes the USDT contract.
     * @param tetherUSD The address of the Tether USD (USDT) token contract.
     */
    constructor(
        address tetherUSD
    ) Ownable(_msgSender()) ERC721("OrbitSphere", "ORBIT") {
        /// @notice Initializing Tether USD (USDT)
        TETHER_USD = IERC20Metadata(tetherUSD);
    }

    /** @notice READ METHODS */
    function getTokenIdsByHolder(
        address holder
    ) public view returns (uint256[] memory ids) {
        return s_tokenIdsByHolder[holder].values();
    }

    /**
     * @notice Checks if a given AWS region is supported for server rentals.
     * @param region The AWS region to check, represented as a bytes32 value.
     * @return bool True if the region is supported, false otherwise.
     */
    function isActiveRegion(bytes32 region) public view returns (bool) {
        return s_awsRegions.contains(region);
    }

    /**
     * @notice Checks if a given AWS instance type is supported for server rentals.
     * @param instanceType The AWS instance type to check, represented as a bytes32 value.
     * @return bool True if the instance type is supported, false otherwise.
     */
    function isActiveInstanceType(
        bytes32 instanceType
    ) public view returns (bool) {
        return s_awsInstanceTypes.contains(instanceType);
    }

    /**
     * @notice Retrieves metadata for a given AWS instance type.
     * @param instanceType The identifier of the instance type.
     * @return metadata The metadata associated with the specified instance type.
     */
    function getInstanceTypeInfo(
        bytes32 instanceType
    ) public view returns (InstanceMetadata memory metadata) {
        return s_instanceTypeMetadata[instanceType];
    }

    /**
     * @notice Retrieves the list of all active AWS regions supported for server rentals.
     * @return regions An array of bytes32 values representing the supported AWS regions.
     */
    function getActiveRegions() public view returns (bytes32[] memory regions) {
        return s_awsRegions.values();
    }

    /**
     * @notice Retrieves the list of all active AWS instance types supported for server rentals.
     * @return instanceTypes An array of bytes32 values representing the supported AWS instance types.
     */
    function getActiveInstanceTypes()
        public
        view
        returns (bytes32[] memory instanceTypes)
    {
        return s_awsInstanceTypes.values();
    }

    /** @notice WRITE METHODS */
    /**
     * @notice Adds multiple AWS regions to the list of supported regions.
     * @dev Updates the `s_awsRegions` set to include new regions.
     * - Only the contract owner can call this function.
     * @param regions An array of bytes32 values representing the AWS regions to be added.
     */
    function addRegions(bytes32[] calldata regions) public onlyOwner {
        for (uint i; i < regions.length; ) {
            /// @dev Adding into `s_awsRegions`
            bytes32 region = regions[i];
            s_awsRegions.add(region);
            /// @dev Emitting `AWSRegionAdded` event.
            emit AWSRegionAdded(region);

            /// Gas optimization
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Removes specified AWS regions from the list of active regions.
     * @dev Only the contract owner can call this function.
     *  - Emits AWSRegionRemoved when a region is successfully removed.
     * @param regions The array of region identifiers to be removed.
     */
    function removeRegions(bytes32[] calldata regions) public onlyOwner {
        for (uint i; i < regions.length; ) {
            /// @dev Removing from `s_awsRegions`
            bytes32 region = regions[i];
            s_awsRegions.remove(region);
            /// @dev Emitting `AWSRegionRemoved` event.
            emit AWSRegionRemoved(region);

            /// Gas optimization
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice  Adds multiple AWS instance types along with their metadata.
     * @dev Updates the `s_awsInstanceTypes` set to include new instance types.
     * @dev Stores instance metadata and tracks available instance types.
     * - Only the contract owner can call this function.
     * @param instanceTypes An array of `InstanceMetadata` containing details of instance types.
     */
    function addInstanceTypes(
        InstanceMetadata[] calldata instanceTypes
    ) public onlyOwner {
        for (uint i; i < instanceTypes.length; ) {
            /// @dev Caching
            InstanceMetadata memory metadata = instanceTypes[i];
            /// @dev Adding instanceType into `s_awsInstanceTypes`
            s_awsInstanceTypes.add(metadata.iType);
            /// @dev Adding instance info into `s_instanceTypeMetadata`.
            s_instanceTypeMetadata[metadata.iType] = metadata;
            /// @dev Emitting `AWSInstanceTypeAdded` event.
            emit AWSInstanceTypeAdded(metadata.iType);

            /// Gas optimization
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Removes specified AWS instance types from the list of active instances.
     * @dev Only the contract owner can call this function.
     *  - Emits AWSInstanceTypeRemoved when an instance type is successfully removed.
     * @param instanceTypes The array of instance type identifiers to be removed.
     */
    function removeInstanceTypes(
        bytes32[] calldata instanceTypes
    ) public onlyOwner {
        for (uint i; i < instanceTypes.length; ) {
            /// @dev Caching
            bytes32 instanceType = instanceTypes[i];
            /// @dev Removing instanceType from `s_awsInstanceTypes`
            s_awsInstanceTypes.remove(instanceType);
            /// @dev Removing instance info from `s_instanceTypeMetadata`.
            delete s_instanceTypeMetadata[instanceType];
            /// @dev Emitting `AWSInstanceTypeRemoved` event.
            emit AWSInstanceTypeRemoved(instanceType);

            /// Gas optimization
            unchecked {
                ++i;
            }
        }
    }

    /** @notice PREVENTION METHODS */
    /// @notice Overrides the ERC721 transfer function to prevent token transfers.
    function transferFrom(address, address, uint256) public virtual override {
        revert OrbitSphere__TransfersNotAllowed();
    }
}
