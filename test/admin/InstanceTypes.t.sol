// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Test, console} from "forge-std/Test.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
/// @notice Local imports
import {TestParams} from "../TestParams.t.sol";
import {OrbitSphere} from "@OrbitSphere-contracts/OrbitSphere.sol";
import {IOrbitSphere} from "@OrbitSphere-contracts/interfaces/IOrbitSphere.sol";
import {OrbitSphereDeploy} from "@OrbitSphere-scripts/OrbitSphereDeploy.s.sol";

contract OrbitSphereInstanceTypesTest is Test, Context {
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

    modifier afterInstanceTypeAdded() {
        /// Prepare
        bytes32[] memory types = TestParams.getMockInstanceTypeParams();
        /// Action
        vm.prank(_msgSender());
        sphere.addInstanceTypes(types);
        /// Assert
        _;
    }

    modifier beforeInstanceTypeAdded() {
        /// Prepare
        bytes32[] memory types = TestParams.getMockInstanceTypeParams();
        /// Assert
        _;
        /// Action
        vm.prank(_msgSender());
        sphere.addInstanceTypes(types);
    }

    function test__GetActiveInstanceTypes() public afterInstanceTypeAdded {
        /// Assert
        assertEq(
            sphere.getActiveInstanceTypes(),
            TestParams.getMockInstanceTypeParams()
        );
    }

    function test__AddNewInstanceTypes() public afterInstanceTypeAdded {
        /// Prepare
        bytes32[] memory types = TestParams.getMockInstanceTypeParams();
        /// Assert
        for (uint8 i; i < types.length; i++) {
            assert(sphere.isActiveInstanceType(types[i]));
        }
    }

    function test__EventsWhileAddNewInstanceTypes()
        public
        beforeInstanceTypeAdded
    {
        /// Prepare
        bytes32[] memory types = TestParams.getMockInstanceTypeParams();
        /// Assert
        for (uint8 i; i < types.length; i++) {
            vm.expectEmit(true, false, false, false, address(sphere));
            emit IOrbitSphere.AWSInstanceTypeAdded(types[i]);
        }
    }
}
