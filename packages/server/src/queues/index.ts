/** @notice Library imports */
import { Queue } from "bullmq";
/// Local imports
import { Queues } from "@/constants";
import { redisConnection } from "@/configs/redis";

/// Queues
export const rentalQueue = new Queue(Queues.RENTAL, {
  connection: redisConnection,
});
