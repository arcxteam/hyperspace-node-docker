#!/bin/bash

# Define color variables
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Log file path
LOG_FILE="/root/script_progress.log"

# Function to log messages
log_message() {
    echo -e "$1"
    echo "$(date): $1" >> $LOG_FILE
}

# Retry function
retry() {
    local n=1
    local max=5
    local delay=10
    while true; do
        "$@" && return 0
        if (( n == max )); then
            return 1
        else
            log_message "Attempt $n/$max failed! Retrying in $delay seconds..."
            sleep $delay
        fi
        ((n++))
    done
}

# Function to handle errors
handle_error() {
    log_message "$1"
    exit 1
}

# Function to get the private key
get_private_key() {
    log_message "${CYAN}Preparing private key...${RESET}"
    read -p "Masukkan private key Anda: " private_key
    echo -e "$private_key" > /root/my.pem
    chmod 600 /root/my.pem
    log_message "${GREEN}Private key saved as my.pem and permissions set correctly.${RESET}"
}

# Function to check and install Docker
check_and_install_docker() {
    if ! command -v docker &> /dev/null; then
        log_message "${RED}Docker not found. Installing Docker...${RESET}"
        retry apt-get update -y || handle_error "Failed to update apt package list."
        retry apt-get install -y apt-transport-https ca-certificates curl software-properties-common || handle_error "Failed to install dependency packages."
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - || handle_error "Failed to add Docker GPG key."
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" || handle_error "Failed to add Docker repository."
        retry apt update -y || handle_error "Failed to update apt package list."
        retry apt install -y docker-ce || handle_error "Failed to install Docker CE."
        systemctl start docker || handle_error "Failed to start Docker."
        systemctl enable docker || handle_error "Failed to set Docker to start on boot."
        log_message "${GREEN}Docker installed and started.${RESET}"
    else
        log_message "${GREEN}Docker is already installed.${RESET}"
    fi
}

# Function to start Docker container
start_container() {
    log_message "${BLUE}Starting Docker container...${RESET}"
    retry docker run -d --name aios-container --restart unless-stopped -v /root:/root kartikhyper/aios /app/aios-cli start || handle_error "Failed to start Docker container."
    log_message "${GREEN}Docker container started.${RESET}"
}

# Function to wait for container initialization
wait_for_container_to_start() {
    log_message "${CYAN}Waiting for container to initialize...${RESET}"
    sleep 60
}

# Function to check daemon status
check_daemon_status() {
    log_message "${BLUE}Checking daemon status inside the container...${RESET}"
    docker exec -i aios-container /app/aios-cli status
    if [[ $? -ne 0 ]]; then
        log_message "${RED}Daemon is not running, restarting...${RESET}"
        docker exec -i aios-container /app/aios-cli kill
        sleep 2
        docker exec -i aios-container /app/aios-cli start
        log_message "${GREEN}Daemon restarted.${RESET}"
    else
        log_message "${GREEN}Daemon is running.${RESET}"
    fi
}

# Function to install local model (Update model path here)
install_local_model() {
    log_message "${BLUE}Installing local model...${RESET}"
    docker exec -i aios-container /app/aios-cli models add hf:mlc-ai/Llama-3.2-1B-Instruct-q4f16_1-MLC || handle_error "Failed to install local model."
}

# Function to run inference (Update model path here)
run_infer() {
    log_message "${BLUE}Running inference...${RESET}"
    retry docker exec -i aios-container /app/aios-cli infer --model hf:mlc-ai/Llama-3.2-1B-Instruct-q4f16_1-MLC --prompt "What is 'Artificial Intelligence'?" || handle_error "Inference task failed."
    log_message "${GREEN}Inference task completed successfully.${RESET}"
}

# Function to login to Hive
hive_login() {
    log_message "${CYAN}Logging into Hive...${RESET}"
    docker exec -i aios-container /app/aios-cli hive import-keys /root/my.pem || handle_error "Failed to import keys."
    docker exec -i aios-container /app/aios-cli hive login || handle_error "Hive login failed."
    docker exec -i aios-container /app/aios-cli hive connect || handle_error "Failed to connect to Hive."
    log_message "${GREEN}Hive login successful.${RESET}"
}

# Function to run Hive inference
run_hive_infer() {
    log_message "${BLUE}Running Hive inference...${RESET}"
    retry docker exec -i aios-container /app/aios-cli hive infer --model hf:mlc-ai/Llama-3.2-1B-Instruct-q4f16_1-MLC --prompt "Explain what a server is in simple terms." || handle_error "Hive inference task failed."
    log_message "${GREEN}Hive inference task completed successfully.${RESET}"
}

# Function to check Hive points
check_hive_points() {
    log_message "${BLUE}Checking Hive points...${RESET}"
    docker exec -i aios-container /app/aios-cli hive points || log_message "${RED}Failed to fetch Hive points.${RESET}"
    log_message "${GREEN}Hive points check complete.${RESET}"
}

# Function to get current signed-in keys
get_current_signed_in_keys() {
    log_message "${BLUE}Getting current signed-in keys...${RESET}"
    docker exec -i aios-container /app/aios-cli hive whoami || handle_error "Failed to get current signed-in keys."
}

# Function to clean up package lists
cleanup_package_lists() {
    log_message "${BLUE}Cleaning up package lists...${RESET}"
    sudo rm -rf /var/lib/apt/lists/* || handle_error "Failed to clean up package lists."
}

# Main script flow
check_and_install_docker
get_private_key
start_container
wait_for_container_to_start
check_daemon_status
install_local_model
run_infer
hive_login
run_hive_infer
check_hive_points
get_current_signed_in_keys
cleanup_package_lists

log_message "${GREEN}All steps completed successfully!${RESET}"

# Loop to repeat every hour
while true; do
    log_message "${CYAN}Restarting process every 1 hour...${RESET}"

    docker exec -i aios-container /app/aios-cli kill || log_message "${RED}Failed to kill daemon process.${RESET}"

    docker exec -i aios-container /app/aios-cli status
    if [[ $? -ne 0 ]]; then
        log_message "${RED}Daemon startup failed, retrying...${RESET}"
    else
        log_message "${GREEN}Daemon is running, status checked.${RESET}"
    fi

    run_infer

    docker exec -i aios-container /app/aios-cli hive login || log_message "${RED}Hive login failed.${RESET}"
    docker exec -i aios-container /app/aios-cli hive connect || log_message "${RED}Failed to connect to Hive.${RESET}"

    run_hive_infer

    log_message "${GREEN}Loop completed. Waiting for 1 hour...${RESET}"
    sleep 3600
done &
