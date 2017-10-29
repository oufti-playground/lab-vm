#!/bin/bash

# Validation of parameters
if [ -z "${TESTS_URL}" ]
then
  echo "== No URL to test found. Please provide a value to the variable TESTS_URL"
  exit 1
fi

## Global Utility Variables
CURL_OPTS="--fail -v -s -L"
export CURL_OPTS

## Global Utility Functions
execute_vagrant_ssh_command() {
    vagrant ssh -c "${*}" -- -n -T
}
