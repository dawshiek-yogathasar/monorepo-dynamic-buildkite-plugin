#!/bin/bash
set -ueo pipefail

function generate_command_pipeline_yml() {
  for pipeline_index in "${upload_pipeline_jobs[@]}";
    do
      validate_pipeline=$(read_pipeline_config "$pipeline" "PIPELINE")
      if [[ -n $validate_pipeline ]]; then
        add_command "$pipeline_index"
      fi
    done
}
# Function to orchestrate adding a command block in Pipeline
function add_command() {
    local pipeline=$1
    local pipeline_location
    pipeline_location=$(read_pipeline_config "$pipeline" "PIPELINE")
    echo >&2 "Generating pipeline upload for pipeline: ${pipeline_location}"
    add_label "$(read_pipeline_commands_config "$pipeline" "LABEL")"
    add_commands_to_block "${pipeline_location}"
}

# Sets label as stop level for each command block
function add_label_block() {
  local label=$1
  default_label="Upload Pipeline"

  if [[ -n $trigger ]]; then
      pipeline_yml+=("$(set_Padding 2)$(set_Padding 0)label: ${label:-$default_label}")
  fi
}

# Add Command Array Block
function add_command_array_block() {
    local label=$1
    pipeline_yml+=("$(set_Padding 4)commands:")
}

# Adds single commands
function add_command_in_block() {
  local command=$1

  if [[ -n $command ]]; then
      pipeline_yml+=("$(set_Padding 6)- ${command}")
  fi
}

# Handler for Commands to File 
function add_commands_to_block() {
  local pipeline=$1
  local commands_to_add
  commands=$(read_pipeline_commands "$pipeline")

  if [[ -n "$commands" ]]; then
    add_command_array_block

    while IFS=$'\n' read -r commands_to_add ; do
        add_command_in_block "$command"
    done <<< "$commands"
  fi
}

