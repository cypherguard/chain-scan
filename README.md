# ChainScan

```
   ____ _           _       ____                   
  / ___| |__   __ _(_)_ __ / ___|  ___ __ _ _ __   
 | |   | '_ \ / _  | |  _  \___ \ / __/ _  |  _ \  
 | |___| | | | (_| | | | | |___) | (_| (_| | | | | 
  \____|_| |_|\__,_|_|_| |_|____/ \___\__,_|_| |_| 
           v1.1 ChainScan
```

**ChainScan** is a comprehensive reconnaissance automation tool designed for security researchers, penetration testers, and bug bounty hunters. It streamlines the subdomain discovery and reconnaissance process by chaining together multiple powerful tools in an intelligent workflow.

## 🚀 Features

- **Multi-Tool Integration**: Combines Subfinder, Amass, Httpx, and Nmap for comprehensive reconnaissance
- **Parallel Processing**: Runs subdomain enumeration tools simultaneously for faster results
- **Smart Deduplication**: Automatically merges and deduplicates results from multiple sources
- **Live Host Detection**: Identifies active subdomains using httpx-toolkit
- **Port Scanning**: Automated Nmap scanning on discovered live hosts
- **Flexible Verbosity**: Granular control over output verbosity for each tool
- **Organized Output**: Clean file structure with timestamped results
- **Error Handling**: Robust tool availability checking and error management

## 📋 Requirements

### System Requirements
- Linux-based operating system (Ubuntu, Debian, Arch Linux, etc.)
- Bash shell
- Internet connectivity for passive reconnaissance

### Required Tools
- `subfinder` - Fast subdomain discovery tool
- `amass` - Network mapping and attack surface discovery
- `httpx-toolkit` - Fast and multi-purpose HTTP toolkit
- `nmap` - Network discovery and security auditing

## 📦 Installation

### Ubuntu/Debian (APT)

```bash
# Update package list
sudo apt update

# Install Nmap
sudo apt install nmap

# Install Go (required for subfinder and httpx)
sudo apt install golang-go

# Install Subfinder
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Install Httpx
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Install Amass
sudo apt install amass

# Add Go bin to PATH (add to ~/.bashrc for persistence)
export PATH=$PATH:~/go/bin

# Make ChainScan executable
chmod +x chainscan.sh
```

### Arch Linux (Pacman/AUR)

```bash
# Install base tools
sudo pacman -S nmap go

# Install AUR helper (yay) if not already installed
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si

# Install tools from AUR
yay -S subfinder-bin
yay -S httpx-bin  
yay -S amass

# Alternative: Install from source
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Add Go bin to PATH
export PATH=$PATH:~/go/bin

# Make ChainScan executable
chmod +x chainscan.sh
```

### Manual Installation (All Distributions)

```bash
# Install Go
wget https://golang.org/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Install tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/owasp-amass/amass/v4/...@master

# Install Nmap
# Ubuntu/Debian: sudo apt install nmap
# Arch: sudo pacman -S nmap
# CentOS/RHEL: sudo yum install nmap
```

## 🛠️ Usage

### Basic Usage
```bash
./chainscan.sh domain.com
```

### Command Line Options
```
Usage: ./chainscan.sh [options] <domain.com>

Options:
  -h, --help        Show help
  -v                Verbose output for all modules
  -vs               Verbose output for Subfinder
  -va               Verbose output for Amass
  -vp               Verbose output for Httpx
  -vn               Verbose output for Nmap
```

### Examples

#### Basic Reconnaissance
```bash
./chainscan.sh example.com
```

#### Full Verbose Output
```bash
./chainscan.sh -v example.com
```

#### Selective Verbose Output
```bash
# Verbose only for Amass and Nmap
./chainscan.sh -va -vn example.com

# Verbose only for Subfinder
./chainscan.sh -vs example.com
```

## 📁 Output Structure

ChainScan creates a directory named after the target domain with organized results:

```
example.com/
├── subfinder.txt       # Raw subfinder results
├── amass.txt          # Raw amass results  
├── amass_filtered.txt # Filtered amass results
├── all_subdomains.txt # Merged and deduplicated subdomains
├── alive.txt          # Live/responsive hosts
└── nmap_*.txt         # Individual nmap scan results for each live host
```

## 🎯 Use Cases

### Bug Bounty Hunting
- **Subdomain Discovery**: Find hidden subdomains for expanded attack surface
- **Live Asset Identification**: Quickly identify responsive targets
- **Service Enumeration**: Discover running services and versions
- **Initial Reconnaissance**: Gather comprehensive intelligence before manual testing

### Penetration Testing
- **External Assessment**: Map client's external attack surface
- **Scope Validation**: Verify all in-scope domains and subdomains
- **Service Discovery**: Identify potential entry points
- **Documentation**: Generate comprehensive reconnaissance reports

### Security Research
- **Domain Monitoring**: Track subdomain changes over time
- **Infrastructure Analysis**: Understand target's technology stack
- **Threat Intelligence**: Gather data for security analysis
- **Academic Research**: Study domain structures and patterns

### Red Team Operations
- **Target Profiling**: Build comprehensive target profiles
- **Attack Surface Mapping**: Identify potential attack vectors
- **Intelligence Gathering**: Collect operational intelligence
- **Preparation Phase**: Prepare for advanced persistent threat simulations

## 🐛 Troubleshooting

### Common Issues

**Tools not found**
```bash
# Check if tools are in PATH
which subfinder amass httpx nmap

# Add Go bin to PATH
export PATH=$PATH:~/go/bin
```

**Permission denied**
```bash
# Make script executable
chmod +x chainscan.sh
```

**No results from Amass**
- Amass might take longer for large domains
- Check internet connectivity
- Verify Amass installation: `amass version`

**Nmap requires root privileges (for some scan types)**
```bash
# Run with sudo if needed for advanced scans
sudo ./chainscan.sh -vn domain.com
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests, report bugs, or suggest features.

### Development Setup
```bash
git clone <repository-url>
cd chainscan
chmod +x chainscan.sh
```

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This tool is intended for educational purposes and authorized security testing only. Users are responsible for complying with applicable laws and regulations. Only test on systems you own or have explicit permission to test.

## 🔗 Related Tools

- [Subfinder](https://github.com/projectdiscovery/subfinder)
- [Amass](https://github.com/owasp-amass/amass)
- [Httpx](https://github.com/projectdiscovery/httpx)
- [Nmap](https://nmap.org/)

---
