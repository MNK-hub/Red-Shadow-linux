#!/bin/bash

# Colors
white="\033[1;37m"
grey="\033[0;37m"
purple="\033[0;35m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
Purple="\033[0;35m"
Cyan="\033[0;36m"
Cafe="\033[0;33m"
Fiuscha="\033[0;35m"
blue="\033[1;34m"
nc="\e[0m"

clear
echo -e "\033[0;36m"

read -s -p "Enter your password: " password
echo

expected_password="shadow"


if [ "$password" != "$expected_password" ]; then
  echo "Incorrect password!"
  exit 1
fi

echo -e "\033[0;35m"

echo "Welcome to shadow linux! Your password is correct."
banner() {
    clear
echo -e '\033[0;34m'
echo """
▒█▀▀▀█ █░░█ █▀▀█ █▀▀▄ █▀▀█ █░░░█
░▀▀▀▄▄ █▀▀█ █▄▄█ █░░█ █░░█ █▄█▄█
▒█▄▄▄█ ▀░░▀ ▀░░▀ ▀▀▀░ ▀▀▀▀ ░▀░▀░
###########################################"""
echo -e '\033[0;31m'
echo """
██╗░░░░░██╗███╗░░██╗██╗░░░██╗██╗░░██╗
██║░░░░░██║████╗░██║██║░░░██║╚██╗██╔╝
██║░░░░░██║██╔██╗██║██║░░░██║░╚███╔╝░
██║░░░░░██║██║╚████║██║░░░██║░██╔██╗░
███████╗██║██║░╚███║╚██████╔╝██╔╝╚██╗
╚══════╝╚═╝╚═╝░░╚══╝░╚═════╝░╚═╝░░╚═╝"""
echo -e "\033[1;31m"
echo "
Red shadow linux  A Error fix at  gui of kali
##########################################"
    text="coded by @shadow"
    delay=0.05

    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep $delay
    done
    printf "\n"
}

# Call the banner function
banner

# Call the fix_error function
fix_error


device_arch=$(dpkg --print-architecture)

setup_rootfs(){
    case "$device_arch" in
        aarch64)
            archtype="arm64"
            ;;
        arm)
            archtype="armhf"
            ;;
        amd64|x86_64)
            archtype="amd64"
            ;;
        i*86|x86)
            archtype="i386"
            ;;
        *)
            echo "unknown architecture"; exit 1 ;;
    esac

    base_url="https://kali.download/nethunter-images/current/rootfs/kalifs-${archtype}-minimal.tar.xz"
rootfs_file="kalifs-${archtype}-minimal.tar.xz"

if [ -f "$rootfs_file" ]; then
  local filename="$rootfs_file"

  echo "${G}File found:${W} ${Y}$filename${W}"
  echo "${B}1) Remove the file${W}"
  echo "${B}2) Rename the file${W}"
  echo "${B}3) Continue with the file${W}"

  read -p "${G}Enter your choice (1/2/3): ${W}" choice

  case $choice in
    1)
      rm "$filename"
      echo "${Y}$filename ${W}${B}File removed.${W}"
      wget "$base_url"
      ;;
    2)
	    new_name="kalifs-${archtype}-$(date +%s).tar.xz"
      mv "$rootfs_file" "$new_name"
      echo "$rootfs_file renamed to $new_name."
	    wget "$base_url"
      ;;
    3)
      echo "${B}Continuing with the file.${W}"
      wget "$base_url"
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac

  get_sha=$(sha256sum "$rootfs_file")
else
  echo "${R}File not found:${W} ${Y}$rootfs_file${W}"
  wget "$base_url"
get_sha=$(sha256sum "$rootfs_file" | cut -d' ' -f1)
fi

}

add_distro(){
banner
    echo -e "${R} [${W}-${R}]${C} Checking required packages...${W}"
    sed -i 's/kali/ /g' /data/data/com.termux/files/usr/bin/proot-distro
    folder_path="/data/data/com.termux/files/usr/var/lib/proot-distro"

    if [ -d "$folder_path" ]; then
        mkdir "${folder_path}/dlcache"
        mv "$rootfs_file" "${folder_path}/dlcache"
    else
        mkdir "$folder_path"
	mkdir "${folder_path}/dlcache"
        mv "$rootfs_file" "${folder_path}/dlcache"
    fi

    touch "$PREFIX/etc/proot-distro/kali.sh"
    cat <<EOF > "$PREFIX/etc/proot-distro/kali.sh"
# If you want to customize installation, please make a copy.
DISTRO_NAME="Kali Linux (nethunter)"
TARBALL_URL['$device_arch']="$base_url"
TARBALL_SHA256['$device_arch']="$get_sha"
EOF

}



check_pack() {
	banner
	echo -e "${R} [${W}-${R}]${C} Checking required packages..."${W}
if [[ `command -v pulseaudio` && `command -v proot-distro` && `command -v wget` ]]; then
        echo -e "\n${R} [${W}-${R}]${G} Packages already installed."${W}
    else
        packs=(pulseaudio proot proot-distro wget)
        for hulu in "${packs[@]}"; do
            type -p "$hulu" &>/dev/null || {
                echo -e "\n${R} [${W}-${R}]${G} Installing package : ${Y}$hulu${C}"${W}
                apt update -y
                apt upgrade -y
                apt install "$hulu" -y
            }
        done
    fi

}


install_rootfs() {
	banner
	echo -e "${R} [${W}-${R}]${C} Setting up Environment..."${W}
    if [[ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/kali" ]]; then
        echo -e "\n${R} [${W}-${R}]${G} Distro already installed."${W}
        exit 0
    else
        proot-distro install kali
        termux-reload-settings
    fi

    if [[ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/kali" ]]; then
        echo -e "\n${R} [${W}-${R}]${G} Installed Successfully !!"${W}
    else
        echo -e "\n${R} [${W}-${R}]${G} Error Installing Distro !\n"${W}
        exit 0
    fi
    if [[ -e "$PREFIX/var/lib/proot-distro/installed-rootfs/kali /root/gui.sh" ]]; then
        chmod +x $PREFIX/var/lib/proot-distro/installed-rootfs/kali/root/shadow-linux.sh
    else
        cp -f /data/data/com.termux/files/home/Red-Shadow-linux/shadow-linux.sh $PREFIX/var/lib/proot-distro/installed-rootfs/kali/root/shadow-linux.sh
        chmod +x $PREFIX/var/lib/proot-distro/installed-rootfs/kali/root/shadow-linux.sh
    fi
}

add_sound() {
    banner
    echo -e "\n${R} [${W}-${R}]${C} Fixing Sound Problem..."${W}
    if [[ ! -e "$HOME/.sound" ]]; then
        touch $HOME/.sound
    fi

    echo "pulseaudio --start --exit-idle-time=-1" > $HOME/.sound
    echo "pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> $HOME/.sound
}

notes() {
	echo "proot-distro login kali --bind /dev/null:/proc/sys/kernel/cap_last_last --shared-tmp --fix-low-ports" > $PREFIX/bin/kali
    if [[ -e "$PREFIX/bin/kali" ]]; then
        chmod +x $PREFIX/bin/kali
        termux-reload-settings
	echo -e "\n${R} [${W}-${R}]${G} kali-letest(CLI) is now Installed on your Termux"${W}
        echo -e "\n${R} [${W}-${R}]${G} Type ${C}kali${G} to run kali CLI."${W}
        echo -e "\n${R} [${W}-${R}]${G} If you Want to Use kali in GUI MODE then ,"${W}
        echo -e "\n${R} [${W}-${R}]${G} Run ${C}kali${G} first & then type ${C}bash shadow-linux.sh  "${W}
        echo -e "\n"
        exit 0
    else
        echo -e "\n${R} [${W}-${R}]${G} Error Installing Distro !"${W}
        exit 0
    fi
}

check_pack
setup_rootfs
add_distro
install_rootfs
add_sound
notes
