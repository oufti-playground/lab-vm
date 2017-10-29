#!/usr/bin/env bats

LOG_PREFIX="[Commons Tests]"

load "tests_helper"

@test "${LOG_PREFIX} The URL ${TESTS_URL} is reachable" {
  curl ${CURL_OPTS} "${TESTS_URL}"
}

@test "${LOG_PREFIX} We have a reachable Jenkins" {
  curl ${CURL_OPTS} "${TESTS_URL}/jenkins"
}
