#!/bin/bash
#
# cerberus-token.sh is a helper script for getting a Cerberus Token during local development
# Use --help to see usage
#
# Dependencies: jq, curl
#

# Customize these settings based on your environment
CERBERUS_DEFAULT_HOST="https://demo.cerberus-oss.io"
# Depending on how login is configured for Cerberus, prompt for username or email address
#USER_PROMPT="Enter login: "
#USER_PROMPT="Enter AD username: "
USER_PROMPT="Enter email address: "
# If you've customized this script for your company, please modify version
SCRIPT_VERSION=1.0.0


# Global variables
CREDS=() # credential array (username,password)
OS=$(uname) # operating system
KEYCHAIN_SERVICE_NAME="cerberus-token-helper"

function print_version() {
    echo "cerberus-token.sh version is $SCRIPT_VERSION"
}

function print_troubleshooting() {
    echo ""
    echo "Troubleshooting:"
    echo "  Is the Cerberus hostname correct?"
    echo "  Are you able to login to dashboard with these credentials?"
    echo "  Login name depends on Cerberus configuration but is probably either Active Directory login OR email"
    echo "  Did you recently change your password?"
    echo "  Do you have the latest version of this script? Use --version option"
    echo ""
}

function print_help() {
    echo "cerberus-token.sh is a helper script for getting a Cerberus Token during local development"
    echo ""
    echo "Arguments are optional"
    echo "    --help                 prints this help"
    echo "    -h or --host HOST      Specify host on command line e.g. https://demo.cerberus.example.com"
    echo "    -v or --version        prints script version"
    echo "    --remove-creds         deletes any saved credentials (helpful if password changed)"
    echo "    --no-keychain-prompt   disables prompting to save/remove credentials to/from keychain"
    echo ""
    echo "Environment variables"
    echo "    CERBERUS_HOST          e.g. https://demo.cerberus.example.com"
    echo ""
    print_version
    print_troubleshooting
}

# Get credentials from keychain or prompt user
function get_creds() {
  case "$OS" in
    Darwin)
      mac_keychain_lookup
      ;;
    *)
      prompt_for_creds
      # TODO handle credential saving for other OS's
      ;;
  esac
}

# try to lookup username and password for KEYCHAIN_SERVICE_NAME via mac keychain
# if KEYCHAIN_SERVICE_NAME is not found, prompt for credentials and store in keychain (using KEYCHAIN_SERVICE_NAME name as identifier)
function mac_keychain_lookup() {
  # adapted from https://github.com/mogensen/keychain/blob/master/keychain.sh

  SEC=$(security find-generic-password -s "$KEYCHAIN_SERVICE_NAME" -g 2>&1 || true) # the || true keeps us from exiting prematurely

  local USER=$(echo "$SEC" | grep acct | cut -d \" -f 4)
  local PASS=$(echo "$SEC" | grep password | cut -d \" -f 2)

  # stored creds not found, prompt for them (and optionally save them for later)
  if [[ -z "$USER" || -z "$PASS" ]]; then

    # only prompt if running interactively
    if [[ ! -t 0 ]]; then
      exit 1;
    fi

    prompt_for_creds

    if [ -z ${NO_KEYCHAIN_PROMPT+x} ]
    then
        read -p "Would you like to save these credentials in the Keychain? (y/N): " -n 1 -r SAVE; echo

        if [[ $SAVE =~ ^[Yy]$ ]]; then
          echo -n "Saving..."
          /usr/bin/security add-generic-password -s "$KEYCHAIN_SERVICE_NAME" -a "${CREDS[0]}" -w "${CREDS[1]}" > /dev/null 2>&1
          echo "done"
        fi
    fi

  # stored creds found in keychain, put them in the global CREDS
  else
    echo "Login from keychain is $USER"
    CREDS[0]="$USER"
    CREDS[1]="$PASS"
  fi

}

# removes any stored credentials
function remove_creds() {
  case "$OS" in
    Darwin)
      echo -n "Removing any saved credentials from Keychain..."
      /usr/bin/security delete-generic-password -s "$KEYCHAIN_SERVICE_NAME" > /dev/null 2>&1
      echo "done";;
    *)
      # TODO handle credential removal for other OS's
      ;;
  esac
}

# prompt to remove stored credentials
function prompt_remove_creds() {
  if [ -z ${NO_KEYCHAIN_PROMPT+x} ]
  then
    case "$OS" in
      Darwin)
        echo "Would you like to remove any saved credentails? [Y/n]"
        read REMOVE_SAVED
        if [[ $REMOVE_SAVED != 'n' ]]
        then
          remove_creds
        fi
        ;;
      *)
        # TODO handle credential removal for other OS's
        ;;
    esac
  fi
}

# prompts the user for credentials and puts them in the global CREDS
function prompt_for_creds() {
  read -p "$USER_PROMPT" CREDS[0]
  read -s -p "Enter AD password: " CREDS[1]
  echo
}

# Parse command line arguments
# See http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --help)
        print_help
        exit 0
        ;;
        -h|--host)
        CERBERUS_HOST="$2"
        shift # past argument
        ;;
        --remove-creds)
        remove_creds
        exit 0
        ;;
        --no-keychain-prompt)
        NO_KEYCHAIN_PROMPT=true
        ;;
        -v|--version)
        print_version
        exit 0
        ;;
        *)
        # unknown option
        echo ""
        echo "Unknown Option: $key"
        echo ""
        print_help
        exit 1
        ;;
    esac
    shift # past argument or value
done

# Test if curl and jq are installed, if not give error message
command -v curl >/dev/null 2>&1 || { echo >&2 "Error: This script requires curl but it's not installed.  Aborting."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "Error: This script requires jq but it's not installed.  Aborting."; exit 1; }

# Use a file to cache the last used hostname
HOSTCACHE_FILE=~/.cerberus/hostcache

if [ -e $HOSTCACHE_FILE ]
then
    CERBERUS_DEFAULT_HOST=$(cat $HOSTCACHE_FILE)
fi

# Prompt for Cerberus hostname
if [ -z ${CERBERUS_HOST+x} ];
then
    echo -n "Enter your Cerberus Host [$CERBERUS_DEFAULT_HOST]: "
    read CERBERUS_HOST
    if [ -z ${CERBERUS_HOST} ]
    then
        # use default value if nothing was entered
        CERBERUS_HOST=${CERBERUS_DEFAULT_HOST}
    else
        # cache the last value
        mkdir -p ~/.cerberus
        echo $CERBERUS_HOST > $HOSTCACHE_FILE
    fi
fi

# Add https:// prefix if missing from CERBERUS_HOST
if [[ $CERBERUS_HOST != "https://"* ]]
then
    CERBERUS_HOST="https://$CERBERUS_HOST"
fi

echo "CERBERUS_HOST is '$CERBERUS_HOST'";

get_creds

# Auth call to Cerberus
CERBERUS_URL=${CERBERUS_HOST}/v2/auth/user
DATA=$(curl -s -u ${CREDS[0]}:${CREDS[1]} ${CERBERUS_URL})
STATUS=$(echo $DATA | jq --raw-output ".status" 2> /dev/null)

# Print success message
function print_success() {
    CERBERUS_TOKEN=$(echo $DATA | jq --raw-output ".data.client_token.client_token")
    echo "Success, use the following token for talking to Cerberus"
    echo ""
    echo "export CERBERUS_ADDR=${CERBERUS_HOST}"
    echo "export CERBERUS_TOKEN=${CERBERUS_TOKEN}"
    echo ""
    echo "The token has the following policies"
    echo $DATA | jq ".data.client_token.policies"
}

if [ "$STATUS" == "success" ]
then
    print_success
    exit 0

elif [ "$STATUS" == "mfa_req" ]
then
    STATE_TOKEN=$(echo $DATA | jq --raw-output ".data.state_token")

    echo "Multi-Factor Authentication is required (${CREDS[0]})"

    # if there is only one device, no need to prompt to choose device
    if [ "1" == `echo $DATA | jq ".data.devices | length"` ]
    then
        DEVICE_ID=`echo $DATA | jq --raw-output ".data.devices[0].id"`
        DEVICE_NAME=`echo $DATA | jq --raw-output ".data.devices[0].name"`

        echo -n "Enter factor for $DEVICE_NAME: "
        read FACTOR
    else
        # More than one MFA devices so prompt as to which to use
        echo "You have the following devices:"
        echo $DATA | jq ".data.devices"

        echo -n "Enter the device id you would like to use: "
        read DEVICE_ID

        echo -n "Enter factor: "
        read FACTOR
    fi

    CERBERUS_URL=${CERBERUS_HOST}/v2/auth/mfa_check
    DATA=$(curl -s ${CERBERUS_URL} \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{
        \"otp_token\": \"${FACTOR}\",
        \"device_id\": \"${DEVICE_ID}\",
        \"state_token\": \"${STATE_TOKEN}\"
    }")

    STATUS=$(echo $DATA | jq --raw-output ".status" 2> /dev/null)

    if [ "$STATUS" == "success" ]
    then
        print_success
        exit 0
    fi
fi

echo ""
echo "ERROR! sorry but something went wrong when calling ${CERBERUS_URL}"
echo "Response from server was:"
if [[ "$DATA" == *"<html"* || "$DATA" == *"<HTML"* ]]
then
    echo "$DATA"
else
    # only pipe to jq if content is not HTML
    echo $DATA | jq
fi

print_troubleshooting

# A common error is that someone has bad credentials saved.
# To help those users get out of that loop we prompt to remove creds here in case they were bad.
prompt_remove_creds

exit 1

