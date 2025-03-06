// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Test, console} from "forge-std/Test.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
/// @notice Local imports
import {OrbitSphere} from "@OrbitSphere-contracts/OrbitSphere.sol";
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";
import {OrbitSphereDeploy} from "@OrbitSphere-scripts/OrbitSphereDeploy.s.sol";
import {AWSRegions, AWSInstanceTypes} from "@OrbitSphere-contracts/lib/AWSConstants.sol";

contract OrbitSphereRentingTest is Test, Context {
    /// @notice Stores the deployed `OrbitSphere` contract instance.
    OrbitSphere sphere;

    /**
     * @notice Deploys the `OrbitSphere` contract and assigns it to `sphere`.
     * @dev Uses `OrbitSphereDeploy` to handle the deployment.
     */
    function setUp() external {
        /// @notice Deploying OrbitSphere
        OrbitSphereDeploy orbiter = new OrbitSphereDeploy();
        sphere = orbiter.run();

        /// @notice Adding regions
        bytes32[] memory regions = new bytes32[](1);
        regions[0] = AWSRegions.ASIA_MUMBAI;

        vm.prank(_msgSender());
        sphere.addRegions(regions);

        /// @notice Adding instance types
        IOrbitSphere.InstanceMetadata[]
            memory instances = new IOrbitSphere.InstanceMetadata[](1);
        instances[0] = AWSInstanceTypes.getInstanceInfo(
            AWSInstanceTypes.T2_MICRO
        );

        vm.prank(_msgSender());
        sphere.addInstanceTypes(instances);
    }

    modifier afterServerRented() {
        /// @notice Calculating the rental cost
        uint256 rentalCost = sphere.getOrbitSphereInstanceCost(
            AWSInstanceTypes.T2_MICRO,
            1 hours
        );
        /// @notice Approving USDT
        vm.startPrank(_msgSender());
        sphere.TETHER_USD().approve(address(sphere), rentalCost);

        /// @notice Renting a server.
        sphere.rentOrbitSphereInstance(
            AWSRegions.ASIA_MUMBAI,
            AWSInstanceTypes.T2_MICRO,
            1 hours,
            bytes("MY SSH PUBLIC KEY")
        );
        vm.stopPrank();
        _;
    }

    modifier beforeServerRented() {
        /// @notice Calculating the rental cost
        uint256 rentalCost = sphere.getOrbitSphereInstanceCost(
            AWSInstanceTypes.T2_MICRO,
            1 hours
        );
        /// @notice Approving USDT
        vm.startPrank(_msgSender());
        sphere.TETHER_USD().approve(address(sphere), rentalCost);

        _;

        /// Action
        /// @notice Renting a server.
        sphere.rentOrbitSphereInstance(
            AWSRegions.ASIA_MUMBAI,
            AWSInstanceTypes.T2_MICRO,
            1 hours,
            bytes("MY SSH PUBLIC KEY")
        );
        vm.stopPrank();
    }

    /** @notice SUCCESS */
    function test__GetMinimumRentalDurationShouldBe10Minutes() public view {
        assertEq(sphere.getMinRentalDuration(), 10 minutes);
    }

    function test__GetAllActiveSphereIdsByTenant() public afterServerRented {
        /// Prepare
        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;

        /// Assert
        assertEq(sphere.getSphereIdsByTenant(_msgSender()), ids);
    }

    function test__TenantBalanceIsOneAfterRenting() public afterServerRented {
        assertEq(sphere.balanceOf(_msgSender()), 1);
    }

    function test__TheOwnerOfSphereIdOneShouldBeTenant()
        public
        afterServerRented
    {
        assertEq(sphere.ownerOf(1), _msgSender());
    }

    function test__ShouldReturnSphereInfoForSphereIdOne()
        public
        afterServerRented
    {
        /// Prepare
        uint256 rentalCost = sphere.getOrbitSphereInstanceCost(
            AWSInstanceTypes.T2_MICRO,
            1 hours
        );
        IOrbitSphere.SphereMetadata memory expectedSphereInfo = IOrbitSphere
            .SphereMetadata({
                sphereId: 1,
                tenant: _msgSender(),
                totalUsdPaid: rentalCost,
                region: AWSRegions.ASIA_MUMBAI,
                rentedOn: uint128(block.timestamp),
                instanceType: AWSInstanceTypes.T2_MICRO,
                willBeEndOn: uint128(block.timestamp + 1 hours),
                terminatedOn: uint128(block.timestamp + 1 hours),
                status: IOrbitSphere.OrbitSphereStatus.RUNNING
            });

        /// Assert
        assertEq(
            abi.encode(expectedSphereInfo), /// Expected
            abi.encode(sphere.getOrbitSphereInfo(1)) /// Actual
        );
    }

    function test__ShouldReturnSphereAndInstanceInfoForSphereIdOne()
        public
        afterServerRented
    {
        /// Prepare
        uint256 rentalCost = sphere.getOrbitSphereInstanceCost(
            AWSInstanceTypes.T2_MICRO,
            1 hours
        );
        IOrbitSphere.SphereMetadata memory expectedSphereInfo = IOrbitSphere
            .SphereMetadata({
                sphereId: 1,
                tenant: _msgSender(),
                totalUsdPaid: rentalCost,
                region: AWSRegions.ASIA_MUMBAI,
                rentedOn: uint128(block.timestamp),
                instanceType: AWSInstanceTypes.T2_MICRO,
                willBeEndOn: uint128(block.timestamp + 1 hours),
                terminatedOn: uint128(block.timestamp + 1 hours),
                status: IOrbitSphere.OrbitSphereStatus.RUNNING
            });

        /// Assert
        (
            IOrbitSphere.SphereMetadata memory exSphere,
            IOrbitSphere.InstanceMetadata memory exInstance
        ) = sphere.getOrbitSphereInfoWithInstance(1);
        assertEq(
            /// Actual
            abi.encode(exSphere, exInstance),
            /// Expected
            abi.encode(
                expectedSphereInfo,
                AWSInstanceTypes.getInstanceInfo(AWSInstanceTypes.T2_MICRO)
            )
        );
    }

    function test__ShouldEmitOrbitSphereInstanceRented()
        public
        beforeServerRented
    {
        /// Prepare
        uint256 rentalCost = sphere.getOrbitSphereInstanceCost(
            AWSInstanceTypes.T2_MICRO,
            1 hours
        );
        /// Assert
        vm.expectEmit(true, true, true, true);
        emit IOrbitSphere.OrbitSphereInstanceRented(
            AWSRegions.ASIA_MUMBAI,
            1,
            AWSInstanceTypes.T2_MICRO,
            bytes("MY SSH PUBLIC KEY"),
            uint128(block.timestamp),
            uint128(block.timestamp + 1 hours),
            _msgSender(),
            rentalCost
        );
    }

    /** @notice FAILURE */
    function test__ShouldRevertWhileRequestedRegionIsNotAvailable() public {
        /// Assert
        vm.expectPartialRevert(
            IOrbitSphere.OrbitSphere__UnavailableRegion.selector
        );
        /// Action
        sphere.rentOrbitSphereInstance(
            AWSRegions.US_CALIFORNIA,
            AWSInstanceTypes.T2_MICRO,
            1 hours,
            bytes("MY SSH PUBLIC KEY")
        );
    }

    function test__ShouldRevertWhileRequestedInstanceTypeIsNotAvailable()
        public
    {
        /// Assert
        vm.expectPartialRevert(
            IOrbitSphere.OrbitSphere__UnavailableInstanceType.selector
        );
        /// Action
        sphere.rentOrbitSphereInstance(
            AWSRegions.ASIA_MUMBAI,
            AWSInstanceTypes.T2_XLARGE,
            1 hours,
            bytes("MY SSH PUBLIC KEY")
        );
    }

    function test__ShouldRevertWhileRequestedDurationIsLessThanMinimumDuration()
        public
    {
        /// Assert
        vm.expectPartialRevert(
            IOrbitSphere.OrbitSphere__RentalDurationTooShort.selector
        );
        /// Action
        sphere.rentOrbitSphereInstance(
            AWSRegions.ASIA_MUMBAI,
            AWSInstanceTypes.T2_MICRO,
            1,
            bytes("MY SSH PUBLIC KEY")
        );
    }
}
