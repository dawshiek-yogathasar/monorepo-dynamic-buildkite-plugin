#!/bin/bash
set -ueo pipefail

function generate_command_pipeline_yml() {
  local validate_pipeline
  for pipeline_index in "${upload_pipeline_jobs[@]}";
  do
    validate_pipeline=$(read_pipeline_commands_config "$pipeline_index" "LABEL")
    echo >&2 "Validate pipeline output : ${validate_pipeline}"
    if [[ -n $validate_pipeline ]]; then
      add_command "$pipeline_index"
    fi
    echo >&2 "Pipeline config has no label : ${pipeline_index}"
  done
}
# Function to orchestrate adding a command block in Pipeline
function add_command() {
    local pipeline=$1
    local pipeline_label
    pipeline_label=$(read_pipeline_commands_config "$pipeline" "LABEL")
    echo >&2 "Generating pipeline upload for pipeline using commands: ${pipeline_label}"
    add_label_block "$(read_pipeline_commands_config "$pipeline" "LABEL")"
    add_commands_to_block "${pipeline}"
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

