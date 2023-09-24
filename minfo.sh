#!/bin/bash

LOG_FILE="minfo_log.txt"

install_speedtest() {
    sudo apt-get install -y speedtest-cli > /dev/null 2>&1
}

update_and_upgrade() {
    if [[ "$(lsb_release -si)" == "Ubuntu" ]]; then
        echo -e "\e[1;35mUpdating and upgrading Ubuntu...\e[0m"
        echo "Updating and upgrading Ubuntu..."
        sudo apt-get update
        sudo apt-get upgrade -y
        echo "Update and upgrade completed for Ubuntu." >&1
    elif [[ "$(lsb_release -si)" == "Debian" ]]; then
        echo -e "\e[1;35mUpdating and upgrading Debian...\e[0m"
        echo "Updating and upgrading Debian..."
        sudo apt-get update
        sudo apt-get upgrade -y
        echo "Update and upgrade completed for Debian." >&1
    elif [[ "$(lsb_release -si)" == "CentOS" ]]; then
        echo -e "\e[1;35mUpdating and upgrading CentOS...\e[0m"
        echo "Updating and upgrading CentOS..."
        sudo yum update -y
        sudo yum upgrade -y
        echo "Update and upgrade completed for CentOS." >&1
    else
        echo -e "\e[1;31mUnsupported distribution. Update and upgrade manually.\e[0m"
    fi
}

display_info() {
    clear

    echo -e "\e[32m"
    cat << "EOF"
 ____    ____   _____                ___             
|_   \  /   _| |_   _|             .' ..]            
  |   \/   |     | |    _ .--.    _| |_     .--.     
  | |\  /| |     | |   [ `.-. |  '-| |-'  / .'`\ \   
 _| |_\/_| |_   _| |_   | | | |    | |    | \__. |   
|_____||_____| |_____| [___||__]  [___]    '.__.'   
   
EOF

    echo -e "\e[0m"
    echo -e "\e[1mMInfo - Custom system information display\e[0m"

    echo

    echo -e "\e[1;36mUser:\e[0m \e[1m$(whoami)\e[0m"
    echo -e "\e[1;36mIP Address:\e[0m \e[1m$(hostname -I)\e[0m"
    echo -e "\e[1;36mHostname:\e[0m \e[1m$(hostname)\e[0m"

    echo

    read -p "Do you want to update and upgrade the system? (y/n): " choice

    case $choice in
        [yY])
            echo -e "\e[1;35mUpdating and upgrading the system...\e[0m"
            echo "Updating and upgrading the system..."
            update_and_upgrade
            ;;
        *)
            echo -e "\e[1;35mSkipping update and upgrade.\e[0m"
            ;;
    esac

    echo

    install_speedtest

    echo -e "\e[1;36mCPU Information:\e[0m"
    echo -e "\e[1mModel:\e[0m $(lscpu | grep "Model name" | awk -F: '{print $2}' | sed 's/^[ \t]*//')"
    echo -e "\e[1mCores:\e[0m $(lscpu | grep "^CPU(s):" | awk -F: '{print $2}')"

    echo

    echo -e "\e[1;36mRAM and Cache:\e[0m"
    echo -e "\e[1mTotal RAM:\e[0m \e[1;33m$(free -h | grep "Mem:" | awk '{print $2}')\e[0m"
    echo -e "\e[1mUsed RAM:\e[0m \e[1;33m$(free -h | grep "Mem:" | awk '{print $3}')\e[0m"
    echo -e "\e[1mL3 Cache:\e[0m \e[1;33m$(lscpu | grep "L3 cache" | awk -F: '{print $2}' | sed 's/^[ \t]*//')\e[0m"

    echo

    echo -e "\e[1;36mSwap Information:\e[0m"
    echo -e "\e[1mTotal Swap:\e[0m \e[1;33m$(free -h | grep "Swap:" | awk '{print $2}')\e[0m"
    echo -e "\e[1mUsed Swap:\e[0m \e[1;33m$(free -h | grep "Swap:" | awk '{print $3}')\e[0m"

    echo

    echo -e "\e[1;36mDisk Space:\e[0m"
    echo -e "\e[1mTotal Disk:\e[0m \e[1;33m$(df -h --total | grep "total" | awk '{print $2}')\e[0m"
    echo -e "\e[1mUsed Disk Space:\e[0m \e[1;33m$(df -h --total | grep "total" | awk '{print $3}')\e[0m"
    echo -e "\e[1mFree Disk Space:\e[0m \e[1;33m$(df -h / | tail -n 1 | awk '{print $4}')\e[0m"

    echo

    echo -e "\e[1;36mNetwork Information:\e[0m"
    echo -e "\e[1mPing to 1.1.1.1:\e[0m"
    ping -c 4 1.1.1.1 | grep "min/avg/max" | awk '{print $4}' | cut -d'/' -f2
    echo -e "\e[1mPacket Loss:\e[0m"
    echo -e "\e[1;33m$(ping -c 10 1.1.1.1 | grep "packet loss" | awk -F, '{print $3}')\e[0m"

    echo

    echo -e "\e[1;36mLatest SSH Connection Attempts:\e[0m"
    grep "sshd" /var/log/auth.log | grep "Failed password" | tail -n 5

    echo

    echo -e "\e[1;35mRunning Speedtest...\e[0m"
    speedtest --simple | grep -E "Ping:|Download:|Upload:" || true
}

display_info
