#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

BREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

last_log_time=0

function stdout {
    local message=$1
    echo "$message"
}

function log {
    local message=$1
    local current_time=$(date +%s)
    local timestamp=$(date +"%H:%M:%S")

    if [ $last_log_time -ne 0 ]; then
        local time_diff=$((current_time - last_log_time))
    else
        local time_diff=0
    fi

    echo "📚 [${timestamp}] (${time_diff}s) ${message}"
    last_log_time=$current_time
}


function log_status {
    local exit_code=$1
    local success_msg=$2
    local failure_msg=$3

    if [ $exit_code -eq 0 ]; then
        printf "${GREEN}"
        log "${success_msg}"
        printf "${NC}"
    else
        printf "${RED}"
        log "${failure_msg}"
        printf "${NC}"
    fi
}

function check_and_install {
    cmd=$1
    install_cmd=$2

    if ! command -v $cmd &>/dev/null; then
        log "$cmd not found, installing..."
        eval $install_cmd
        log_status $? "$cmd installed successfully" "$cmd installation failed"
    else
        log "$cmd already installed"
    fi
}

function update_homebrew {
    log "updating homebrew..."
    local output=$(brew update 2>&1)
    stdout "$output"
    if [[ $output == *"Already up-to-date."* ]]; then
        log_status $? "homebrew is already up to date"
    else
        log_status $? "homebrew updated successfully" "homebrew update failed"
    fi
}

function install_homebrew {
    check_and_install "brew" "/bin/bash -c \"$(curl -fsSL $BREW_INSTALL_URL)\""
}

function brew_install {
    local package=$1
    if brew list --versions $package > /dev/null; then
        echo "$package is already installed"
    else
        brew install $package
    fi
}

function install_pyenv_dependencies {
    brew_install "gcc"
    brew_install "openssl"
    brew_install "readline"
    brew_install "sqlite3"
    brew_install "xz"
    brew_install "zlib"
}

function install_pyenv {
    check_and_install "pyenv" "brew install pyenv"
}

function init_pyenv {
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
}

function install_python {
    check_and_install "python" "pyenv install 3.12.0"
}

function set_python_version {
    pyenv shell 3.12.0
    pyenv global 3.12.0
}

function install_ansible {
    check_and_install "ansible" "brew install ansible"
}

function run_ansible {
    ansible-playbook main.yml
}


case $1 in
    --brew)
        install_homebrew
        ;;
    --update)
        update_homebrew
        ;;
    --pyenv-dependencies)
        install_pyenv_dependencies
        ;;
    --pyenv)
        install_pyenv
        ;;
    --pyenv-init)
        init_pyenv
        ;;
    --python)
        install_python
        ;;
    --set-python-version)
        set_python_version
        ;;
    --ansible)
        install_ansible
        ;;
    "")
        install_homebrew
        update_homebrew
        # install_pyenv
        # install_python
        # set_python_version
        install_ansible
        ;;
    *)
        echo "Invalid argument: $1"
        exit 1
        ;;
esac
