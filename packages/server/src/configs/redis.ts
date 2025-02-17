/** @notice Library imports */
import { Redis } from "ioredis";
/// Local imports
import { environments } from "./environments";

/// Redis connection
export const redisConnection = new Redis(environments.REDIS_CONNECTION_URL);
