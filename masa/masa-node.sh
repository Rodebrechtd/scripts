#!/bin/bash
source variables.sh
#Install Go

#Git Clone
function git_clone {
    echo "Clonening ${repo}..."
    git clone ${repo}
    echo "${repo} cloned..."
}

function git_change_check {
if git diff-index --quiet HEAD --; then
  echo "Git is up to date"
else
  echo "Git repo is behind"
fi
}

# Pull changes from git repository
function git_pull {
    echo "Pulling changes from git repository..."
    git pull
    echo "Git pull completed."
}


function check_service {
    if systemctl list-units --type=service --all | grep -q "$service"; then
        echo "Service ${service} exists."
    else
        echo "Service ${service} does not exist."
    fi
}


# Check if masa-node.service is running
function check_service_status {
    if systemctl is-active --quiet masa-node.service; 
    then
        echo "${service} is running."
    else
        echo "${service} is not running."
    fi
}


# Build the masa-node binary
function go_build {
    echo "Building masa-node binary..."
    go build -v -o masa-node ./cmd/masa-node
    echo "masa-node binary built successfully."
}

#Install Contracts
function install_contracts {
    echo "Installing contracts..."
    cd contracts/
    npm instal
    cd ..
    echo "Contracts installed..."
}

# Start the masa-node.service
function start_node {
    echo "Starting ${service}..."
    systemctl start ${service}
    check_service_status
}

#Stop the masa-node.service
function stop_node {
    if check_service_status; then
        echo "Stoping ${service}..."
        systemctl stop ${service}
        echo "${service} stoped."
    else
        echo "${service} is not running"
    fi
}

function logs {
    tail -f masa_oracle_node.log
}

function update {
    if ! git_change_check; 
    then
        echo  "Node update started..."
        stop_node
        git_pull
        go_build
        install_contracts
        start_node
        logs
    else
        echo "Node is up to date"
    fi
}


if [ "$1" == "update" ]; then
    update
fi