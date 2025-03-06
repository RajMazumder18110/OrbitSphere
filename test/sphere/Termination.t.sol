// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Test, console} from "forge-std/Test.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
/// @notice Local imports
import {OrbitSphere} from "@OrbitSphere-contracts/OrbitSphere.sol";
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";
import {OrbitSphereDeploy} from "@OrbitSphere-scripts/OrbitSphereDeploy.s.sol";
import {AWSRegions, AWSInstanceTypes} from "@OrbitSphere-contracts/lib/AWSConstants.sol";

contract OrbitSphereTerminationTest is Test, Context {
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

    /** @notice SUCCESS */
    function test__ShouldReturnBlankActiveSphereIds() public afterServerRented {
        /// Prepare
        uint256[] memory ids = new uint256[](0);
        /// Action
        vm.startPrank(_msgSender());
        sphere.terminateOrbitSphereInstance(1);
        /// Assert
        assertEq(sphere.getSphereIdsByTenant(_msgSender()), ids);
    }

    function test__TenantBalanceIsZeroAfterTermination()
        public
        afterServerRented
    {
        /// Action
        vm.startPrank(_msgSender());
        sphere.terminateOrbitSphereInstance(1);
        /// Assert
        assertEq(sphere.balanceOf(_msgSender()), 0);
    }

    function test__SphereInfoForIdOneTerminatedAfterFullDuration()
        public
        afterServerRented
    {
        /// Prepare
        uint256 rentedOn = block.timestamp;
        /// @notice Skip to 1+ hours
        skip(1 hours);
        uint256 rentalCost = sphere.getOrbitSphereInstanceCost(
            AWSInstanceTypes.T2_MICRO,
            1 hours
        );
        IOrbitSphere.SphereMetadata memory expectedSphereInfo = IOrbitSphere
            .SphereMetadata({
                sphereId: 1,
                rentedOn: rentedOn,
                tenant: _msgSender(),
                totalUsdPaid: rentalCost,
                region: AWSRegions.ASIA_MUMBAI,
                willBeEndOn: rentedOn + 1 hours,
                terminatedOn: block.timestamp,
                instanceType: AWSInstanceTypes.T2_MICRO,
                status: IOrbitSphere.OrbitSphereStatus.TERMINATED
            });

        /// Action
        vm.startPrank(_msgSender());
        sphere.terminateOrbitSphereInstance(1);

        /// Assert
        assertEq(
            abi.encode(expectedSphereInfo), /// Expected
            abi.encode(sphere.getOrbitSphereInfo(1)) /// Actual
        );
    }

    function test__SphereInfoForIdOneTerminatedBefore()
        public
        afterServerRented
    {
        /// Prepare
        uint256 rentedOn = block.timestamp;
        /// @notice Instance Used for 25 minutes
        skip(25 minutes);
        uint256 actualRentalCost = sphere.getOrbitSphereInstanceCost(
            AWSInstanceTypes.T2_MICRO,
            25 minutes
        );
        IOrbitSphere.SphereMetadata memory expectedSphereInfo = IOrbitSphere
            .SphereMetadata({
                sphereId: 1,
                rentedOn: rentedOn,
                tenant: _msgSender(),
                totalUsdPaid: actualRentalCost,
                region: AWSRegions.ASIA_MUMBAI,
                willBeEndOn: rentedOn + 1 hours,
                terminatedOn: block.timestamp,
                instanceType: AWSInstanceTypes.T2_MICRO,
                status: IOrbitSphere.OrbitSphereStatus.TERMINATED
            });

        /// Action
        vm.startPrank(_msgSender());
        sphere.terminateOrbitSphereInstance(1);
        uint256 usdtBalanceAfter = sphere.TETHER_USD().balanceOf(
            address(sphere)
        );

        /// Assert
        assertEq(actualRentalCost, usdtBalanceAfter);
        assertEq(
            abi.encode(expectedSphereInfo), /// Expected
            abi.encode(sphere.getOrbitSphereInfo(1)), /// Actual
            "Matching sphereInfo"
        );
    }

    function test__ShouldEmitTerminatedEventAfterTermination()
        public
        afterServerRented
    {
        /// Prepare
        /// @notice Instance Used for 25 minutes
        skip(25 minutes);
        uint256 timeConsumed = 25 minutes;
        uint256 actualRentalCost = sphere.getOrbitSphereInstanceCost(
            AWSInstanceTypes.T2_MICRO,
            timeConsumed
        );
        uint256 totalPaid = sphere.getOrbitSphereInstanceCost(
            AWSInstanceTypes.T2_MICRO,
            1 hours
        );

        /// Assert
        vm.expectEmit(true, true, false, true);
        emit IOrbitSphere.OrbitSphereInstanceTerminated(
            _msgSender(),
            1,
            actualRentalCost,
            timeConsumed,
            totalPaid - actualRentalCost
        );
        /// Action
        vm.startPrank(_msgSender());
        sphere.terminateOrbitSphereInstance(1);
    }

    /** @notice FAILURE */
    function test__ShouldRevertOwnerOfMethodAfterTermination()
        public
        afterServerRented
    {
        /// Action
        vm.startPrank(_msgSender());
        sphere.terminateOrbitSphereInstance(1);
        /// Assert
        vm.expectPartialRevert(IERC721Errors.ERC721NonexistentToken.selector);
        sphere.ownerOf(1);
    }

    function test__ShouldRevertWhileCallerIsNotActualTenant()
        public
        afterServerRented
    {
        /// Assert
        vm.expectPartialRevert(
            IOrbitSphere.OrbitSphere__UnauthorizedTenant.selector
        );
        /// Action
        vm.prank(address(10));
        sphere.terminateOrbitSphereInstance(1);
    }
}
