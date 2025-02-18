/** @notice library imports */
import amqp, { type Connection, type Channel } from "amqplib";
/// Local imports
import { environments } from "@/configs/environments";

export class RabbitMQConnectionQueue {
  /// Global instance
  protected static __connection: Connection;
  protected static __channel: Channel;

  /// All constants
  /// Exchanges
  public static ORBITSPHERE_EXCHANGE = "ORBITSPHERE_EXCHANGE";

  /// Queues
  public static STOP_QUEUE = "STOP_QUEUE";
  public static RENTAL_QUEUE = "RENTAL_QUEUE";
  public static TERMINATE_QUEUE = "TERMINATE_QUEUE";

  /// Routes
  public static ROUTE_TO_STOP_QUEUE = "ROUTE_TO_STOP_QUEUE";
  public static ROUTE_TO_RENTAL_QUEUE = "ROUTE_TO_RENTAL_QUEUE";
  public static ROUTE_TO_TERMINATE_QUEUE = "ROUTE_TO_TERMINATE_QUEUE";

  /**
   * @notice Initializes the message broker connection and channel if not already set up.
   */
  protected static async initialize() {
    if (!this.__channel) {
      await this.setUpWholeMessageBroker();
    }
  }

  /**
   * @notice Closes the active message broker connections (channel and connection).
   */
  protected static async closeConnections() {
    if (this.__channel) {
      await this.__channel.close();
      await this.__connection.close();
    }
  }

  /**
   * Sets up the message broker (connection, channel, exchange, and queues).
   */
  private static async setUpWholeMessageBroker() {
    if (!this.__connection) {
      this.__connection = await amqp.connect(
        environments.RABBITMQ_CONNECTION_URL
      );
      this.__channel = await this.__connection.createChannel();

      /// Create an Exchange
      await this.__channel.assertExchange(
        this.ORBITSPHERE_EXCHANGE,
        "x-delayed-message",
        {
          durable: true,
          arguments: {
            "x-delayed-type": "direct",
          },
        }
      );

      /// Create Queues
      await this.__channel.assertQueue(this.STOP_QUEUE, { durable: true });
      await this.__channel.assertQueue(this.RENTAL_QUEUE, { durable: true });
      await this.__channel.assertQueue(this.TERMINATE_QUEUE, { durable: true });

      /// Binging Queues to Exchange
      await this.__channel.bindQueue(
        this.STOP_QUEUE,
        this.ORBITSPHERE_EXCHANGE,
        this.ROUTE_TO_STOP_QUEUE
      );

      await this.__channel.bindQueue(
        this.RENTAL_QUEUE,
        this.ORBITSPHERE_EXCHANGE,
        this.ROUTE_TO_RENTAL_QUEUE
      );

      await this.__channel.bindQueue(
        this.TERMINATE_QUEUE,
        this.ORBITSPHERE_EXCHANGE,
        this.ROUTE_TO_TERMINATE_QUEUE
      );
    }
  }
}
