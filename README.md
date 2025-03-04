# OrbitSphere

This repository contains the smart contracts for **OrbitSphere**, a decentralized server lending platform where users can rent cloud servers per hour and pay in USDC/USDT. The smart contracts handle:

- Rental management (tracking rented instances)
- Payment processing (USDC/USDT-based transactions)
- Event emissions to trigger AWS automation
- Access control and ownership

These contracts ensure a trustless, transparent, and efficient server rental experience using blockchain technology.

## Features

- ✅ Decentralized Server Rental – Users can rent cloud servers trustlessly
- ✅ Automated AWS Provisioning – Blockchain events trigger AWS instance creation
- ✅ ERC20 Stablecoin Payments – Supports USDC/USDT for seamless transactions
- ✅ Time-Based Rentals – Users rent servers for a fixed duration
- ✅ Smart Contract-Managed Lifecycle – Events handle server start, stop, and termination

## Architecture

## Deployment & Setup

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/RajMazumder18110/OrbitSphere.git
cd OrbitSphere
```

### 2️⃣ Install Dependencies

```bash
forge install
```

### 3️⃣ Compile Contracts

```bash
forge build
```

### 4️⃣ Run Tests

```bash
forge test -vvv
```

## License

This project is licensed under the MIT License.
