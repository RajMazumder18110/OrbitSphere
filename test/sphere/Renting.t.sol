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
        /// @notice Renting a server.
        sphere.rentOrbitSphereInstance(
            AWSRegions.ASIA_MUMBAI,
            AWSInstanceTypes.T2_MICRO,
            1 hours,
            bytes("MY SSH PUBLIC KEY")
        );
        _;
    }

    function _tenant() private view returns (address) {
        return address(this);
    }

    function test__HolderBalanceIsOneAfterRenting() public afterServerRented {
        assertEq(sphere.balanceOf(_tenant()), 1);
    }
}
