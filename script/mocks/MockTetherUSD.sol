// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @notice Library imports
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title MockTetherUSD
/// @notice A mock implementation of the Tether USD (USDT) token for testing purposes.
contract MockTetherUSD is ERC20 {
    /**
     * @notice Deploys the MockTetherUSD contract and mints an initial supply to the deployer.
     * @dev Mints 1 billion USDT (with 6 decimal places) to the contract deployer.
     */
    constructor() ERC20("Tether USD", "USDT") {
        _mint(_msgSender(), 1000000000 * (10 ** decimals()));
    }

    /**
     * @notice Returns the number of decimal places used by USDT.
     * @dev USDT uses 6 decimal places instead of the standard 18.
     * @return uint8 The decimal precision of the token.
     */
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
