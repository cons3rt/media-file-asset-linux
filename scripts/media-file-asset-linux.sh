#!/bin/bash

# Source the environment
if [ -f /etc/bashrc ] ; then
    . /etc/bashrc
fi
if [ -f /etc/profile ] ; then
    . /etc/profile
fi

# Establish a log file and log tag
logTag="media-file-asset-linux"
logDir="/opt/cons3rt-agent/log"
logFile="${logDir}/${logTag}-$(date "+%Y%m%d-%H%M%S").log"

######################### GLOBAL VARIABLES #########################

# Media directory
mediaDir=

# Media file staging directory
installDir="/opt/install_media"

####################### END GLOBAL VARIABLES #######################

# Logging functions
function timestamp() { date "+%F %T"; }
function logInfo() { echo -e "$(timestamp) ${logTag} [INFO]: ${1}" >> ${logFile}; }
function logWarn() { echo -e "$(timestamp) ${logTag} [WARN]: ${1}" >> ${logFile}; }
function logErr() { echo -e "$(timestamp) ${logTag} [ERROR]: ${1}" >> ${logFile}; }

function set_asset_dir() {
    # Ensure ASSET_DIR exists, if not assume this script exists in ASSET_DIR/scripts
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    if [ -z "${ASSET_DIR}" ] ; then
        logWarn "ASSET_DIR not found, assuming ASSET_DIR is 1 level above this script ..."
        export ASSET_DIR="${SCRIPT_DIR}/.."
    fi
    mediaDir="${ASSET_DIR}/media"
}

function main() {
    logInfo "Running ${logTag}..."
    set_asset_dir

    # Ensure the media directory exists
    if [ ! -d "${mediaDir}" ] ; then
        logErr "Media directory not found: ${mediaDir}"
        return 1
    else
        logInfo "Found media directory: ${mediaDir}"
    fi

    # Create the install directory
    logInfo "Creating directory: ${installDir}"
    mkdir -p ${installDir} >> ${logFile} 2>&1
    
    # Copy files to the install directory
    logInfo "Copying files: ${mediaDir} to ${installDir}"
    cp -Rf ${mediaDir}/* ${installDir}/ >> ${logFile} 2>&1
    if [ $? -ne 0 ]; then logErr "Problem copying file from ${mediaDir} to ${installDir}"; return 2; fi
    logInfo "Completed copying files to: ${installDir}"

    # Clean up the media directory to avoid 2 copies of media on the system
    logInfo "Cleaning up media dir to save space, removing: ${mediaDir}"
    rm -Rf ${mediaDir} >> ${logFile} 2>&1
    return 0
}

# Set up the log file
mkdir -p ${logDir}
chmod 700 ${logDir}
touch ${logFile}
chmod 644 ${logFile}

main
result=$?
cat ${logFile}

logInfo "Exiting with code ${result} ..."
exit ${result}
