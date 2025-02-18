/** @notice library imports */
import type { ContractEventPayload } from "ethers";
import { InstanceRentalQueue } from "@orbitsphere/queues";
/// Local imports
import { OrbitSphereContract } from "@/constants";
import { OrbitSphereEvents } from "@/constants/orbitSphereEvents";

export class OnInstanceRented {
  /// Listen InstanceRented events
  public static async listen() {
    await OrbitSphereContract.on(
      OrbitSphereEvents.INSTANCE_RENTED,
      async (
        /// Instance details
        region: string,
        nftId: bigint,
        instanceType: string,
        sshPublicKey: string,
        rentedOn: bigint,
        willBeEndOn: bigint,

        /// Tenant details
        tenant: string,
        totalCost: bigint,
        pricePerHour: bigint,
        payload: ContractEventPayload
      ) => {
        /// Saving logs into database.

        /// Pushing data into rental queue
        await InstanceRentalQueue.publish({
          message: {
            tenant,
            region,
            sshPublicKey,
            instanceType,
            nftId: nftId.toString(),
            terminateOn: Number(willBeEndOn),
          },
        });
      }
    );
  }
}
