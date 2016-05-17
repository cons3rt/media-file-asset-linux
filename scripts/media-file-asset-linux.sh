#!/bin/bash
# Created by J. Yennaco (5/16/2016)

# Use this script with no modifications to copy media files from
# your asset to /opt/install_media.  Otherwise, update the "installDir"
# variable below.

# Set log commands
logTag="media-file-asset-linux"
logInfo="logger -i -s -p local3.info -t ${logTag} [INFO] "
logWarn="logger -i -s -p local3.warning -t ${logTag} [WARNING] "
logErr="logger -i -s -p local3.err -t ${logTag} [ERROR] "

# Get the current timestamp and append to logfile name
TIMESTAMP=$(date "+%Y-%m-%d-%H%M")
source /etc/bashrc

######################### GLOBAL VARIABLES #########################

# Media file staging directory
installDir="/opt/install_media"

# Array to maintain exit codes of commands
resultSet=()

####################### END GLOBAL VARIABLES #######################

# Executes the passed command, adds the status to the resultSet
# array and return the exit code of the executed command
# Parameters:
# 1 - Command to execute
# Returns:
# Exit code of the command that was executed
function run_and_check_status() {
    local command="$@"
    ${command}
    local status=$?
    if [ ${status} -ne 0 ] ; then
        ${logErr} "Error executing: ${command}, exited with code: ${status}"
    else
        ${logInfo} "${command} executed successfully and exited with code: ${status}"
    fi
    resultSet+=("${status}")
    return ${status}
}

# Main function
function main() {
    ${logInfo} "Running ${logTag}..."
    
    # Ensure ASSET_DIR exists, if not assume this script exists in ASSET_DIR/scripts
    if [ -z "${ASSET_DIR}" ] ; then
        ${logWarn} "ASSET_DIR not found, assuming ASSET_DIR is 1 level above this script ..."
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        ASSET_DIR=${SCRIPT_DIR}/..
    fi
    mediaDir="${ASSET_DIR}/media"
    
    # Ensure the media directory exists
    if [ ! -d "${mediaDir}" ] ; then
        ${logErr} "Media directory not found: ${mediaDir}"
        return 1
    else
        ${logInfo} "Found media directory: ${mediaDir}"
    fi

    # Create the install directory
    run_and_check_status mkdir -p ${installDir}
    
    # Copy files to the install directory
    run_and_check_status cp -Rf ${mediaDir}/* ${installDir}/
    
    # Clean up the media directory to avoid 2 copies of media on the system
    run_and_check_status rm -Rf ${mediaDir} 

    # Check the results of commands from this script
    for resultCheck in "${resultSet[@]}" ; do
        if [ ${resultCheck} -ne 0 ] ; then
            ${logErr} "Non-zero exit code found: ${resultCheck}"
            return 2
        fi
    done
    ${logInfo} "Successfully staged media files!"
    return 0
}

main
result=$?

${logInfo} "Exiting with code ${result} ..."
exit ${result}
