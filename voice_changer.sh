#!/bin/bash

# Helper script for running https://github.com/w-okada/voice-changer/
# Usage:
#   ./voice_changer.sh {load|unload|start|build}
#
#   load:       Load virtual microphone modules
#   unload:     Unload virtual microphone modules
#   start:      Start the Docker container in local mode
#   build:      Build the Docker container

# Function to get the module ID by name
get_module_id() {
    pactl list short modules | grep "$1" | awk '{print $1}'
}

# Function to load the modules
load_modules() {
    SINK_NAME="VirtualMicrophoneSink"
    SOURCE_NAME="VirtualMicrophone"

    NULL_SINK_MODULE="module-null-sink"
    REMAP_SOURCE_MODULE="module-remap-source"

    if ! pactl list short modules | grep -q "$NULL_SINK_MODULE"; then
        echo "Loading $NULL_SINK_MODULE"
        pactl load-module $NULL_SINK_MODULE sink_name=$SINK_NAME
    else
        echo "$NULL_SINK_MODULE is already loaded"
    fi

    if ! pactl list short modules | grep -q "$REMAP_SOURCE_MODULE"; then
        echo "Loading $REMAP_SOURCE_MODULE"
        pactl load-module $REMAP_SOURCE_MODULE master=$SINK_NAME.monitor source_name=$SOURCE_NAME
    else
        echo "$REMAP_SOURCE_MODULE is already loaded"
    fi
}

# Function to unload the modules
unload_modules() {
    NULL_SINK_MODULE_ID=$(get_module_id "module-null-sink")
    REMAP_SOURCE_MODULE_ID=$(get_module_id "module-remap-source")

    if [ -n "$NULL_SINK_MODULE_ID" ]; then
        echo "Unloading module-null-sink (ID: $NULL_SINK_MODULE_ID)"
        pactl unload-module $NULL_SINK_MODULE_ID
    else
        echo "module-null-sink is not loaded"
    fi

    if [ -n "$REMAP_SOURCE_MODULE_ID" ]; then
        echo "Unloading module-remap-source (ID: $REMAP_SOURCE_MODULE_ID)"
        pactl unload-module $REMAP_SOURCE_MODULE_ID
    else
        echo "module-remap-source is not loaded"
    fi
}

# Function to build the project with npm
build_project() {
    echo "Running npm run build:docker:vcclient"
    npm run build:docker:vcclient
}

# Function to start the project with USE_LOCAL environment variable
start_project() {
    echo "Running USE_LOCAL=on bash ./start_docker.sh"
    USE_LOCAL=on bash ./start_docker.sh
}

# Main script logic
case "$1" in
    load)
        load_modules
        ;;
    unload)
        unload_modules
        ;;
    build)
        build_project
        ;;
    start)
        start_project
        ;;
    *)
        echo "Usage: $0 {load|unload|build|start}"
        exit 1
        ;;
esac
