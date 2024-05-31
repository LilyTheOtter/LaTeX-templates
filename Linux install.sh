#!/bin/bash

# Function to check if a package is installed on Debian-based distributions
is_installed_debian() {
    dpkg -s "$1" &> /dev/null
}

# Function to check if a package is installed on Arch-based distributions
is_installed_arch() {
    pacman -Q "$1" &> /dev/null
}

# Function to install packages on Debian-based distributions
install_debian() {
    packages_to_install=()
    for pkg in "$@"; do
        if ! is_installed_debian "$pkg"; then
            packages_to_install+=("$pkg")
        fi
    done

    if [ ${#packages_to_install[@]} -eq 0 ]; then
        echo "All packages are already installed."
    else
        sudo apt update
        sudo apt install -y "${packages_to_install[@]}"
    fi

    echo "Packages left alone: ${already_installed[@]}"
    echo "Packages installed: ${packages_to_install[@]}"
}

# Function to install packages on Arch-based distributions
install_arch() {
    packages_to_install=()
    for pkg in "$@"; do
        if ! is_installed_arch "$pkg"; then
            packages_to_install+=("$pkg")
        fi
    done

    if [ ${#packages_to_install[@]} -eq 0 ]; then
        echo "All packages are already installed."
    else
        sudo pacman -Syu --noconfirm
        sudo pacman -S --noconfirm "${packages_to_install[@]}"
    fi

    echo "Packages left alone: ${already_installed[@]}"
    echo "Packages installed: ${packages_to_install[@]}"
}

# List of packages to be installed on Debian-based distributions
debian_packages=(
    texlive-fonts-recommended
    texlive
    biber
    texlive-latex-extra
    texlive-bibtex-extra
    texlive-extra-utils
    texlive-lang-european
)

# List of packages to be installed on Arch-based distributions
arch_packages=(
    texlive-fontsrecommended
    texlive-core
    biber
    texlive-latexextra
    texlive-bibtexextra
    texlive-binextra
    texlive-langeuropean
)

# Determine the distribution and install the packages
if [ -f /etc/os-release ]; then
    source /etc/os-release
    case $ID in
        ubuntu|debian)
            for pkg in "${debian_packages[@]}"; do
                if is_installed_debian "$pkg"; then
                    already_installed+=("$pkg")
                fi
            done
            install_debian "${debian_packages[@]}"
            ;;
        arch)
            for pkg in "${arch_packages[@]}"; do
                if is_installed_arch "$pkg"; then
                    already_installed+=("$pkg")
                fi
            done
            install_arch "${arch_packages[@]}"
            ;;
        *)
            echo "Unsupported Linux distribution: $ID"
            exit 1
            ;;
    esac
else
    echo "Cannot determine the Linux distribution."
    exit 1
fi
