#!/usr/bin/env bash

# gh-key-fab (Cross-Platform): A script to determine if the current path matches a set of rules.
# Logging is disabled by default and can be enabled with -l or --log.
# Logging can be tagged with -n --name value to help identify specific key triggers
# Log files are auto trimmed to 1000 or set with -ml or --log-max-lines


paths=()
DEFAULT_LOG_FILE="/tmp/gh-key-fab.log"
LOG_FILE="" # Logging is disabled by default
LOG_MAX_LINES=1000
KEY_NAME=""


log_debug() {
  # Only log if a LOG_FILE has been set
  if [[ -z "$LOG_FILE" ]]; then
    return
  fi
  
  if [[ -z "$KEY_NAME" ]]; then
    local message="$1"
  else
    local message="$KEY_NAME | $1"
  fi

  local timestamp
  timestamp=$(date)
  
  echo "$timestamp | $message" >> "$LOG_FILE"
}

log_trim() {
  # Only trim the logs if a LOG_FILE has been set
  if [[ -z "$LOG_FILE" ]]; then
    return
  fi

  local line_count
  line_count=$(wc -l < "$LOG_FILE")

  # If the file is too long, trim it
  if (( line_count > LOG_MAX_LINES )); then
    local temp_log
    temp_log=$(mktemp)
    
    # Add a note at the top of the file that the trim occurred
    echo "**logs-trimmed** ($LOG_MAX_LINES) " > "$temp_log"

    # Get the last LOG_MAX_LINES and write them to a temp file
    tail -n "$LOG_MAX_LINES" "$LOG_FILE" >> "$temp_log"

    # Overwrite the original log with the trimmed version
    mv "$temp_log" "$LOG_FILE"
  fi
}

# --- Main script execution ---

# Process all command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--path)
      paths+=("$2")
      shift 2
      ;;
    -l|--log)
      if [[ -n "$2" && "$2" != -* ]]; then
        LOG_FILE="$2"
        shift 2
      else
        LOG_FILE="$DEFAULT_LOG_FILE"
        shift 1
      fi
      ;;
    -n|--name)
      if [[ -n "$2" && "$2" != -* ]]; then
        KEY_NAME="$2"
        shift 2
      else        
        shift 1
      fi
      ;;
    -ml|--log-max-lines) 
      LOG_MAX_LINES="$2"
      shift 2
      ;;
    *)
      shift 1
      ;;
  esac
done

if [[ ${#paths[@]} -eq 0 ]]; then
  log_debug "Result: NO MATCH (No paths provided)"
  log_trim
  exit 1
fi

CWD=$(pwd)

log_debug "Checking params | Paths: ${paths[*]} | CWD: $CWD"

# --- Core matching logic (always recursive) ---
for path in "${paths[@]}"; do
  # Expand tilde (~/) in the path
  expanded_path=${path/#\~/$HOME}
  
  # --- START: Applied Path Normalization ---
  # Normalize both paths by removing any trailing slashes for a reliable comparison
  normalized_cwd=${CWD%/}
  normalized_path=${expanded_path%/}

  # Check if the normalized CWD starts with the normalized configured path
  if [[ "$normalized_cwd" == "$normalized_path"* ]]; then
  # --- END: Applied Path Normalization ---
    log_debug "Result: MATCH"
    log_trim
    exit 0
  fi
done

log_debug "Result: NO MATCH"
log_trim
exit 1