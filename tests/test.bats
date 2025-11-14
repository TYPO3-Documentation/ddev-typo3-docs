#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=TYPO3-Documentation/ddev-typo3-docs

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support
  bats_require_minimum_version 1.5.0
  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d -t ${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success

  cp -rf "$DIR/tests" "$TESTDIR"
  cp -rf "$DIR/Documentation" "$TESTDIR"
  find . -type f
  run ddev start -y
  assert_success
}

health_checks() {
  echo "Evaluating output from rendering" >&3
  run ddev logs -s typo3-docs
  assert_success
  assert_output --partial "Server running at http://"

  echo "Showing output from rendering" >&3
  ddev logs -s typo3-docs >&3

  echo "Send request from 'web' to the api" >&3
  export HTML_ASSERT="DDEV TYPO3 Documentation Add-On main"
  echo "Curling..."
  run ddev exec "curl -s --fail -H 'Content-Type: text/html' -X GET 'http://typo3-docs:1337/'"
  assert_success
  assert_output --partial "${HTML_ASSERT}"

  echo "Docs via HTTP from outside to http://${PROJNAME}.ddev.site:1337 is shown" >&3
  run curl -sfL http://${PROJNAME}.ddev.site:1337
  assert_success
  assert_output --partial "${HTML_ASSERT}"

  echo "Docs via HTTPS from outside is shown" >&3
  run curl -sfL https://${PROJNAME}.ddev.site:1337
  assert_success
  assert_output --partial "${HTML_ASSERT}"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  echo "Teardown ${TESTDIR}" >&3
  ls -lR ${TESTDIR} >&3
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR} || true
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
