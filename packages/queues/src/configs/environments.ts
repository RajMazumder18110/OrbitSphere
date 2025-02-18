/** @notice library imports */
import { grabEnv } from "@rajmazumder/grabenv";

/// Types
type Environments = {
  /// Mandatory
  RABBITMQ_CONNECTION_URL: string;
};

export const environments = grabEnv<Environments>({
  RABBITMQ_CONNECTION_URL: {
    type: "string",
  },
});
