// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Test, console} from "forge-std/Test.sol";
/// @notice Local imports
import {OrbitSphere} from "@OrbitSphere-contracts/OrbitSphere.sol";
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";
import {OrbitSphereDeploy} from "@OrbitSphere-scripts/OrbitSphereDeploy.s.sol";

contract OrbitSpherePreventionMethodsTest is Test {
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

    function test__PreventFromTransferFrom() public {
        /// Assert
        vm.expectRevert(IOrbitSphere.OrbitSphere__TransfersNotAllowed.selector);
        /// Action
        sphere.transferFrom(address(1), address(2), 1);
    }

    function test__PreventFromSafeTransferFrom() public {
        /// Assert
        vm.expectRevert(IOrbitSphere.OrbitSphere__TransfersNotAllowed.selector);
        /// Action
        sphere.safeTransferFrom(address(1), address(2), 1);
    }

    function test__PreventFromSafeTransferWithDataFrom() public {
        /// Assert
        vm.expectRevert(IOrbitSphere.OrbitSphere__TransfersNotAllowed.selector);
        /// Action
        sphere.safeTransferFrom(address(1), address(2), 1, bytes("COOL"));
    }
}
