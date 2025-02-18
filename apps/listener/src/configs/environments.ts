/** @notice library imports */
import { grabEnv } from "@rajmazumder/grabenv";

/// Types
type Environments = {
  /// Mandatory
  ORBIT_SPHERE_ADDRESS: string;
  BLOCKCHAIN_URL_FOR_LISTENERS: string;
};

export const environments = grabEnv<Environments>({
  ORBIT_SPHERE_ADDRESS: {
    type: "string",
  },
  BLOCKCHAIN_URL_FOR_LISTENERS: {
    type: "string",
  },
});
