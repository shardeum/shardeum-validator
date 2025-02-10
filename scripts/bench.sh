#!/bin/bash

# Method to log output to console and file
log_output() {
    echo "$1" | tee -a "$BENCHMARK_LOG"
}

# Method to ensure logs directory exists
setup_output_directory() {
    BENCHMARK_LOG="/home/node/app/logs/benchmark.log"
    if [ ! -f "$BENCHMARK_LOG" ]; then
        log_output "Benchmark log file not found. Creating file..."
        touch "$BENCHMARK_LOG"
    fi
    log_output "Benchmark log file: $BENCHMARK_LOG"
}

# Update the main script section
setup_output_directory

mkdir -p bench
cd bench

# Check if sysbench is installed
if ! command -v sysbench &> /dev/null
then
    log_output "sysbench could not be found. Installing..."
    if ! sudo apt update &>/dev/null; then
        log_output "Error: Failed to update apt repository."
        exit 1
    fi
    if ! sudo apt install -y sysbench &>/dev/null; then
        log_output "Error: Failed to install sysbench."
        exit 1
    fi
    log_output "sysbench installed successfully."
fi

# Check if curl is installed
if ! command -v curl &> /dev/null
then
    log_output "curl could not be found. Installing..."
    if ! sudo apt install -y curl &>/dev/null; then
        log_output "Error: Failed to install curl."
        exit 1
    fi
    log_output "curl installed successfully."
fi

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    log_output "jq could not be found. Installing..."
    if ! sudo apt install -y jq &>/dev/null; then
        log_output "Error: Failed to install jq."
        exit 1
    fi
    log_output "jq installed successfully."
fi

# Function to run sysbench and extract total events
run_sysbench() {
  local test_type=$1
  log_output "Running $test_type.."
  local sysbench_output
  sysbench_output=$(sysbench --threads=2 --time=6 "$test_type" run 2>&1)

  # Check for sysbench errors
  if [[ $? -ne 0 ]]; then
    log_output "Error: sysbench $test_type test failed."
    log_output "$sysbench_output"
    return 1
  fi

  # Extract total events using the most robust method (sed)
  local total_events
  total_events=$(echo "$sysbench_output" | grep "total number of events" | sed 's/.*total number of events: \+//')

  # Check if extraction was successful
  if [[ -z "$total_events" ]]; then
    log_output "Error: Could not extract 'total number of events' from $test_type test output."
    log_output "$sysbench_output"
    return 1
  fi

  log_output "$test_type: $total_events"
  return 0
}

# Function to run sysbench fileio test and extract reads/s, writes/s, and fsyncs/s
run_sysbench_fileio() {
  log_output "Running fileio.."
  # sysbench fileio test requires a prepare step
  if ! sysbench --threads=2 --time=6 --file-test-mode=rndrw fileio prepare &>/dev/null; then
    log_output "Error: sysbench fileio prepare failed."
    return 1
  fi
  local sysbench_output
  sysbench_output=$(sysbench --threads=2 --time=6 --file-test-mode=rndrw fileio run 2>&1)

  # Check for sysbench errors
  if [[ $? -ne 0 ]]; then
    log_output "Error: sysbench fileio test failed."
    log_output "$sysbench_output"
    return 1
  fi

  # Extract reads/s
  local reads_per_second
  reads_per_second=$(echo "$sysbench_output" | grep "reads/s" | awk '{print $2}')

  # Extract writes/s
  local writes_per_second
  writes_per_second=$(echo "$sysbench_output" | grep "writes/s" | awk '{print $2}')

  # Extract fsyncs/s
  local fsyncs_per_second
  fsyncs_per_second=$(echo "$sysbench_output" | grep "fsyncs/s" | awk '{print $2}')

  # Check if extraction was successful
  if [[ -z "$reads_per_second" || -z "$writes_per_second" || -z "$fsyncs_per_second" ]]; then
    log_output "Error: Could not extract reads/s, writes/s, or fsyncs/s from fileio test output."
    log_output "$sysbench_output"
    return 1
  fi

  log_output "fileio reads/s: $reads_per_second"
  log_output "fileio writes/s: $writes_per_second"
  log_output "fileio fsyncs/s: $fsyncs_per_second"
  return 0
}

# Download and extract blake2b benchmark
if ! curl -o bench.tar.gz "https://chabot.dev/bench.tar.gz" &>/dev/null; then
  log_output "Error: Failed to download bench.tar.gz"
  exit 1
fi

tar -xzf bench.tar.gz

# Run blake2b benchmark and extract tps
run_blake2b_benchmark() {
  log_output "Running blake2b.."
  local sysbench_output
  sysbench_output=$(sysbench --threads=2 --time=6 blake2b_benchmark.lua run 2>&1)

  # Check for sysbench errors
  if [[ $? -ne 0 ]]; then
    log_output "Error: sysbench blake2b benchmark failed."
    log_output "$sysbench_output"
    return 1
  fi

  # Extract tps using jq (if available) or fallback to grep and awk
  local tps_value
  tps_value=$(echo "$sysbench_output" | jq -r '.[0].tps' 2> /dev/null)
  if [[ -z "$tps_value" ]]; then
      tps_value=$(echo "$sysbench_output" | grep '"tps":' | awk -F ': ' '{print $2}' | tr -d ',')
  fi

  # Check if extraction was successful
  if [[ -z "$tps_value" ]]; then
    log_output "Error: Could not extract tps from blake2b benchmark output."
    log_output "$sysbench_output"
    return 1
  fi

  log_output "blake2b tps: $tps_value"
  return 0
}

# Run the tests and store the results
threads_result=$(run_sysbench threads)
cpu_result=$(run_sysbench cpu)
memory_result=$(run_sysbench memory)
fileio_results=$(run_sysbench_fileio)
blake2b_result=$(run_blake2b_benchmark)

# Check if all tests were successful
if [[ -z "$threads_result" || -z "$cpu_result" || -z "$memory_result" || -z "$fileio_results" || -z "$blake2b_result" ]]; then
    log_output "Error during sysbench tests. Exiting."
    exit 1
fi

# Print and save the results
log_output "=== Benchmark Results ==="
log_output "$blake2b_result"
log_output "$cpu_result"
log_output "$memory_result"
log_output "$threads_result"
log_output "$fileio_results"
log_output "======================="

cd ..
rm -rf bench

exit 0
