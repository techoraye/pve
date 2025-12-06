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
chmod +x /usr/local/bin/whitelist
sudo chmod -x /etc/update-motd.d/*
sudo bash -c "cat > /etc/motd << 'EOF'
\e[1;38;5;51m───────────────────────────────────────────────\e[0m
        \e[1;38;5;47mCarbonForge Build Infrastructure\e[0m
       \e[1;38;5;39mAndroid ROM Builder • Secure SSH Node\e[0m
\e[1;38;5;51m───────────────────────────────────────────────\e[0m

\e[1;37mHostname:\e[0m      \e[1;32m$(hostname)\e[0m
\e[1;37mUptime:\e[0m        \e[1;32m$(uptime -p)\e[0m
\e[1;37mLoad:\e[0m          \e[1;32m$(cut -d ' ' -f1-3 /proc/loadavg)\e[0m
\e[1;37mIP Address:\e[0m    \e[1;32m$(hostname -I | awk '{print \$1}')\e[0m

\e[1;33mDashboard:\e[0m     http://carbonforge.techoraye.com/  \e[2m(coming soon)\e[0m

\e[1;36mNeed a package?\e[0m
\e[1;37mContact:\e[0m       \e[1;32m@techoraye\e[0m on Discord or Telegram.

\e[1;31mUnauthorized access is prohibited.\e[0m
\e[2mAll activity is logged.\e[0m
EOF"

sudo reboot
