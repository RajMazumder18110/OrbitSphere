/** @notice library imports */
import { InstanceStopQueue } from "@orbitsphere/queues";
import type { ContractEventPayload, EventLog, Block } from "ethers";
/// Local imports
import { OrbitSphereEvents } from "@/constants/orbitSphereEvents";
import { OrbitSphereContract, orbitSphereRpcProvider } from "@/constants";

export class OnInstanceStopped {
  /// Listen InstanceStopped events
  public static async listen() {
    await OrbitSphereContract.on(
      OrbitSphereEvents.INSTANCE_STOPPED,
      async (nftId: bigint, tenant: string, payload: ContractEventPayload) => {
        await this.process(nftId, tenant, payload.log);
        await this.acknowledge(payload.log.blockNumber, payload.log.blockHash);
      }
    );
  }

  /// Sync unsynced InstanceStopped events
  public static async sync() {
    const latestBlock = (await orbitSphereRpcProvider.getBlock(
      "latest"
    )) as Block;
    /// TODO: Grab last synced block number
    const lastUpdatedBlock = 48393445;

    /// Incase if any block left to sync
    if (lastUpdatedBlock < latestBlock.timestamp) {
      /// Grabbing all unsynced logs
      const unsyncedLogs = (await OrbitSphereContract.queryFilter(
        OrbitSphereEvents.INSTANCE_STOPPED,
        lastUpdatedBlock + 1,
        "latest"
      )) as EventLog[];

      /// Process all logs
      unsyncedLogs.forEach(async (log) => {
        const [nftId, tenant] = log.args;
        /// Process & acknowledge
        await this.process(nftId, tenant, log);
        await this.acknowledge(log.blockNumber, log.blockHash);
      });
    }

    /// Update the current block as synced.
    await this.acknowledge(latestBlock.number, latestBlock.hash!);
  }

  /// Save the last synced blockNumber with transaction hash
  private static async acknowledge(blockNumber: number, blockHash: string) {
    /// TODO.
    console.log("Acknowledged!", blockNumber);
  }

  /// Sync unsynced InstanceStopped events
  private static async process(
    nftId: bigint,
    tenant: string,
    payload: EventLog
  ) {
    /// Saving logs into database.
    // console.log(nftId, tenant, payload);

    /// Pushing data into rental queue
    await InstanceStopQueue.publish({
      message: {
        tenant,
        nftId: nftId.toString(),
      },
    });
  }
}
