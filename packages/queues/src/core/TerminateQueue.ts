/** @notice library imports */
/// Local imports
import { RabbitMQConnectionQueue } from "@/core/ConnectionQueue";

/// Types
type TerminateMessagePublishParams = {
  message: {
    nftId: string;
    tenant: string;
  };
  terminateTimestamp?: number;
};

type TerminateMessageHandler = (
  message: TerminateMessagePublishParams["message"]
) => Promise<void>;

/// Terminate Queue
export class InstanceTerminateQueue extends RabbitMQConnectionQueue {
  /**
   * @notice Closes active connections.
   * This static method waits for the `closeConnections` method to finish, ensuring all connections are closed.
   */
  public static async close() {
    await this.closeConnections();
  }

  /**
   * @notice Publishes a message to the rental queue.
   * Initializes the connection if not already available and then publishes the
   * provided message to the rental queue.
   *
   * @param {TerminateMessagePublishParams} params - The parameters containing the message & delay timestamp to publish.
   */
  public static async publish({
    message,
    terminateTimestamp,
  }: TerminateMessagePublishParams) {
    /// Initialize connection if not available
    await this.initialize();

    /// Publish with delay
    const delay = terminateTimestamp ?? 0 * 1000 - Date.now();

    this.__channel.publish(
      this.ORBITSPHERE_EXCHANGE,
      this.ROUTE_TO_TERMINATE_QUEUE,
      Buffer.from(JSON.stringify(message)),
      {
        headers: terminateTimestamp
          ? {
              "x-delay": delay,
            }
          : {},
      }
    );
  }

  /**
   * @notice Consumes messages from the rental queue and processes them with the provided handler.
   * Initializes the connection if not already available, then listens for messages in the
   * rental queue. Upon receiving a message, it parses the content and executes the handler.
   *
   * @param {RentalMessageHandler} handler - The function to handle the parsed message.
   */
  public static async consume(handler: TerminateMessageHandler) {
    /// Initialize connection if not available
    await this.initialize();

    /// Consuming msg
    await this.__channel.consume(this.TERMINATE_QUEUE, async (msg) => {
      /// Incase of no msg
      if (!msg) return;

      /// Execute the function
      try {
        const data: TerminateMessagePublishParams["message"] = JSON.parse(
          msg.content.toString()
        );
        await handler(data);
        this.__channel.ack(msg);
      } catch (error) {
        console.error(error);
      }
    });
  }
}
