/** @notice library imports */
/// Local imports
import { RabbitMQConnectionQueue } from "@/core/ConnectionQueue";

/// Types
type StopMessagePublishParams = {
  message: {
    nftId: string;
    tenant: string;
  };
};

type StopMessageHandler = (
  message: StopMessagePublishParams["message"]
) => Promise<void>;

/// Stop Queue
export class InstanceStopQueue extends RabbitMQConnectionQueue {
  /**
   * @notice Closes active connections.
   * This static method waits for the `closeConnections` method to finish, ensuring all connections are closed.
   */
  public static async close() {
    await this.closeConnections();
  }

  /**
   * @notice Publishes a message to the stop queue.
   * Initializes the connection if not already available and then publishes the
   * provided message to the stop queue.
   *
   * @param {StopMessagePublishParams} params - The parameters containing the message to publish.
   */
  public static async publish({ message }: StopMessagePublishParams) {
    /// Initialize connection if not available
    await this.initialize();

    /// Publish
    this.__channel.publish(
      this.ORBITSPHERE_EXCHANGE,
      this.ROUTE_TO_STOP_QUEUE,
      Buffer.from(JSON.stringify(message))
    );
  }

  /**
   * @notice Consumes messages from the stop queue and processes them with the provided handler.
   * Initializes the connection if not already available, then listens for messages in the
   * stop queue. Upon receiving a message, it parses the content and executes the handler.
   *
   * @param {StopMessageHandler} handler - The function to handle the parsed message.
   */

  public static async consume(handler: StopMessageHandler) {
    /// Initialize connection if not available
    await this.initialize();

    /// Consuming msg
    await this.__channel.consume(this.STOP_QUEUE, async (msg) => {
      /// Incase of no msg
      if (!msg) return;

      /// Execute the function
      try {
        const data: StopMessagePublishParams["message"] = JSON.parse(
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
