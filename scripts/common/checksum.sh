#!/usr/bin/env bash

# Source: https://github.com/gruntwork-io/bash-commons/blob/master/modules/bash-commons/src/os.sh

source "$DOTFILES_DIR/scripts/common/log.sh"

# Validate that the given file has the given checksum of the given checksum type, where type is one of: md5 or sha256
function validate_checksum {
  local -r filepath="$1"
  local -r checksum="$2"
  local -r checksum_type="$3"

  case "$checksum_type" in
    sha256)
      log_info "Validating sha256 checksum of $filepath is $checksum"
      echo "$checksum $filepath" | sha256sum -c
      ;;
    md5)
      log_info "Validating md5 checksum of $filepath is $checksum"
      echo "$checksum $filepath" | md5sum -c
      ;;
    *)
      log_error "Unsupported checksum type: $checksum_type."
      exit 1
  esac
}

