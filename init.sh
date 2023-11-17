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

function command_exists {
    command -v "$1" &>/dev/null
}

function check_and_log {
    cmd=$1
    command_exists "$cmd"
    status=$?
    log_status $status "$cmd found" "$cmd not found"
    return $status
}

function check_and_install {
    cmd=$1
    install_cmd=$2

    if ! command_exists "$cmd"; then
        log "$cmd not found, installing..."
        eval "$install_cmd"
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

function install_xcode {
    log "installing xcode..."
    xcode-select --install
    log_status $? "xcode installed successfully" "xcode installation failed"
}

function install_homebrew {
    check_and_install "brew" "/bin/bash -c \"$(curl -fsSL $BREW_INSTALL_URL)\""
}

function brew_install {
    local package=$1
    if brew list --versions "$package" > /dev/null; then
        echo "$package is already installed"
    else
        brew install "$package"
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

function install_ansible_brew {
    check_and_install "ansible" "brew install ansible"
}

function install_ansible_apt {
    check_and_install "ansible" "apt install ansible"
}


function install_ansible_core {
    check_and_install "ansible" "pip install ansible-core"
}

function install_ansible_core_pip3 {
    check_and_install "ansible" "pip3 install ansible-core"
}

function install_stackify {
    check_and_install "stackify" "pip install stackify"
}

function install_stackify_pip3 {
    check_and_install "stackify" "pip3 install stackify"
}

function run_ansible {
    ansible-playbook main.yml
}

function check_environment {
    check_and_log "curl"
    check_and_log "python"
    check_and_log "pip"
    check_and_log "pyenv"
    check_and_log "brew"
    check_and_log "ansible"
}

function python_env_exists {
    check_and_log "python" && check_and_log "pip"
}

function python_env_macOS_exists {
    check_and_log "python" && check_and_log "pip"
}

function check_python_version {
    local python_version=$(python --version 2>&1 | cut -d " " -f 2)
    local major_version=$(echo $python_version | cut -d "." -f 1)
    local minor_version=$(echo $python_version | cut -d "." -f 2)

    if [ $major_version -gt 3 ] || ([ $major_version -eq 3 ] && [ $minor_version -ge 10 ]); then
        return 0
    else
        return 1
    fi
}

function install {
    if ! check_and_log "stackify"; then
        log "installing"
        if python_env_exists && check_python_version; then
            install_stackify
        else
            if [[ "$OSTYPE" == "darwin"* ]]; then
                if python_env_macOS_exists && check_python_version; then
                    install_stackify_pip3
                else
                    if ! check_and_log "xcode-select -p"; then
                        install_xcode
                    fi
                    if ! check_and_log "brew"; then
                        install_homebrew
                    fi
                    install_pyenv_dependencies
                    install_pyenv
                    install_python
                    init_pyenv
                    set_python_version
                    install_stackify
                fi
            fi
        fi
    fi
}


case $1 in
    --check-environment)
        check_environment
        ;;
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
        install_ansible_core
        ;;
    "")
        # install_homebrew
        # update_homebrew
        # install_pyenv
        # install_python
        # set_python_version
        # install_ansible
        check_environment
        install
        stackify
        ;;
    *)
        echo "Invalid argument: $1"
        exit 1
        ;;
esac
