// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Test, console} from "forge-std/Test.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
/// @notice Local imports
import {TestParams} from "../TestParams.t.sol";
import {OrbitSphere} from "@OrbitSphere-contracts/OrbitSphere.sol";
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";
import {OrbitSphereDeploy} from "@OrbitSphere-scripts/OrbitSphereDeploy.s.sol";

contract OrbitSphereRegionsTest is Test, Context {
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

    modifier afterRegionAdded() {
        /// Prepare
        bytes32[] memory regions = TestParams.getMockRegionParams();
        /// Action
        vm.prank(_msgSender());
        sphere.addRegions(regions);
        /// Assert
        _;
    }

    modifier beforeRegionAdded() {
        /// Prepare
        bytes32[] memory regions = TestParams.getMockRegionParams();
        /// Assert
        _;
        /// Action
        vm.prank(_msgSender());
        sphere.addRegions(regions);
    }

    function test__GetActiveRegions() public afterRegionAdded {
        /// Assert
        assertEq(sphere.getActiveRegions(), TestParams.getMockRegionParams());
    }

    function test__AddNewRegions() public afterRegionAdded {
        /// Prepare
        bytes32[] memory regions = TestParams.getMockRegionParams();
        /// Assert
        for (uint8 i; i < regions.length; i++) {
            assert(sphere.isActiveRegion(regions[i]));
        }
    }

    function test__EventsWhileAddNewRegions() public beforeRegionAdded {
        /// Prepare
        bytes32[] memory regions = TestParams.getMockRegionParams();
        /// Assert
        for (uint8 i; i < regions.length; i++) {
            vm.expectEmit(true, false, false, false, address(sphere));
            emit IOrbitSphere.AWSRegionAdded(regions[i]);
        }
    }
}
