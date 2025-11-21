#!/bin/bash

################################################################################
# WAHA Secure Installation Script
#
# This script installs WAHA (WhatsApp HTTP API) with maximum security
# on a fresh Ubuntu 22.04 server.
#
# Features:
# - Automated installation with interactive prompts
# - Maximum security hardening
# - SSL/TLS support with Cloudflare
# - Firewall configuration
# - Fail2ban protection
# - Automatic security updates
# - Daily security monitoring
#
# Usage: sudo bash install-waha.sh
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function (no secrets)
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)"
   exit 1
fi

# Banner
clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "         WAHA Secure Installation Script"
echo "         WhatsApp HTTP API with Maximum Security"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

################################################################################
# Step 1: Collect Information from User
################################################################################

log_step "Collecting installation information..."
echo ""

# Domain name
read -p "Enter your domain name (e.g., waha.example.com): " DOMAIN_NAME
if [[ -z "$DOMAIN_NAME" ]]; then
    log_error "Domain name is required"
    exit 1
fi

# SSH Port
read -p "Enter SSH port (default: 2222): " SSH_PORT
SSH_PORT=${SSH_PORT:-2222}

# WAHA Engine
echo ""
echo "Available WAHA Engines:"
echo "  1) WEBJS (default, free)"
echo "  2) NOWEB (requires PRO)"
echo "  3) VENOM (requires PRO)"
echo "  4) GOWS (requires PRO)"
read -p "Select engine (1-4, default: 1): " ENGINE_CHOICE
ENGINE_CHOICE=${ENGINE_CHOICE:-1}

case $ENGINE_CHOICE in
    1) WAHA_ENGINE="WEBJS" ;;
    2) WAHA_ENGINE="NOWEB" ;;
    3) WAHA_ENGINE="VENOM" ;;
    4) WAHA_ENGINE="GOWS" ;;
    *)
        log_warn "Invalid choice, using WEBJS"
        WAHA_ENGINE="WEBJS"
        ENGINE_CHOICE=1
        ;;
esac

# Check if selected engine requires PRO
REQUIRES_PRO=false
if [[ $ENGINE_CHOICE =~ ^[234]$ ]]; then
    REQUIRES_PRO=true
    log_warn "⚠️  Engine $WAHA_ENGINE requires WAHA PRO license"
fi

# PRO License
echo ""
if [[ "$REQUIRES_PRO" == "true" ]]; then
    log_step "This engine requires WAHA PRO license"
    read -sp "Enter your WAHA PRO license key: " WAHA_PRO_KEY
    echo ""
    if [[ -z "$WAHA_PRO_KEY" ]]; then
        log_error "ERROR: Engine $WAHA_ENGINE requires a PRO license key!"
        log_error "Please provide a valid license key or choose engine 1 (WEBJS - free)"
        exit 1
    else
        WAHA_VERSION="pro"
    fi
else
    read -p "Do you have a WAHA PRO license? (y/N): " HAS_PRO
    HAS_PRO=${HAS_PRO:-n}

    if [[ "$HAS_PRO" =~ ^[Yy]$ ]]; then
        read -sp "Enter your WAHA PRO license key: " WAHA_PRO_KEY
        echo ""
        if [[ -z "$WAHA_PRO_KEY" ]]; then
            log_warn "No license key provided, continuing with CORE version"
            WAHA_VERSION="core"
        else
            WAHA_VERSION="pro"
        fi
    else
        WAHA_VERSION="core"
    fi
fi

# SSL Certificates
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SSL Certificate Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Please paste your SSL certificate and private key."
echo "These will be stored securely and NOT logged."
echo ""

# Certificate - support both environment variables and interactive input
if [[ -n "$SSL_CERT" ]] && [[ -n "$SSL_KEY" ]]; then
    # Using environment variables (for automation)
    log_step "Using SSL certificates from environment variables"
else
    # Interactive input - read directly from terminal
    echo "Please provide your SSL certificate."
    echo "Paste the FULL certificate (from -----BEGIN to -----END), then press Enter and type 'END' on a new line:"

    SSL_CERT=""
    while IFS= read -r line; do
        if [[ "$line" == "END" ]]; then
            break
        fi
        SSL_CERT+="$line"$'\n'
    done

    # Remove trailing newline
    SSL_CERT="${SSL_CERT%$'\n'}"

    if [[ -z "$SSL_CERT" ]]; then
        log_error "SSL certificate is required"
        exit 1
    fi

    echo ""
    echo "Please provide your SSL private key."
    echo "Paste the FULL private key (from -----BEGIN to -----END), then press Enter and type 'END' on a new line:"

    SSL_KEY=""
    while IFS= read -r line; do
        if [[ "$line" == "END" ]]; then
            break
        fi
        SSL_KEY+="$line"$'\n'
    done

    # Remove trailing newline
    SSL_KEY="${SSL_KEY%$'\n'}"

    if [[ -z "$SSL_KEY" ]]; then
        log_error "SSL private key is required"
        exit 1
    fi
fi

# Generate random credentials (no logging)
WAHA_API_KEY=$(openssl rand -hex 16)
WAHA_DASHBOARD_PASSWORD=$(openssl rand -hex 16)
WHATSAPP_SWAGGER_PASSWORD=$(openssl rand -hex 16)

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Domain: $DOMAIN_NAME"
echo "SSH Port: $SSH_PORT"
echo "WAHA Engine: $WAHA_ENGINE"
echo "WAHA Version: $WAHA_VERSION"
echo "Credentials: Generated (will be saved to /root/waha-credentials.txt)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Proceed with installation? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    log_error "Installation cancelled"
    exit 0
fi

################################################################################
# Step 2: System Update
################################################################################

log_step "Updating system packages (this may take a few minutes)..."
apt update
apt upgrade -y
log_info "System updated successfully"

################################################################################
# Step 3: Install Docker
################################################################################

log_step "Installing Docker (this may take 2-3 minutes)..."
apt install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

log_info "Downloading Docker packages..."
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl start docker
systemctl enable docker >/dev/null 2>&1
log_info "Docker installed successfully"

################################################################################
# Step 3.5: Configure SSH Port (BEFORE Firewall!)
################################################################################

log_step "Configuring SSH port..."

# Backup original config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Update SSH port
if grep -q "^Port " /etc/ssh/sshd_config; then
    sed -i "s/^Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config
elif grep -q "^#Port 22" /etc/ssh/sshd_config; then
    sed -i "s/^#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
else
    sed -i "1i Port $SSH_PORT" /etc/ssh/sshd_config
fi

# Restart SSH to apply new port
systemctl restart sshd
log_info "SSH configured on port $SSH_PORT"

################################################################################
# Step 4: Configure Firewall
################################################################################

log_step "Configuring firewall (UFW)..."
apt install -y ufw

ufw default deny incoming >/dev/null 2>&1
ufw default allow outgoing >/dev/null 2>&1

ufw allow $SSH_PORT/tcp comment 'SSH' >/dev/null 2>&1
ufw allow 80/tcp comment 'HTTP' >/dev/null 2>&1
ufw allow 443/tcp comment 'HTTPS' >/dev/null 2>&1

ufw --force enable >/dev/null 2>&1
log_info "Firewall configured successfully"

################################################################################
# Step 5: Install and Configure Nginx
################################################################################

log_step "Installing Nginx..."
apt install -y nginx

# Create SSL directory and save certificates
mkdir -p /etc/nginx/ssl/$DOMAIN_NAME
echo "$SSL_CERT" > /etc/nginx/ssl/$DOMAIN_NAME/cert.pem
echo "$SSL_KEY" > /etc/nginx/ssl/$DOMAIN_NAME/key.pem
chmod 644 /etc/nginx/ssl/$DOMAIN_NAME/cert.pem
chmod 600 /etc/nginx/ssl/$DOMAIN_NAME/key.pem

# Create Nginx configuration
cat > /etc/nginx/sites-available/$DOMAIN_NAME << EOF
# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN_NAME;

    return 301 https://\$server_name\$request_uri;
}

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN_NAME;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/$DOMAIN_NAME/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/$DOMAIN_NAME/key.pem;

    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logs
    access_log /var/log/nginx/${DOMAIN_NAME}-access.log;
    error_log /var/log/nginx/${DOMAIN_NAME}-error.log;

    # Proxy to WAHA
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # WebSocket support
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

ln -sf /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t >/dev/null 2>&1
systemctl restart nginx
log_info "Nginx configured successfully"

################################################################################
# Step 6: Install WAHA
################################################################################

log_step "Installing WAHA..."
mkdir -p /opt/waha/data

# Determine Docker image
if [[ "$WAHA_VERSION" == "pro" ]]; then
    DOCKER_IMAGE="devlikeapro/waha-plus:latest"
else
    DOCKER_IMAGE="devlikeapro/waha:latest"
fi

# Create docker-compose.yml
cat > /opt/waha/docker-compose.yml << EOF
services:
  waha:
    image: $DOCKER_IMAGE
    container_name: waha
    restart: unless-stopped
    ports:
      - '127.0.0.1:3000:3000'
    environment:
      - WAHA_API_KEY=$WAHA_API_KEY
      - WAHA_DASHBOARD_USERNAME=admin
      - WAHA_DASHBOARD_PASSWORD=$WAHA_DASHBOARD_PASSWORD
      - WHATSAPP_SWAGGER_USERNAME=admin
      - WHATSAPP_SWAGGER_PASSWORD=$WHATSAPP_SWAGGER_PASSWORD
      - WHATSAPP_HOOK_URL=
      - WHATSAPP_HOOK_EVENTS=message,session.status
      - WAHA_LOG_LEVEL=info
      - WHATSAPP_API_PORT=3000
      - WHATSAPP_API_HOSTNAME=0.0.0.0
      - WHATSAPP_DEFAULT_ENGINE=$WAHA_ENGINE
EOF

# Add PRO key if provided
if [[ -n "$WAHA_PRO_KEY" ]]; then
    cat >> /opt/waha/docker-compose.yml << EOF
      - WAHA_LICENSE_KEY=$WAHA_PRO_KEY
EOF
fi

# Continue docker-compose.yml
cat >> /opt/waha/docker-compose.yml << EOF
    volumes:
      - ./data:/app/.sessions
    networks:
      - waha_network

networks:
  waha_network:
    driver: bridge

volumes:
  waha_data:
EOF

log_info "Downloading and starting WAHA Docker container (this may take 1-2 minutes)..."
cd /opt/waha
docker compose up -d
log_info "WAHA installed and started successfully"

################################################################################
# Step 7: Add SSH Security Settings
################################################################################

log_step "Adding SSH security hardening..."

# Add security settings (Port already configured in Step 3.5)
cat >> /etc/ssh/sshd_config << 'EOF'

# Enhanced Security Settings
PermitRootLogin prohibit-password
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
MaxAuthTries 3
MaxSessions 2
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
EOF

systemctl restart sshd
log_info "SSH hardened successfully"

################################################################################
# Step 8: Install and Configure Fail2ban
################################################################################

log_step "Installing Fail2ban..."
apt install -y fail2ban

cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/*error.log
maxretry = 5
bantime = 3600
findtime = 600

[nginx-limit-req]
enabled = true
port = http,https
logpath = /var/log/nginx/*error.log
maxretry = 10
bantime = 3600
findtime = 600

[nginx-botsearch]
enabled = true
port = http,https
logpath = /var/log/nginx/*access.log
maxretry = 2
bantime = 7200
findtime = 600
EOF

systemctl restart fail2ban
systemctl enable fail2ban >/dev/null 2>&1
log_info "Fail2ban configured successfully"

################################################################################
# Step 9: Configure Automatic Security Updates
################################################################################

log_step "Configuring automatic security updates..."
apt install -y unattended-upgrades apt-listchanges

cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
EOF

cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Download-Upgradeable-Packages "1";
EOF

systemctl enable unattended-upgrades >/dev/null 2>&1
systemctl start unattended-upgrades >/dev/null 2>&1
log_info "Automatic security updates configured"

################################################################################
# Step 10: Kernel Hardening
################################################################################

log_step "Applying kernel security hardening..."
cat > /etc/sysctl.d/99-security-hardening.conf << 'EOF'
# IP Forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# SYN Flood Protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 4096

# IP Spoofing Protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# ICMP Redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Bad Error Messages Protection
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Ping Broadcasts
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Log Suspicious Packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Performance and Security
net.core.somaxconn = 4096
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_rfc1337 = 1
EOF

sysctl -p /etc/sysctl.d/99-security-hardening.conf >/dev/null 2>&1
log_info "Kernel hardening applied"

################################################################################
# Step 11: Setup Security Monitoring
################################################################################

log_step "Setting up daily security monitoring..."
mkdir -p /opt/monitoring

cat > /opt/monitoring/daily-security-check.sh << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/security-check.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "===== Security Check Report - ${DATE} =====" >> ${LOG_FILE}

# SSH Failed Logins
echo "" >> ${LOG_FILE}
echo "--- SSH Failed Login Attempts (Last 24h) ---" >> ${LOG_FILE}
grep 'Failed password' /var/log/auth.log 2>/dev/null | tail -20 >> ${LOG_FILE} || echo "No failed attempts" >> ${LOG_FILE}

# Fail2ban Bans
echo "" >> ${LOG_FILE}
echo "--- Fail2ban Banned IPs ---" >> ${LOG_FILE}
fail2ban-client status sshd 2>/dev/null | grep 'Banned IP' >> ${LOG_FILE}

# Nginx Errors
echo "" >> ${LOG_FILE}
echo "--- Nginx Errors (Last 50) ---" >> ${LOG_FILE}
tail -50 /var/log/nginx/*error.log 2>/dev/null >> ${LOG_FILE} || echo "No errors" >> ${LOG_FILE}

# Docker Status
echo "" >> ${LOG_FILE}
echo "--- Docker Container Status ---" >> ${LOG_FILE}
docker ps -a >> ${LOG_FILE}

# Disk Usage
echo "" >> ${LOG_FILE}
echo "--- Disk Usage ---" >> ${LOG_FILE}
df -h >> ${LOG_FILE}

echo "" >> ${LOG_FILE}
echo "===== End of Report =====" >> ${LOG_FILE}
echo "" >> ${LOG_FILE}

# Keep only last 1000 lines
tail -1000 ${LOG_FILE} > ${LOG_FILE}.tmp && mv ${LOG_FILE}.tmp ${LOG_FILE}
EOF

chmod +x /opt/monitoring/daily-security-check.sh

# Add to cron
(crontab -l 2>/dev/null | grep -v 'daily-security-check'; echo '0 6 * * * /opt/monitoring/daily-security-check.sh') | crontab -

log_info "Security monitoring configured"

################################################################################
# Step 12: Save Credentials
################################################################################

log_step "Saving credentials..."
cat > /root/waha-credentials.txt << EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WAHA Installation Credentials
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Domain: https://$DOMAIN_NAME
SSH Port: $SSH_PORT

WAHA Dashboard:
  Username: admin
  Password: $WAHA_DASHBOARD_PASSWORD

API Access:
  API Key: $WAHA_API_KEY

Swagger Documentation:
  URL: https://$DOMAIN_NAME/docs
  Username: admin
  Password: $WHATSAPP_SWAGGER_PASSWORD

WAHA Configuration:
  Engine: $WAHA_ENGINE
  Version: $WAHA_VERSION

Important Files:
  - WAHA Config: /opt/waha/docker-compose.yml
  - WAHA Data: /opt/waha/data
  - Nginx Config: /etc/nginx/sites-available/$DOMAIN_NAME
  - SSL Certificates: /etc/nginx/ssl/$DOMAIN_NAME/
  - Security Log: /var/log/security-check.log

Useful Commands:
  - View WAHA logs: docker logs waha -f
  - Restart WAHA: cd /opt/waha && docker compose restart
  - Check Fail2ban: fail2ban-client status
  - View security log: cat /var/log/security-check.log

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
KEEP THIS FILE SECURE!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

chmod 600 /root/waha-credentials.txt
log_info "Credentials saved to /root/waha-credentials.txt"

################################################################################
# Installation Complete
################################################################################

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your WAHA instance is ready at: https://$DOMAIN_NAME"
echo ""
echo "📋 Credentials have been saved to: /root/waha-credentials.txt"
echo "   View with: cat /root/waha-credentials.txt"
echo ""
echo "⚠️  IMPORTANT NOTES:"
echo "   1. SSH port has been changed to: $SSH_PORT"
echo "   2. Reconnect with: ssh -p $SSH_PORT root@your-server-ip"
echo "   3. Password authentication is DISABLED - only SSH keys work"
echo "   4. Your credentials file is stored securely with 600 permissions"
echo ""
echo "🛡️  Security Features Enabled:"
echo "   ✓ Firewall (UFW) - Only essential ports open"
echo "   ✓ Fail2ban - 4 jails protecting SSH and Nginx"
echo "   ✓ Automatic security updates"
echo "   ✓ Daily security monitoring (check: /var/log/security-check.log)"
echo "   ✓ Kernel hardening"
echo "   ✓ SSL/TLS with strong ciphers"
echo ""
echo "📊 System Status:"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Display credentials (one time only)
cat /root/waha-credentials.txt

echo ""
log_warn "Make sure to save your credentials! They are stored in /root/waha-credentials.txt"
echo ""
