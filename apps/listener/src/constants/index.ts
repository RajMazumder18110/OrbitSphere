/** @notice Library imports */
import { JsonRpcProvider, Contract, WebSocketProvider } from "ethers";
/// Local imports
import { environments } from "@/configs/environments";
import { orbitSphereEventsAbi } from "./orbitSphereEvents";

/// Blockchain provider & contract
export const orbitSphereRpcProvider = new WebSocketProvider(
  environments.BLOCKCHAIN_URL_FOR_LISTENERS
);
export const OrbitSphereContract = new Contract(
  environments.ORBIT_SPHERE_ADDRESS,
  orbitSphereEventsAbi,
  orbitSphereRpcProvider
);
