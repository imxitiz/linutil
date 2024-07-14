#!/bin/bash

. ./common.sh

fastUpdate() {
    case ${PACKAGER} in
        pacman)
            if ! command_exists yay && ! command_exists paru; then
                echo "Installing yay as AUR helper..."
                sudo ${PACKAGER} --noconfirm -S base-devel
                cd /opt && sudo git clone https://aur.archlinux.org/yay-git.git && sudo chown -R ${USER}:${USER} ./yay-git
                cd yay-git && makepkg --noconfirm -si
            else
                echo "Aur helper already installed"
            fi
            if command_exists yay; then
                AUR_HELPER="yay"
            elif command_exists paru; then
                AUR_HELPER="paru"
            else
                echo "No AUR helper found. Please install yay or paru."
                exit 1
            fi
            ${AUR_HELPER} --noconfirm -S rate-mirrors-bin
            sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
            
            # If for some reason DTYPE is still unknown use always arch so the rate-mirrors does not fail
            local dtype_local=${DTYPE}
            if [ ${DTYPE} == "unknown" ]; then
                dtype_local="arch"
            fi
            sudo rate-mirrors --top-mirrors-number-to-retest=5 --disable-comments --save /etc/pacman.d/mirrorlist --allow-root ${dtype_local}
            ;;
        apt-get|nala)
            sudo apt-get update
            sudo apt-get install -y nala
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
            sudo nala update
            PACKAGER="nala"
            sudo ${PACKAGER} upgrade -y
            ;;
        dnf)
            ;;
        zypper)
            ;;
        *)
            echo -e "${RED}Unsupported package manager: ${PACKAGER}${RC}"
            exit 1
            ;;
    esac
}

updateSystem() {
    echo -e "${GREEN}Updating system${RC}"
    case ${PACKAGER} in
        nala)
            sudo ${PACKAGER} update -y
            sudo ${PACKAGER} upgrade -y
            ;;
        yum)
            sudo ${PACKAGER} update -y
            sudo ${PACKAGER} upgrade -y
            ;;
        dnf)
            sudo ${PACKAGER} update -y
            sudo ${PACKAGER} upgrade -y
            ;;
        pacman)
            sudo ${PACKAGER} -Syu --noconfirm
            ;;
        zypper)
            sudo ${PACKAGER} refresh
            sudo ${PACKAGER} update -y
            ;;
        *)
            echo -e "${RED}Unsupported package manager: ${PACKAGER}${RC}"
            exit 1
            ;;
    esac
}

checkEnv
fastUpdate
updateSystem
