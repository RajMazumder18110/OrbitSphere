/** @notice Local imports */
import { rentalQueue } from "@/queues";

export class QueueHandlers {
  public static async enqueueRent(data: Record<string, any>) {
    const job = await rentalQueue.add(`RENT`, data);
    return job;
  }
}
