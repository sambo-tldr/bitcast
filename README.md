# BitCast Protocol

> **Decentralized Bitcoin Price Forecasting on Stacks**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Clarity](https://img.shields.io/badge/Clarity-v3-blue.svg)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange.svg)](https://stacks.co/)

## Overview

BitCast Protocol is a sophisticated decentralized prediction market platform that harnesses collective intelligence to forecast Bitcoin price movements on the Stacks blockchain. The protocol creates trustless prediction markets where participants can stake STX tokens on Bitcoin price direction forecasts, with transparent oracle-based resolution and proportional reward distribution to successful predictors.

## 🎯 Key Features

- **🔮 Decentralized Prediction Markets** - Create and participate in trustless Bitcoin price forecasting markets
- **🎯 Oracle-Based Resolution** - Transparent price resolution using reliable oracle feeds
- **💰 Proportional Rewards** - Fair distribution of rewards based on stake size and prediction accuracy
- **⚙️ Configurable Parameters** - Flexible market parameters for different prediction scenarios
- **🔒 Automated Settlement** - Built-in mechanisms for fee collection and reward distribution
- **⏰ Multi-Timeframe Windows** - Support for various prediction time horizons
- **🛡️ Enterprise Security** - Robust error handling and permission controls

## 🏗️ Architecture

### Core Components

1. **Prediction Markets**: Time-bounded markets with bull/bear pools
2. **Participant Stakes**: Individual user positions and reward claims
3. **Oracle Integration**: External price feed resolution
4. **Fee Management**: Platform fee collection and distribution
5. **Admin Controls**: Protocol parameter management

### Smart Contract Structure

```
contracts/
├── bitcast.clar          # Main protocol contract
└── ...
```

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) v18+ for testing
- [Git](https://git-scm.com/) for version control

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/sambo-tldr/bitcast.git
   cd bitcast
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify installation**

   ```bash
   clarinet check
   ```

### Development Setup

1. **Start local development environment**

   ```bash
   clarinet integrate
   ```

2. **Run tests**

   ```bash
   npm test
   ```

3. **Run tests with coverage**

   ```bash
   npm run test:report
   ```

4. **Watch mode for development**

   ```bash
   npm run test:watch
   ```

## 📖 Usage Guide

### Creating a Prediction Market

Only the contract owner can create new prediction markets:

```clarity
(contract-call? .bitcast launch-prediction-market
  u5000000000  ;; Opening price (50,000 USD in micro-units)
  u1000        ;; Start block
  u2000        ;; End block
)
```

### Casting Predictions

Users can stake STX tokens on price direction:

```clarity
;; Bull prediction (price will increase)
(contract-call? .bitcast cast-prediction
  u0           ;; Market ID
  "bull"       ;; Direction
  u10000000    ;; Stake amount (10 STX)
)

;; Bear prediction (price will decrease)
(contract-call? .bitcast cast-prediction
  u0           ;; Market ID
  "bear"       ;; Direction
  u5000000     ;; Stake amount (5 STX)
)
```

### Market Resolution

Oracle resolves markets with final prices:

```clarity
(contract-call? .bitcast settle-market
  u0           ;; Market ID
  u5500000000  ;; Closing price (55,000 USD)
)
```

### Claiming Rewards

Winners can claim their proportional rewards:

```clarity
(contract-call? .bitcast claim-prediction-rewards u0)
```

## 🔧 Configuration

### Protocol Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `minimum-stake` | 1,000,000 μSTX (1 STX) | Minimum stake required |
| `platform-fee-rate` | 250 (2.5%) | Platform fee in basis points |
| `oracle-address` | Set by owner | Authorized oracle address |

### Administrative Functions

- **Update Oracle**: `update-oracle-address`
- **Set Minimum Stake**: `update-minimum-stake`
- **Adjust Platform Fee**: `update-platform-fee` (max 10%)
- **Withdraw Fees**: `withdraw-protocol-fees`

## 🧪 Testing

The project includes comprehensive test coverage:

```bash
# Run all tests
npm test

# Run with detailed reporting
npm run test:report

# Watch mode for development
npm run test:watch

# Check contract syntax
clarinet check
```

### Test Categories

- **Unit Tests**: Individual function testing
- **Integration Tests**: End-to-end market scenarios
- **Error Handling**: Edge cases and failure modes
- **Gas Optimization**: Cost analysis and optimization

## 📊 Contract Interface

### Public Functions

#### Market Management

- `launch-prediction-market(opening-price, start-block, end-block)` - Create new market
- `cast-prediction(market-id, direction, stake-amount)` - Place prediction
- `settle-market(market-id, closing-price)` - Resolve market (oracle only)
- `claim-prediction-rewards(market-id)` - Claim winnings

#### Administration

- `update-oracle-address(new-oracle)` - Update oracle address
- `update-minimum-stake(new-minimum)` - Set minimum stake
- `update-platform-fee(new-fee-rate)` - Adjust platform fee
- `withdraw-protocol-fees(amount)` - Withdraw collected fees

### Read-Only Functions

- `get-market-details(market-id)` - Market information
- `get-participant-stake(market-id, participant)` - User stake details
- `get-protocol-balance()` - Total protocol balance
- `get-market-statistics(market-id)` - Market analytics

## ⚠️ Error Codes

| Code | Error | Description |
|------|--------|-------------|
| u100 | ERR_UNAUTHORIZED | Insufficient permissions |
| u101 | ERR_NOT_FOUND | Market or stake not found |
| u102 | ERR_INVALID_PREDICTION | Invalid prediction parameters |
| u103 | ERR_MARKET_INACTIVE | Market not active |
| u104 | ERR_ALREADY_CLAIMED | Rewards already claimed |
| u105 | ERR_INSUFFICIENT_BALANCE | Insufficient STX balance |
| u106 | ERR_INVALID_PARAMETER | Invalid function parameter |
| u107 | ERR_MARKET_NOT_RESOLVED | Market not yet resolved |

## 🔐 Security Considerations

### Access Controls

- **Owner-only functions**: Market creation, parameter updates
- **Oracle-only functions**: Market resolution
- **User functions**: Staking and reward claiming

### Safety Mechanisms

- **Balance validation**: Prevents overspending
- **Timing controls**: Ensures proper market lifecycle
- **Double-claim protection**: Prevents reward re-claiming
- **Parameter bounds**: Limits fee rates and minimums

### Best Practices

- Always verify market status before operations
- Check user balances before staking
- Validate oracle authenticity
- Monitor for unusual market activity

## 🗺️ Roadmap

### Phase 1: Core Protocol ✅

- [x] Basic prediction market functionality
- [x] Oracle integration
- [x] Reward distribution system
- [x] Administrative controls

### Phase 2: Enhanced Features 🚧

- [ ] Multi-asset prediction markets
- [ ] Advanced market types (time-series, ranges)
- [ ] Liquidity provider rewards
- [ ] Governance token integration

### Phase 3: Ecosystem Growth 📋

- [ ] Web3 frontend interface
- [ ] Mobile application
- [ ] API integrations
- [ ] Cross-chain compatibility

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Code Standards

- Follow Clarity best practices
- Include comprehensive tests
- Update documentation
- Maintain backwards compatibility

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Stacks Foundation** for blockchain infrastructure
- **Hiro** for development tooling
- **Community Contributors** for continuous improvements
