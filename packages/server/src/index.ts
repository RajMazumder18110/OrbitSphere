import { QueueHandlers } from "@/queues/QueueHandlers";

await QueueHandlers.enqueueRent({
  nftId: 1,
  instance: "t2.micro",
});
