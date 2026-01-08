# NexCore Donations

> Revolutionizing charitable giving through transparent, verifiable impact tracking on the Stacks blockchain

## Overview

NexCore Donations creates a trustless ecosystem for charitable giving where every donation is tracked, every impact is verified, and every beneficiary is accountable. Built on Stacks, the platform leverages smart contracts to ensure transparency and maximize the effectiveness of philanthropic efforts.

## Key Features

### 🎯 Transparent Project Funding
- Beneficiaries create projects with clear funding goals
- Real-time tracking of raised amounts vs targets
- Community-visible project status and verification

### 💰 Secure Donation System
- Direct STX donations to verified projects
- Minimum donation thresholds to ensure meaningful contributions
- Immutable donation records on-chain

### ✅ Decentralized Impact Verification
- Network of registered validators assess real-world impact
- Evidence-backed validations with IPFS hash references
- Reputation-based validator system prevents manipulation

### 🏆 Social Impact NFTs
- Donors receive mintable NFTs as proof of contribution
- Tradeable credentials representing verified charitable outcomes
- Permanent record of philanthropic impact

### 📊 Comprehensive Analytics
- Track total donations and donor statistics
- Monitor project progress and impact scores
- Validator performance and reputation metrics

## Smart Contract Architecture

### Core Data Structures

**Projects**
- Project metadata and funding goals
- Raised amounts and impact scores
- Verification and activity status
- Beneficiary information

**Donations**
- Donor identification and amounts
- Project association and timestamps
- Impact NFT minting status

**Validators**
- Reputation scoring system
- Validation count tracking
- Active status management

**Impact Validations**
- Project-specific impact scores (0-100)
- IPFS evidence hash storage
- Timestamp recording

## Getting Started

### Prerequisites
- Stacks wallet (Hiro Wallet, Xverse, etc.)
- STX tokens for donations and gas fees
- Clarinet CLI for local development

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/nexcore-donations
cd nexcore-donations

# Install Clarinet
curl -L https://github.com/hirosystems/clarinet/releases/download/latest/clarinet-linux-x64.tar.gz | tar xz

# Initialize project
clarinet integrate
```

### Deployment

```bash
# Check contract syntax
clarinet check

# Run tests
clarinet test

# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
```

## Usage Examples

### Creating a Project

```clarity
(contract-call? .nexcore-donations create-project 
  "Clean Water Initiative" 
  u100000000) ;; 100 STX target
```

### Making a Donation

```clarity
(contract-call? .nexcore-donations donate 
  u1          ;; project-id
  u5000000)   ;; 5 STX donation
```

### Registering as Validator

```clarity
(contract-call? .nexcore-donations register-validator)
```

### Submitting Impact Validation

```clarity
(contract-call? .nexcore-donations submit-validation
  u1                                          ;; project-id
  u85                                         ;; impact-score (0-100)
  "QmX7H3Kj9N2P4LmR8Tz5Vw6Yq1Bc3Df4Gh5")  ;; IPFS hash
```

### Minting Impact NFT

```clarity
(contract-call? .nexcore-donations mint-impact-nft 
  u1) ;; donation-id
```

## API Reference

### Read-Only Functions

- `(get-project (project-id uint))` - Retrieve project details
- `(get-donation (donation-id uint))` - Get donation information
- `(get-validator (validator principal))` - Check validator status
- `(get-donor-stats (donor principal))` - View donor statistics
- `(get-total-donations)` - Total platform donations count
- `(get-total-projects)` - Total projects created
- `(get-project-validation (project-id uint) (validator principal))` - Validation details

### Public Functions

- `(create-project (name string) (target-amount uint))` - Initialize new project
- `(donate (project-id uint) (amount uint))` - Contribute to project
- `(register-validator)` - Join validator network
- `(submit-validation (project-id uint) (impact-score uint) (evidence-hash string))` - Submit impact assessment
- `(release-funds (project-id uint))` - Withdraw verified funds (beneficiary only)
- `(verify-project (project-id uint))` - Mark project verified (owner only)
- `(mint-impact-nft (donation-id uint))` - Claim impact NFT
- `(set-min-donation (new-min uint))` - Update minimum donation (owner only)

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `err-owner-only` | Caller is not contract owner |
| u101 | `err-not-found` | Resource not found |
| u102 | `err-unauthorized` | Unauthorized action |
| u103 | `err-invalid-amount` | Invalid amount provided |
| u104 | `err-already-verified` | Already verified |
| u105 | `err-insufficient-balance` | Insufficient balance |

## Roadmap

- [ ] Multi-signature validation requirements
- [ ] Quadratic funding mechanism implementation
- [ ] Cross-chain bridge integration
- [ ] Mobile-first beneficiary interface
- [ ] Advanced dispute resolution system
- [ ] Cascading impact tracking (Ripple Effect)
- [ ] Integration with IoT sensors and satellite imagery
- [ ] Community governance token

## Security Considerations

- All fund transfers use native STX transfer functions
- Authorization checks on sensitive operations
- Minimum donation amounts prevent dust attacks
- Validator reputation system mitigates malicious validations
- Project verification gate before fund release

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

