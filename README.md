
# Eternacode AI Smart Contract 🤖⏳

A Solidity smart contract for managing AI model versioning with granular access control, designed for EVM-compatible blockchains (Scroll, Ethereum, Polygon, BSC, etc).

[![Solidity](https://img.shields.io/badge/Solidity-0.8%2B-blue)](https://soliditylang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Features ✨
- ✅ **AI model versioning** with timestamp tracking
- 🔑 **Granular access control per ID** (owner + authorized wallets)
- 📚 Advanced query methods:
  - Version pagination
  - Index-based version retrieval
  - Latest version per ID
  - User-specific model IDs
- 🛡️ Security modifiers for all operations
- 📡 EVM-compatible architecture
- 📊 Change tracking through events

## Core Components 🧩
```solidity
- EternacodeAI.sol
  ├── Structures:
  │   └── ModelVersion (dataHash, timestamp, author)
  │
  ├── Mappings:
  │   ├── idToVersions (ID => versions)
  │   ├── permissions (ID => wallet => bool)
  │   └── idToLatestAuthor (ID => last editor)
  │
  ├── Functions:
  │   ├── addVersion()       # Add new model version
  │   ├── getVersions()      # Get all versions
  │   ├── getLatestVersion() # Latest model version
  │   └── getUserLatestIds() # IDs edited by user
  │
  └── Events:
      ├── VersionAdded
      ├── PermissionGranted
      └── PermissionRevoked
```

## Query Methods 🔍
| Method                     | Description                          | Example                   |
|----------------------------|--------------------------------------|---------------------------|
| `getVersionsPaginated(id, N)` | Get last N model versions          | `getVersionsPaginated(1, 3)` |
| `getVersion(id, index)`     | Get specific version by index       | `getVersion(1, 0)`        |
| `getLatestVersion(id)`      | Get latest model version            | `getLatestVersion(1)`     |
| `getUserLatestIds(wallet)`  | Get IDs where wallet last edited    | `getUserLatestIds(0x123...)` |

## Security Considerations 🔒
- 🔐 Owner-exclusive permission management
- ⛽ Gas optimization using numeric IDs
- 🕵️ Third-party audits recommended for mainnet
- 🧩 Dedicated admin wallets advised
- 🔄 Regular dependency updates


## Contributing 🤝
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Follow [coding standards](.github/CODE_STYLE.md)
4. Submit a Pull Request

## Roadmap 🗺️
- [ ] IPFS integration for model data
- [ ] Web3.js/React demo interface
- [ ] Multi-signature support
- [ ] DAO-based governance
- [ ] Model training metadata support
- [ ] Federated learning integration

## License 📄
MIT License - See [LICENSE](LICENSE) for details.

