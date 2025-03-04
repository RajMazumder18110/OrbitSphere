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
            emit AWSRegionAdded(region);

            /// Gas optimization
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Adds multiple AWS instance types to the list of supported instance types.
     * @dev Updates the `s_awsInstanceTypes` set to include new instance types.
     * - Only the contract owner can call this function.
     * @param instanceTypes An array of bytes32 values representing the AWS instance types to be added.
     */
    function addInstanceTypes(
        bytes32[] calldata instanceTypes
    ) public onlyOwner {
        for (uint i; i < instanceTypes.length; ) {
            /// @dev Adding into `s_awsInstanceTypes`
            bytes32 instanceType = instanceTypes[i];
            s_awsInstanceTypes.add(instanceType);
            emit AWSInstanceTypeAdded(instanceType);

            /// Gas optimization
            unchecked {
                ++i;
            }
        }
    }
}
