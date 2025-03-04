// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {Test, console} from "forge-std/Test.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
/// @notice Local imports
import {OrbitSphere} from "@OrbitSphere-contracts/OrbitSphere.sol";
import {OrbitSphereDeploy} from "@OrbitSphere-scripts/OrbitSphereDeploy.s.sol";
import {AWSRegions, AWSInstanceTypes} from "@OrbitSphere-contracts/lib/AWSConstants.sol";

contract OrbitSphereTest is Test, Context {
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

    /**
     * @notice Ensures the contract owner is the same as the transaction sender.
     * @dev Uses an assertion to check if `sphere.owner()` matches `_msgSender()`.
     */
    function testOwnerIsSameAsMsgSender() public view {
        assert(sphere.owner() == _msgSender());
    }

    /** @notice ADD NEW REGIONS */
    /**
     * @notice Tests that adding new regions fails when the caller is not the contract owner.
     * @dev Expects a partial revert with `OwnableUnauthorizedAccount` error when `addRegions` is called by a non-owner.
     */
    function testAddNewRegionsWhenCallerIsNotOwner() public {
        /// Prepare
        bytes32[] memory regions = new bytes32[](2);
        regions[0] = AWSRegions.ASIA_MUMBAI;
        regions[1] = AWSRegions.US_CALIFORNIA;

        /// Assert & Action
        vm.expectPartialRevert(Ownable.OwnableUnauthorizedAccount.selector);
        sphere.addRegions(regions);
    }

    /**
     * @notice Tests that the contract owner can successfully add new AWS regions.
     * @dev Uses `vm.prank` to simulate the owner calling `addRegions` and asserts the regions were added correctly.
     */
    function testAddNewRegionsWhenCallerIsOwner() public {
        /// Prepare
        bytes32[] memory regions = new bytes32[](2);
        regions[0] = AWSRegions.ASIA_MUMBAI;

        /// Action
        vm.prank(_msgSender());
        sphere.addRegions(regions);

        /// Assert
        assert(sphere.isActiveRegion(AWSRegions.ASIA_MUMBAI));
        assert(!sphere.isActiveRegion(AWSRegions.US_CALIFORNIA));
    }

    /** @notice ADD NEW INSTANCE TYPES */
    /**
     * @notice Tests that adding new instane types fails when the caller is not the contract owner.
     * @dev Expects a partial revert with `OwnableUnauthorizedAccount` error when `addInstanceTypes` is called by a non-owner.
     */
    function testAddNewInstanceTypesWhenCallerIsNotOwner() public {
        /// Prepare
        bytes32[] memory types = new bytes32[](2);
        types[0] = AWSInstanceTypes.T2_MICRO;
        types[1] = AWSInstanceTypes.T2_SMALL;

        /// Assert & Action
        vm.expectPartialRevert(Ownable.OwnableUnauthorizedAccount.selector);
        sphere.addInstanceTypes(types);
    }

    /**
     * @notice Tests that the contract owner can successfully add new AWS instance types.
     * @dev Uses `vm.prank` to simulate the owner calling `addInstanceTypes` and asserts the regions were added correctly.
     */
    function testAddNewInstanceTypesWhenCallerIsOwner() public {
        /// Prepare
        bytes32[] memory types = new bytes32[](2);
        types[0] = AWSInstanceTypes.T2_MICRO;
        types[1] = AWSInstanceTypes.T2_SMALL;

        /// Action
        vm.prank(_msgSender());
        sphere.addInstanceTypes(types);

        /// Assert
        assert(sphere.isActiveInstanceType(AWSInstanceTypes.T2_MICRO));
        assert(sphere.isActiveInstanceType(AWSInstanceTypes.T2_SMALL));
    }
}
