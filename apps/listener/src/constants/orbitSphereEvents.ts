export const orbitSphereEventsAbi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes",
        name: "region",
        type: "bytes",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "nftId",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "bytes",
        name: "instanceType",
        type: "bytes",
      },
      {
        indexed: false,
        internalType: "bytes",
        name: "sshPublicKey",
        type: "bytes",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "rentedOn",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "willBeEndOn",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "address",
        name: "tenant",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "totalCost",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "pricePerHour",
        type: "uint256",
      },
    ],
    name: "InstanceRented",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "uint256",
        name: "nftId",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "address",
        name: "tenant",
        type: "address",
      },
    ],
    name: "InstanceStopped",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "tenant",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "nftId",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "actualCost",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "timeConsumed",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "refundAmount",
        type: "uint256",
      },
    ],
    name: "InstanceTerminated",
    type: "event",
  },
] as const;

export const enum OrbitSphereEvents {
  INSTANCE_RENTED = "InstanceRented",
  INSTANCE_STOPPED = "InstanceStopped",
  INSTANCE_TERMINATED = "InstanceTerminated",
}
