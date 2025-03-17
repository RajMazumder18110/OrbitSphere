// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Test, console} from "forge-std/Test.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
/// @notice Local imports
import {TestParams} from "../TestParams.t.sol";
import {OrbitSphere} from "@OrbitSphere-contracts/OrbitSphere.sol";
import {OrbitSphereDeploy} from "@OrbitSphere-scripts/OrbitSphereDeploy.s.sol";
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";
import {AWSRegions, AWSInstanceTypes} from "@OrbitSphere-contracts/lib/AWSConstants.sol";

contract OrbitSphereForceTerminateTest is Test, Context {
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
        sphere.rentSphere(
            AWSRegions.ASIA_MUMBAI,
            AWSInstanceTypes.T2_MICRO,
            1 hours,
            bytes("MY SSH PUBLIC KEY")
        );
        vm.stopPrank();
        _;
    }

    function test__ShouldTerminateSphereIdsByOwner() public afterServerRented {
        /// Prepare
        uint256[] memory idsToTerminate = new uint256[](1);
        idsToTerminate[0] = 1;

        /// Action
        vm.startPrank(_msgSender());
        sphere.forceTerminateSpheres(idsToTerminate);
        /// Assert
        uint256[] memory activeIdsAfterTerminate = new uint256[](0);
        assertEq(
            sphere.getSphereIdsByTenant(_msgSender()),
            activeIdsAfterTerminate
        );
    }

    function test__TenantBalanceIsZeroAfterForceTerminationByOwner()
        public
        afterServerRented
    {
        /// Prepare
        uint256[] memory idsToTerminate = new uint256[](1);
        idsToTerminate[0] = 1;

        /// Action
        vm.startPrank(_msgSender());
        sphere.forceTerminateSpheres(idsToTerminate);
        /// Assert
        assertEq(sphere.balanceOf(_msgSender()), 0);
    }
}
