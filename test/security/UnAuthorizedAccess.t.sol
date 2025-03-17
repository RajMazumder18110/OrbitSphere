// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Test, console} from "forge-std/Test.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
/// @notice Local imports
import {TestParams} from "../TestParams.t.sol";
import {OrbitSphere} from "@OrbitSphere-contracts/OrbitSphere.sol";
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";
import {OrbitSphereDeploy} from "@OrbitSphere-scripts/OrbitSphereDeploy.s.sol";

contract OrbitSphereUnAuthorizedAccessTest is Test, Context {
    /// @notice Stores the deployed `OrbitSphere` contract instance.
    OrbitSphere sphere;

    /**
     * @notice Deploys the `OrbitSphere` contract and assigns it to `sphere`.
     * @dev Uses `OrbitSphereDeploy` to handle the deployment.
     */
    function setUp() external {
        OrbitSphereDeploy orbiter = new OrbitSphereDeploy();
        sphere = orbiter.run();
    }

    function test__AddNewRegionsWhenCallerIsNotOrbitSphereManager() public {
        /// Prepare
        bytes32[] memory regions = TestParams.getMockRegionParams();
        /// Assert & Action
        vm.expectPartialRevert(
            IAccessControl.AccessControlUnauthorizedAccount.selector
        );
        sphere.addRegions(regions);
    }

    function test__RemoveActiveRegionsWhenCallerIsNotOrbitSphereManager()
        public
    {
        /// Prepare
        bytes32[] memory regions = TestParams.getMockRegionParams();
        /// Assert & Action
        vm.expectPartialRevert(
            IAccessControl.AccessControlUnauthorizedAccount.selector
        );
        sphere.removeRegions(regions);
    }

    function test__AddNewInstanceTypesWhenCallerIsNotOrbitSphereManager()
        public
    {
        /// Prepare
        IOrbitSphere.InstanceMetadata[] memory types = TestParams
            .getMockInstanceTypeParams();
        /// Assert & Action
        vm.expectPartialRevert(
            IAccessControl.AccessControlUnauthorizedAccount.selector
        );
        sphere.addInstanceTypes(types);
    }

    function test__RemoveActiveInstanceTypesWhenCallerIsNotOrbitSphereManager()
        public
    {
        /// Prepare
        bytes32[] memory types = TestParams.getMockInstanceTypesOnlyParams();
        /// Assert & Action
        vm.expectPartialRevert(
            IAccessControl.AccessControlUnauthorizedAccount.selector
        );
        sphere.removeInstanceTypes(types);
    }

    function test__TerminateExpiredSphereWhenCallerIsNotOrbitSphereTerminator()
        public
    {
        /// Prepare
        uint256[] memory spherIds = new uint256[](0);
        /// Assert & Action
        vm.expectPartialRevert(
            IAccessControl.AccessControlUnauthorizedAccount.selector
        );
        sphere.forceTerminateSpheres(spherIds);
    }
}
