// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {ERC721, IERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IERC165, ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {AccessControl, IAccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
/// @notice Local imports
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";

contract OrbitSphere is IOrbitSphere, AccessControl, ERC721 {
    /// @notice Using libraries
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /// @notice Roles for OrbitSphere
    bytes32 public constant ORBIT_SPHERE_MANAGER =
        keccak256("ORBIT_SPHERE_MANAGER");
    bytes32 public constant ORBIT_SPHERE_TERMINATOR =
        keccak256("ORBIT_SPHERE_TERMINATOR");

    /// @notice OrbitSphere deployer.
    /// Used for handling payments and transactions within the platform.
    address public immutable ORBIT_SPHERE_DEPLOYER;

    /// @notice Stores the contract instance of the Tether USD (USDT) token.
    /// Used for handling payments and transactions within the platform.
    IERC20Metadata public immutable TETHER_USD;

    /// @notice Counter for tracking the total number of rented OrbitSphere instances.
    /// @dev This variable increments with each new rental and represents the latest Sphere ID.
    uint256 private s_sphereIds;

    /// @notice Stores the list of supported AWS regions for server rentals
    /// to efficiently manage and check available regions.
    EnumerableSet.Bytes32Set private s_awsRegions;

    /// @notice Stores the list of supported AWS instance types for rentals.
    /// Uses EnumerableSet to efficiently manage and check available instance types.
    EnumerableSet.Bytes32Set private s_awsInstanceTypes;

    /// @notice Mapping to store token IDs held by each address.
    /// @dev Uses UintSet to efficiently manage address-to-sphereId relationships.
    /// Stores sphere IDs mapped to their respective owners.
    mapping(address tenant => EnumerableSet.UintSet metadata)
        private s_sphereIdsByTenant;

    /// @notice Stores metadata for each AWS instance type.
    /// Maps an instance type identifier to its corresponding metadata.
    mapping(bytes32 instanceType => InstanceMetadata metadata)
        private s_instanceTypeMetadata;

    /// @notice Stores metadata for each rented OrbitSphere instance.
    /// @dev Maps a unique sphere ID to its corresponding `SphereMetadata` struct.
    mapping(uint256 sphereId => SphereMetadata metadata)
        private s_sphereMetadata;

    /** @notice MODIFIERS */
    /**
     * @dev Ensures that the caller is the tenant of the specified OrbitSphere instance.
     *  - Reverts with `OrbitSphere__UnauthorizedTenant` if the caller is not the owner.
     * @param sphereId The ID of the rented OrbitSphere instance.
     */
    modifier onlyTenant(uint256 sphereId) {
        if (ownerOf(sphereId) != _msgSender())
            revert OrbitSphere__UnauthorizedTenant();
        _;
    }

    /**
     * @notice Deploys the OrbitSphere contract and initializes the ERC721 token.
     * @dev Sets the name and symbol of the ERC721 token, Ownership and initializes the USDT contract.
     * @param tetherUSD The address of the Tether USD (USDT) token contract.
     */
    constructor(address tetherUSD) ERC721("OrbitSphere", "ORBIT") {
        /// Assinging roles
        address owner = _msgSender();
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(ORBIT_SPHERE_MANAGER, owner);
        _grantRole(ORBIT_SPHERE_TERMINATOR, owner);

        /// @notice Initializing Tether USD (USDT) & deployer
        ORBIT_SPHERE_DEPLOYER = owner;
        TETHER_USD = IERC20Metadata(tetherUSD);
    }

    /** @notice READ METHODS */
    /**
     * @notice Returns the minimum rental duration for an OrbitSphere instance.
     * @dev The minimum duration is set to 10 minutes.
     * @return The minimum rental duration in seconds.
     */
    function getMinRentalDuration() public pure returns (uint256) {
        return 10 minutes;
    }

    /**
     * @notice Retrieves the list of Sphere IDs rented by a specific tenant.
     * @dev Uses an enumerable set to efficiently return all Sphere IDs associated with the given tenant.
     * @param holder The address of the tenant whose rented Sphere IDs are being queried.
     * @return ids An array of Sphere IDs associated with the specified tenant.
     */
    function getSphereIdsByTenant(
        address holder
    ) public view returns (uint256[] memory ids) {
        return s_sphereIdsByTenant[holder].values();
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

    /**
     * @notice Retrieves metadata for a rented OrbitSphere instance.
     * @param sphereId The unique ID representing the rented OrbitSphere instance.
     * @return sphere The metadata containing details of the rented OrbitSphere instance.
     */
    function getOrbitSphereInfo(
        uint256 sphereId
    ) public view returns (SphereMetadata memory sphere) {
        return s_sphereMetadata[sphereId];
    }

    /**
     * @notice Retrieves metadata for a rented OrbitSphere instance and its instance type details.
     * @param sphereId The unique ID representing the rented OrbitSphere instance.
     * @return sphere The metadata containing details of the rented OrbitSphere instance.
     * @return instance The metadata containing instance type specifications.
     */
    function getOrbitSphereInfoWithInstance(
        uint256 sphereId
    )
        public
        view
        returns (SphereMetadata memory sphere, InstanceMetadata memory instance)
    {
        sphere = s_sphereMetadata[sphereId];
        instance = getInstanceTypeInfo(sphere.instanceType);
    }

    /**
     * @notice Calculates the total cost of renting an OrbitSphere instance for a given duration.
     * @dev Retrieves the hourly rate of the specified instance type and computes the cost based on the rental duration.
     * @param instanceType The type of instance to be rented.
     * @param rentingForNoOfSeconds The total duration (in seconds) for which the instance will be rented.
     * @return usdCost The total rental cost in USD.
     */
    function getOrbitSphereInstanceCost(
        bytes32 instanceType,
        uint256 rentingForNoOfSeconds
    ) public view returns (uint256 usdCost) {
        /// @notice Incase if the instance type not available or minimum rental duration doesn't meet.
        if (
            !isActiveInstanceType(instanceType) ||
            rentingForNoOfSeconds < getMinRentalDuration()
        ) return 0;

        /// @notice Caching instance metadata.
        InstanceMetadata memory metadata = s_instanceTypeMetadata[instanceType];
        return (metadata.hourlyRate * rentingForNoOfSeconds) / 1 hours;
    }

    /** @notice WRITE METHODS */
    /**
     * @notice Adds multiple AWS regions to the list of supported regions.
     * @dev Updates the `s_awsRegions` set to include new regions.
     * - Only the OrbitSphere managers can call this function.
     * @param regions An array of bytes32 values representing the AWS regions to be added.
     */
    function addRegions(
        bytes32[] calldata regions
    ) public onlyRole(ORBIT_SPHERE_MANAGER) {
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
     * @dev Only the OrbitSphere managers can call this function.
     *  - Emits AWSRegionRemoved when a region is successfully removed.
     * @param regions The array of region identifiers to be removed.
     */
    function removeRegions(
        bytes32[] calldata regions
    ) public onlyRole(ORBIT_SPHERE_MANAGER) {
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
     * - Only the OrbitSphere managers can call this function.
     * @param instanceTypes An array of `InstanceMetadata` containing details of instance types.
     */
    function addInstanceTypes(
        InstanceMetadata[] calldata instanceTypes
    ) public onlyRole(ORBIT_SPHERE_MANAGER) {
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
     * @dev Only the OrbitSphere managers can call this function.
     *  - Emits AWSInstanceTypeRemoved when an instance type is successfully removed.
     * @param instanceTypes The array of instance type identifiers to be removed.
     */
    function removeInstanceTypes(
        bytes32[] calldata instanceTypes
    ) public onlyRole(ORBIT_SPHERE_MANAGER) {
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

    /**
     * @notice Allows a user to rent an OrbitSphere instance in a specified AWS region.
     * @dev The function validates availability, processes payment, and emits an event upon successful rental.
     * @param region The AWS region where the instance will be deployed.
     * @param instanceType The type of AWS instance to rent.
     * @param rentalDuration The total duration (in seconds) for which the instance will be rented.
     * @param sshPublicKey The SSH public key for accessing the rented instance.
     */
    function rentSphere(
        bytes32 region,
        bytes32 instanceType,
        uint256 rentalDuration,
        bytes calldata sshPublicKey
    ) public {
        /// @notice Parameter Validation
        if (!isActiveRegion(region))
            revert OrbitSphere__UnavailableRegion(region);
        if (!isActiveInstanceType(instanceType))
            revert OrbitSphere__UnavailableInstanceType(instanceType);

        uint256 minimumRentalDuration = getMinRentalDuration();
        if (rentalDuration < minimumRentalDuration)
            revert OrbitSphere__RentalDurationTooShort(
                rentalDuration,
                minimumRentalDuration
            );

        /// @notice Calculating rental cost and transfer from tenant.
        uint256 totalInstanceRentalCost = getOrbitSphereInstanceCost(
            instanceType,
            rentalDuration
        );
        _doTetherUSDTransaction(
            address(this),
            totalInstanceRentalCost,
            TransactionType.TRANSFER_FROM
        );

        address tenant = _msgSender();
        uint256 sphereId = ++s_sphereIds;
        /// @notice Referencing sphere with sphereId.
        SphereMetadata storage newSphere = s_sphereMetadata[sphereId];
        /// @dev Calculating timestamps
        uint256 startedOn = block.timestamp;
        uint256 willTerminateOn = startedOn + rentalDuration;

        /// @dev Adding details into new sphere.
        newSphere.tenant = tenant;
        newSphere.region = region;
        newSphere.sphereId = sphereId;
        newSphere.rentedOn = startedOn;
        newSphere.instanceType = instanceType;
        newSphere.willBeEndOn = willTerminateOn;
        newSphere.terminatedOn = willTerminateOn;
        newSphere.status = OrbitSphereStatus.RUNNING;
        newSphere.totalUsdPaid = totalInstanceRentalCost;

        /// @notice Minting OrbitSphere NFT to `tenant` and add sphereId to tenant.
        _mint(tenant, sphereId);
        s_sphereIdsByTenant[tenant].add(sphereId);

        /// @notice Emitting `OrbitSphereInstanceRented` event.
        emit OrbitSphereInstanceRented(
            region,
            sphereId,
            instanceType,
            sshPublicKey,
            startedOn,
            willTerminateOn,
            tenant,
            totalInstanceRentalCost
        );
    }

    /**
     * @notice The instance will be marked as terminated, and any applicable refunds will be processed.
     * @dev Terminates a rented OrbitSphere instance.
     *  the internal `_terminate` function effectively shutting down expired instance.
     *  - Can only be called by the tenant who owns the instance.
     * @param sphereId The ID of the rented OrbitSphere instance to be terminated.
     */
    function terminateSphere(uint256 sphereId) public onlyTenant(sphereId) {
        /// @dev Terminate the sphere.
        _terminate(sphereId);
    }

    /**
     * @notice Terminates expired server instances associated with given sphere IDs.
     * @dev This function iterates through the provided array of sphere IDs and calls
     *      the internal `_terminate` function for each, effectively shutting down expired instances.
     * @param sphereIds An array of sphere IDs representing the instances to be terminated.
     * @custom:restriction Only the contract owner can call this function.
     */
    function forceTerminateSpheres(
        uint256[] memory sphereIds
    ) public onlyRole(ORBIT_SPHERE_TERMINATOR) {
        /// Caching
        uint256 len = sphereIds.length;
        for (uint i; i < len; ) {
            /// @dev Terminate sphere
            uint256 sphereId = sphereIds[i];
            _terminate(sphereId);

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

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, AccessControl) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /** @notice PRIVATE METHODS */
    /**
     * @notice Executes a specified MANTA token transaction for a given holder.
     * @dev Supports the following types of ERC-20 transactions:
     *      - Transferring tokens to the specified `holder`.
     *      - Transferring tokens from the caller to the specified `holder`.
     * @param receiver The address involved in the transaction.
     *        - For `TRANSFER`: The recipient of the tokens.
     *        - For `TRANSFER_FROM`: The address receiving tokens from the caller.
     * @param amount The amount of MANTA tokens involved in the transaction.
     * @param transactionType The type of transaction to execute:
     *        - `TRANSFER`: Transfers `amount` tokens to the `holder`.
     *        - `TRANSFER_FROM`: Transfers `amount` tokens from the caller to the `holder`.
     */
    function _doTetherUSDTransaction(
        address receiver,
        uint256 amount,
        TransactionType transactionType
    ) private {
        /// @notice TRANSFER`: Transfers `amount` tokens to the `receiver`.
        if (transactionType == TransactionType.TRANSFER) {
            SafeERC20.safeTransfer(TETHER_USD, receiver, amount);
        }
        /// @notice `TRANSFER_FROM`: Transfers `amount` tokens from the caller to the `receiver`.
        else if (transactionType == TransactionType.TRANSFER_FROM) {
            SafeERC20.safeTransferFrom(
                TETHER_USD,
                _msgSender(),
                receiver,
                amount
            );
        }
    }

    /**
     * @notice The instance will be marked as terminated, and any applicable refunds will be processed.
     * @dev Terminates a rented OrbitSphere instance.
     * @param sphereId The ID of the rented OrbitSphere instance to be terminated.
     */
    function _terminate(uint256 sphereId) private {
        /// @notice Referencing sphere with sphereId.
        SphereMetadata storage sphere = s_sphereMetadata[sphereId];
        address tenant = sphere.tenant;
        bool isTerminatingBefore = block.timestamp < sphere.willBeEndOn;

        /// @dev Default the refund amount.
        uint256 refundAmount = 0;
        /// @dev Default actual cost.
        uint256 actualCost = sphere.totalUsdPaid;
        /// @dev Calculating actual time consumed.
        uint256 timeConsumed = isTerminatingBefore
            ? (block.timestamp - sphere.rentedOn)
            : (sphere.willBeEndOn - sphere.rentedOn);

        /// @notice Incase if tenant terminating the instance before
        if (isTerminatingBefore) {
            /// @dev Updating actual cost.
            actualCost = getOrbitSphereInstanceCost(
                sphere.instanceType,
                timeConsumed
            );
            /// @dev Calculating the refund amount if any.
            refundAmount = sphere.totalUsdPaid - actualCost;

            /// @notice Transfer the refund to tenant.
            _doTetherUSDTransaction(
                tenant,
                refundAmount,
                TransactionType.TRANSFER
            );
        }

        /// @notice Burning OrbitSphere NFT from `tenant` and remove sphereId from tenant.
        _burn(sphereId);
        s_sphereIdsByTenant[tenant].remove(sphereId);

        /// @notice Update the sphere details.
        sphere.totalUsdPaid = actualCost;
        sphere.terminatedOn = sphere.willBeEndOn;
        sphere.status = OrbitSphereStatus.TERMINATED;

        /// @notice Emitting `OrbitSphereInstanceTerminated` event.
        emit OrbitSphereInstanceTerminated(
            tenant,
            sphereId,
            actualCost,
            timeConsumed,
            refundAmount
        );
    }
}
