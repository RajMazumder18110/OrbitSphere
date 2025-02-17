/** @notice library imports */
import { grabEnv } from "@rajmazumder/grabenv";

/// Types
interface Environments {
  /// Mandatory
  REDIS_CONNECTION_URL: string;
}

export const environments = grabEnv<Environments>({
  REDIS_CONNECTION_URL: {
    type: "string",
  },
});
