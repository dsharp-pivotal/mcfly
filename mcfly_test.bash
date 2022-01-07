#!/usr/bin/env bash

. mcfly

stash=$(mktemp -d)

bindir=$(mktemp -d)
touch $bindir/fly-1.0
touch $bindir/fly-1.1
touch $bindir/fly-2.0
touch $bindir/fly-2.5
touch $bindir/not-fly
touch $bindir/fly  # symlink to mcfly

fake_HOME=$(mktemp -d)
HOME=$fake_HOME
yq e -n '.targets.t1.api = "https://t1.example.com"' >$fake_HOME/.flyrc

test_latest_downloaded_fly_version() {
  expect [ $(latest_downloaded_fly_version) = "2.5" ]
}

test_target_api() (
  expect [ $(target=t1; target_api) = "https://t1.example.com" ]
  die() {
    echo "$*" >$stash/die_msg
  }
  target=bad; target_api >/dev/null
  expect [ "$(cat $stash/die_msg)" = 'Target "bad" could not be found in ~/.flyrc' ]
)

test_api_version() (
  curl() {
    echo "$*" >$stash/curl_args
    echo '{"version":"7.6.0","worker_version":"2.3"}'
  }
  api="example.com"
  expect [ "$(api_version)" = "7.6.0" ]
  expect [ "$(cat $stash/curl_args)" = "-s example.com/api/v1/info" ]
)

test_determine_fly_version() (
  fly() {
    parse_args "$@"
    determine_fly_version
    echo $version
  }

  target_api() {
    case "$target" in
      t1) echo "https://t1.example.com" ;;
    esac
  }

  api_version() {
    case "$api" in
      "https://t1.example.com") echo "3.1" ;;
      "https://t2.example.com") echo "3.2" ;;
    esac
  }

  expect [ "$(fly -h)" = "2.5" ]
  expect [ "$(fly targets)" = "2.5" ]
  expect [ "$(fly login)" = "" ]
  expect [ "$(fly nonsense)" = "" ]
  expect [ "$(fly -t t1 targets)" = "3.1" ]
  expect [ "$(fly -t t1 login)" = "3.1" ]
  expect [ "$(fly -t t1 login -c https://t2.example.com)" = "3.2" ]
  expect [ "$(fly -t t1 whatever)" = "3.1" ]
)

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

expect() {
  "$@" || fail "$testname: $*"
}

run_tests() {
  for testname in $(compgen -A function test_) ; do
    echo "$testname"
    $testname || fail "$testname"
  done
}

run_tests
rm -rf $bindir
rm -rf $fake_HOME  # typing rm -rf $HOME makes me nervous.
rm -rf $stash

echo "PASS"
