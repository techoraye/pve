#!/bin/bash

sudo apt update
apt-get install nano btop htop gnupg2 curl gh git byobu

sudo apt install -y \
    bc bison build-essential curl flex g++-multilib gcc-multilib \
    git gnupg gperf imagemagick lib32ncurses-dev lib32readline-dev \
    lib32z1-dev libncurses-dev libsdl1.2-dev libssl-dev \
    libxml2 libxml2-utils lzop openjdk-11-jdk pngcrush \
    schedtool squashfs-tools xsltproc zip zlib1g-dev \
    python-is-python3 repo ccache

sudo byobu-enable --system
sudo sed -i '/# Byobu system-wide auto-start/,$d' /etc/profile
sudo bash -c 'cat >> /etc/profile' << "EOF"
# Byobu system-wide auto-start
if [ "$TERM" != "screen" ] && [ "$TERM" != "screen-256color" ] && [ -n "$PS1" ]; then
    exec byobu
fi
EOF

sed -i '/Global command lockdown for all non-root users/,+5d' /etc/profile
mkdir -p /opt/allowed-bin
chmod 755 /opt/allowed-bin
ln -s /bin/ls           /opt/allowed-bin/
ln -s /usr/bin/nano     /opt/allowed-bin/
ln -s /usr/bin/sed      /opt/allowed-bin/
ln -s /usr/bin/clear    /opt/allowed-bin/
ln -s /usr/bin/bash     /opt/allowed-bin/
ln -s /usr/bin/git      /opt/allowed-bin/
ln -s /usr/bin/make     /opt/allowed-bin/
ln -s /usr/bin/python3  /opt/allowed-bin/
ln -s /usr/bin/java     /opt/allowed-bin/
ln -s /usr/bin/javac    /opt/allowed-bin/
ln -s /usr/bin/ccache   /opt/allowed-bin/
ln -s /usr/bin/zip      /opt/allowed-bin/
ln -s /usr/bin/unzip    /opt/allowed-bin/
ln -s /usr/bin/curl     /opt/allowed-bin/
ln -s /usr/bin/rsync    /opt/allowed-bin/
ln -s /usr/bin/repo     /opt/allowed-bin/
ln -s /usr/bin/basename /opt/allowed-bin/
ln -s /usr/bin/dircolors /opt/allowed-bin/
ln -s /usr/bin/dirname   /opt/allowed-bin/
ln -s /usr/bin/gh        /opt/allowed-bin/
ln -s /usr/bin/lesspipe  /opt/allowed-bin/
ln -s /usr/bin/nproc     /opt/allowed-bin/
ln -s /usr/bin/mkdir     /opt/allowed-bin/
ln -s /usr/bin/rm        /opt/allowed-bin/
ln -s /usr/bin/ssh       /opt/allowed-bin/
ln -s /usr/bin/7z        /opt/allowed-bin/
ln -s /usr/bin/rsync     /opt/allowed-bin/
ln -s /usr/bin/mktemp    /opt/allowed-bin/

cat << 'EOF' >> /etc/profile
# ===== Global command lockdown for all non-root users =====
if [ "$USER" != "root" ]; then
    PATH=/opt/allowed-bin
    export PATH
fi
EOF
source /etc/profile
cat << 'EOF' > /usr/local/bin/whitelist
#!/bin/bash

WHITELIST_DIR="/opt/allowed-bin"

usage() {
    echo "Usage:"
    echo "  whitelist add <command>"
    echo "  whitelist remove <command>"
    echo "  whitelist list"
    exit 1
}

mkdir -p "$WHITELIST_DIR"

case "$1" in

    add)
        CMD="$2"
        [ -z "$CMD" ] && usage
        CMD_PATH=$(command -v "$CMD")
        [ -z "$CMD_PATH" ] && { echo "Command not found."; exit 1; }
        ln -sf "$CMD_PATH" "$WHITELIST_DIR/"
        echo "Whitelisted: $CMD"
        ;;

    remove)
        CMD="$2"
        [ -z "$CMD" ] && usage
        rm -f "$WHITELIST_DIR/$CMD"
        echo "Removed: $CMD"
        ;;

    list)
        ls -1 "$WHITELIST_DIR"
        ;;

    *)
        usage
        ;;
esac
EOF
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
sudo bash -c 'echo -e "LANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8" > /etc/default/locale'
sudo locale-gen en_US.UTF-8
locale

chmod +x /usr/local/bin/whitelist
sudo chmod -x /etc/update-motd.d/*
sudo tee /etc/update-motd.d/00-carbonforge >/dev/null << 'EOF'
#!/bin/bash

# Colors
CYAN="\033[1;38;5;51m"
GREEN="\033[1;32m"
BLUE="\033[1;38;5;39m"
WHITE="\033[1;37m"
YELLOW="\033[1;33m"
GREY="\033[2m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}───────────────────────────────────────────────${RESET}"
echo -e "        ${GREEN}CarbonForge Build Infrastructure${RESET}"
echo -e "       ${BLUE}Android ROM Builder • Secure SSH Node${RESET}"
echo -e "${CYAN}───────────────────────────────────────────────${RESET}"
echo
echo -e "${WHITE}Hostname:${RESET}      ${GREEN}CarbonForge${RESET}"
echo -e "${WHITE}Uptime:${RESET}        ${GREEN}$(uptime -p)${RESET}"
echo -e "${WHITE}Load:${RESET}          ${GREEN}$(cut -d ' ' -f1-3 /proc/loadavg)${RESET}"
echo -e "${WHITE}IP Address:${RESET}    ${GREEN}$(hostname -I | awk '{print $1}')${RESET}"
echo
echo -e "${YELLOW}Dashboard:${RESET}     https://carbonforge.techoraye.com/  ${GREY}(coming soon)${RESET}"
echo
echo -e "${RED}Unauthorized access is prohibited.${RESET}"
echo -e "${GREY}All activity is logged.${RESET}"
EOF
sudo chmod +x /etc/update-motd.d/00-carbonforge
sudo chmod +x /etc/update-motd.d/*
sudo rm -f /etc/motd
run-parts /etc/update-motd.d/
sudo chmod -x /etc/update-motd.d/00-header
sudo chmod -x /etc/update-motd.d/10-help-text
sudo chmod -x /etc/update-motd.d/50-motd-news
sudo chmod -x /etc/update-motd.d/80-livepatch
sudo chmod -x /etc/update-motd.d/91-contract-ua-esm-status
sudo chmod -x /etc/update-motd.d/97-overlayroot
sudo chmod -x /etc/update-motd.d/98-fsck-at-reboot
sudo chmod -x /etc/update-motd.d/98-reboot-required
sudo find /etc/update-motd.d/ -type f ! -name '00-carbonforge' -exec chmod -x {} \;
sudo hostnamectl set-hostname CarbonForge
echo "127.0.1.1   CarbonForge" | sudo tee -a /etc/hosts
sudo reboot
