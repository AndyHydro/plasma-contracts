#!/bin/bash

ganache_port=${1:-8545}

ganache_running() {
  nc -z localhost "$ganache_port"
}

start_ganache() {
  $(yarn bin)/ganache-cli --port $ganache_port --accounts 100 --networkId 15 --gasLimit 8000000 --defaultBalanceEther 100 --mnemonic plasma_cash > ganache_run.log 2>&1 &
  ganache_pid=$!
  echo $ganache_pid
  echo $ganache_pid > ganache.pid
}

if ganache_running; then
  echo "Using existing ganache instance at port $ganache_port"
else
  start_ganache
fi
