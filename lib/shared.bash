#!/bin/bash

# Reads either a value or a list from plugin config
function plugin_read_list() {
  local prefix="BUILDKITE_PLUGIN_MONOREPO_DYNAMIC_$1"
  local suffix="$2"
  local parameter="${prefix}_0_${suffix}"
  local chained_parameter="${prefix}_0_${suffix}_0"

  # Reads nested list of multiple watch paths
  if [[ -n "${!parameter:-}" || -n "${!chained_parameter:-}" ]]; then
    local i=0
    while [[ -n "${!parameter:-}" || -n "${!chained_parameter:-}" ]]; do
      local parameter="${prefix}_${i}_${suffix}"
      # check for single path oldschool
      if [[ -n "${!parameter:-}" ]]; then
      	 echo "${!parameter}"
      else
        # check for new style
        local params=()
        local j=0
	      while [[ -n "${!chained_parameter:-}" ]]; do
		      params+=("${!chained_parameter}")
		      j=$((j+1))
		      chained_parameter="${prefix}_${i}_${suffix}_${j}"
	      done
        echo "${params[@]}"
      fi
      i=$((i+1))
      chained_parameter="${prefix}_${i}_${suffix}_0"
      parameter="${prefix}_${i}_${suffix}"
    done
  fi
  # Read one watch with one path
  if [[ -n "${!prefix:-}" ]]; then
    echo "${!prefix}"
  fi
}

function read_pipeline_config() {
  local pipeline_index=$1
  local config_key=$2
  local parameter="BUILDKITE_PLUGIN_MONOREPO_DYNAMIC_WATCH_${pipeline_index}_CONFIG_${config_key}"

  echo "${!parameter:-}"
}

function read_pipeline_build_env() {
  local pipeline_index=$1
  local prefix="BUILDKITE_PLUGIN_MONOREPO_DYNAMIC_WATCH_${pipeline_index}_CONFIG_BUILD_ENV"
  local parameter="${prefix}_0"

  if [[ -n "${!parameter:-}" ]]; then
    local i=0
    local parameter="${prefix}_${i}"
    while [[ -n "${!parameter:-}" ]]; do
      echo "${!parameter}"
      i=$((i+1))
      parameter="${prefix}_${i}"
    done
  fi
}

function read_pipeline_commands_config() {
  local pipeline_index=$1
  local config_key=$2
  local parameter="BUILDKITE_PLUGIN_MONOREPO_DYNAMIC_WATCH_${pipeline_index}_CONFIG_PIPELINE_${config_key}"

  echo "${!parameter:-}"
}

# Reads Commands specified in Watch -> Path -> Config -> Commands
# Used for Command Block for Upload Support
function read_pipeline_commands() {
  local pipeline_index=$1
  local prefix="BUILDKITE_PLUGIN_MONOREPO_DYNAMIC_WATCH_${pipeline_index}_CONFIG_PIPELINE_COMMANDS"
  local parameter="${prefix}_0"

  if [[ -n "${!parameter:-}" ]]; then
    local i=0
    local parameter="${prefix}_${i}"
    while [[ -n "${!parameter:-}" ]]; do
      echo "${!parameter}"
      i=$((i+1))
      parameter="${prefix}_${i}"
    done
  fi
}

# Padding Function for Yaml
function set_Padding() {
    local padding=$1

    #0 is used for dash + space for block seperation in Buildkite yaml
    if [[ $padding == 0 ]]; then
        echo "- "
    else
        echo $padding
        seq  -f " " -s '' $padding
    fi
}

function in_array() {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}