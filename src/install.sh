#!/bin/bash


# +-----------------+
# |    FUNCTIONS!   |
# +-----------------+

user_input() {
    local valid_options=("$@")
    local user_input

    read -p "==> " user_input

    if [[ " ${valid_options[@]} " =~ " ${user_input} " ]]; then
        input="$user_input"
    else
        echo "Invalid input. Please try again."
        echo "Valid options are: ${valid_options[*]}, and \"$user_input\" is not in that list."
        user_input "${valid_options[@]}"
    fi
}

check_command() {
    local command="$1"

    command_installed=0
    if command -v "$command" >/dev/null 2>&1; then
        command_installed=1
    fi
}

#  --------------------------------------------------------------------------------

# check root status
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi


echo "      ____             __             ___               _____ __                 "
echo "     / __ \____  _____/ /_____  _____/   |  ____  ____ / ___// /_____  ________  "
echo "    / / / / __ \/ ___/ //_/ _ \/ ___/ /| | / __ \/ __ \\__ \/ __/ __ \/ ___/ _ \ "
echo "   / /_/ / /_/ / /__/ ,< /  __/ /  / ___ |/ /_/ / /_/ /__/ / /_/ /_/ / /  /  __/ "
echo "  /_____/\____/\___/_/|_|\___/_/  /_/  |_/ .___/ .___/____/\__/\____/_/   \___/  "
echo "                                        /_/   /_/                                "
echo ""
echo "                                         Easy, flexible, docker-compose platform."
echo ""
echo ""
echo "  +--------------------------------------------------+"
echo "  |                     OPTIONS                      |"
echo "  |                                                  |"
echo "  |   0 . . . . . . Cancel install                   |"
echo "  |                                                  |"
echo "  |                                                  |"
echo "  |   1 . . . . . . Continue with install            |"
echo "  +--------------------------------------------------+"

user_input 0 1

if [ "$input" = "0" ]; then
    echo ">>> Abort."
    exit 0
fi

echo "+ Beginning installation."
echo "++ Checking if Docker is installed."
check_command docker
if [ "$command_installed" = 1 ]; then
    echo "+++ Docker is installed"
else
    echo "+++ Docker is NOT installed; Installing."
    echo "++++ Setting up Docker APT cert."
    apt-get update
    sudo apt-get install ca-certificates curl gnupg -y
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    echo "++++ Done installing cert."
    echo "++++ Re-update repos."
    sudo apt-get update
    echo "++++ Installing docker (This may take a while!)"
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

fi
