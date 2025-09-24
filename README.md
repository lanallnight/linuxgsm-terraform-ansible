# LinuxGSM Terraform Ansible

🎮 **Automated Game Server Deployment** - Deploy and manage game servers on Vultr Cloud infrastructure using Terraform and Ansible with LinuxGSM integration.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 Overview

This project provides a complete Infrastructure as Code (IaC) solution for deploying game servers on Vultr Cloud. It combines:

- **Terraform** - Cloud infrastructure provisioning
- **Ansible** - Server configuration and management  
- **LinuxGSM** - Game server installation and management
- **Vultr Cloud** - High-performance VPS hosting

## 🎯 Supported Game Servers

| Game | Server Type | Status |
|------|-------------|---------|
| Minecraft | `mcserver` | ✅ Working |
| Team Fortress 2 | `tf2server` | ✅ Working |
| Quake Live | `qlserver` | ✅ Working |
| PalWorld | `pwserver` | ✅ Working |
| Counter-Strike 2 | `cs2server` | ⚠️ Testing |
| Counter-Strike: GO | `csgoserver` | ⚠️ Testing |
| Unreal Tournament | `utserver` | ⚠️ Testing |
| Return to Castle Wolfenstein | `rtcwserver` | ⚠️ Testing |
| Unreal Tournament '99 | `ut99server` | ⚠️ Testing |
| Battlefield 1942 | `bf1942server` | ⚠️ Testing |
| Unreal Tournament 2004 | `ut2k4server` | ⚠️ Testing |

## 📋 Prerequisites

### Required Tools
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 2.9
- [1Password CLI](https://developer.1password.com/docs/cli/get-started/) (for secrets management)

### Required Accounts & APIs
- [Vultr Account](https://www.vultr.com/) with API key
- [1Password Account](https://1password.com/) with service token
- Steam Account (for Steam-based games)
- Discord Webhook (optional, for notifications)

## 🛠️ Quick Start

### 1. Clone Repository
```bash
git clone <repository-url>
cd linuxgsm-terraform-ansible
```

### 2. Configure Environment Variables
```bash
# Copy example environment file
cp .env.example .env

# Edit with your credentials
export VULTR_API_KEY="your-vultr-api-key"
export ONEPASSWORD_TOKEN="your-1password-service-token"
export STEAM_USERNAME="your-steam-username"
export STEAM_PASSWORD="your-steam-password"
export DISCORD_WEBHOOK="your-discord-webhook-url"
```

### 3. Deploy a Game Server
```bash
cd game-servers-vultr

# Initialize Terraform
terraform init

# Deploy Minecraft server (example)
./terraform.sh apply minecraft

# Check deployment status
./terraform.sh output minecraft
```

## 📁 Project Structure

```
linuxgsm-terraform-ansible/
├── 📂 game-servers-vultr/          # Vultr cloud infrastructure
│   ├── 📄 main.tf                  # Main Terraform configuration
│   ├── 📄 instance.tf              # VM instance definitions
│   ├── 📄 provider.tf              # Cloud provider settings
│   ├── 📄 locals.tf                # Game port configurations
│   ├── 📄 ssh_keys.tf              # SSH key management
│   ├── 📄 terraform.sh             # Deployment script
│   ├── 📂 tfvars/                  # Game-specific configurations
│   └── 📂 playbooks/               # Ansible playbooks
├── 📂 ansible-role-linuxgsm/       # Ansible role for LinuxGSM
│   ├── 📂 tasks/                   # Installation & configuration tasks
│   ├── 📂 defaults/                # Default variables
│   ├── 📂 vars/                    # Environment variables
│   └── 📂 files/                   # Game-specific config files
├── 📂 game-servers-packer/         # Packer templates (optional)
└── 📄 README.md                    # This file
```

## 🔧 Configuration

### Game Server Configuration

Each game server has its own `.tfvars` file in the `tfvars/` directory:

```hcl
# Example: minecraft.tfvars
game_server_type = "mcserver"
instance_size = "vc2-2c-4gb"
```

### Available Instance Sizes
- `vc2-1c-1gb` - 1 vCPU, 1GB RAM (testing)
- `vc2-2c-4gb` - 2 vCPU, 4GB RAM (recommended)
- `vc2-4c-8gb` - 4 vCPU, 8GB RAM (high performance)

### Network Ports

Game servers automatically configure the following ports:

| Game | TCP Ports | UDP Ports |
|------|-----------|-----------|
| Minecraft | 25565 | 25565 |
| Team Fortress 2 | 27015, 27036, 27020 | 27015, 27036, 27020 |
| Quake Live | 27960, 5222 | 27960, 5222 |
| PalWorld | 8211, 27015 | 8211, 27015 |

## 🚀 Usage

### Deploy a Server
```bash
# Deploy specific game server
./terraform.sh apply <game-type>

# Examples:
./terraform.sh apply minecraft
./terraform.sh apply tf2server
./terraform.sh apply palworld
```

### Manage Servers
```bash
# Plan changes
./terraform.sh plan minecraft

# View outputs (IP addresses, etc.)
./terraform.sh output minecraft

# Destroy server
./terraform.sh destroy minecraft
```

### Connect to Server
```bash
# SSH connection info is automatically configured
ssh server_instance_minecraft  # Uses generated SSH config

# Manual connection
ssh -i ~/.ssh/minecraft_id_ed25519.pem root@<server-ip>
```

## 🔐 Security Features

- **SSH Key Management** - Automatic ED25519 key generation
- **Firewall Rules** - Restricted SSH access to specific IPs
- **1Password Integration** - Secure secret management
- **Workspace Isolation** - Separate Terraform workspaces per game

## 🎛️ Advanced Configuration

### Custom Game Configurations

Edit files in `ansible-role-linuxgsm/files/<game-type>/` to customize:
- Server properties
- Operator lists
- Game-specific settings

### Environment Variables

Required environment variables for Ansible:
```bash
GAME_SERVER_TYPE="mcserver"
STEAM_USERNAME="your-username"
STEAM_PASSWORD="your-password"
CS2SERVER_ID_HASH="your-cs2-token"
DISCORD_WEBHOOK="your-webhook-url"
```

## 🐛 Troubleshooting

### Common Issues

**SSH Connection Failed**
```bash
# Check if server is ready
terraform output
# Try manual connection
ssh -i ~/.ssh/<game>_id_ed25519.pem root@<ip>
```

**Game Server Not Starting**
```bash
# Connect to server and check logs
ssh server_instance_<game>
sudo -u <game-type> ./gameserver details
```

**Port Access Issues**
- Verify firewall rules in Vultr dashboard
- Check game-specific port configurations in `locals.tf`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-game-support`)
3. Commit changes (`git commit -am 'Add support for new game'`)
4. Push to branch (`git push origin feature/new-game-support`)
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📚 [LinuxGSM Documentation](https://linuxgsm.com/)
- 🌐 [Vultr API Documentation](https://www.vultr.com/api/)
- 💬 [Terraform Documentation](https://developer.hashicorp.com/terraform)
- 📖 [Ansible Documentation](https://docs.ansible.com/)

---

