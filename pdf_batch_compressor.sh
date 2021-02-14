#!/usr/bin/env bash
#
### FUNCTIONALITY ###
# Compress PDF files in the folder where this script resides via Ghostscript
# 1. Create a sub-folder, ./compressed, and put the resultant compressed ones in it
# 2. Compress files with any PDF extentions i.e., .pdf, .PDF, .pDf and so on
# 3. Optional compression parameter, namely, prepress, ebook (default) and screen - in the descending order of quality
# 4. Log output in the sub-folder with the compressed file names and any error message
# N.B. Make sure to make this script excutable via chmod +x or 755, after copying!

shopt -s nocaseglob
# Bash matches filenames in a case-insensitive fashion when performing filename expansion
# E.g., a.pdf, b.PDF and c.PdF all gets compressed

set -eo pipefail
# e: The script will exit on an error
# u: <ABORTED> Treat unset variables as an error when performing parameter expansion
#  This gives an error, "$1: unbound variable", when taking in input parameter of a command
# o pipefail: If any element of the pipeline fails, then the pipeline as a whole will fail
#  This is dangerous as pipelines only return a failure if the last command errors by default

# All variables in bash are global by default
# Global variables should be in ALL_CAPITAL_CASE with readonly designation 
# Variable substitution within a sting should be "${variable}", NOT just $variable
# Use POSIX-compliant [[ ]], i.e., ksh, zsh, etc., rather than []
# REFERENCE: https://google.github.io/styleguide/shellguide.html

show_no_setting_msg() {
  echo "No compression setting specified!"
}

show_setting_not_recognised_msg() {
  echo "Setting not recognised!"
}

show_ghostscript_not_installed_msg() {
  echo "Ghostcript not installed!" 
}

show_help_msg() {
  local help_msg

  help_msg="
    NAME
      Compress all the PDF files in the same folder as this script resides via
      Ghostscript and put them into a newly created \"compressed\" sub-folder
    SYNOPSIS
      pdf_batch_compressor.sh [OPTION]
    DESCRIPTION
      -s, --setting=SETTING
        override default ebook; prepress, ebook or screen (in the descending order of quality)
      -h, --help
        display this help and exit
    "
  
  # echo $help_msg (without quotes) does NOT retain the new lines!
  # After expanding, the enclosing double quotes stops
  #  '(field) splitting (via $IFS) and globbing(i.e., pathname expansion))'
  echo "${help_msg}"
}

#######################################
# Remove a number of characters from a string from the beginning
# Arguments:
#   A string
#   An integer
# Returns:
#   A trucated string
# Example:
#   truncate_char_from_beginning abcde 2 => cde
#######################################
truncate_char_from_beginning() {
  # shellcheck disable=SC2005
  echo "$(echo "$1" | cut -c $(($2+1))-)"
}

#######################################
# Make sure legit input parameters
# Arguments:
#   An optional setting parameter
# Returns:
#   None. Call Ghostscript function
#######################################
check_inputs() {
  #`declare` stipulates a variable as "local" by default. `-r` makes it readonly
  declare -r SHORT_SETTING_SWITCH=-s=
  declare -r LONG_SETTING_SWITCH=--setting=

  local compression_setting
  local ghostscript_dir_and_exec

  local short_setting_switch_len
  local long_setting_switch_len

  # `-n` truncates the trailling new-line character
  short_setting_switch_len=$(echo -n "$SHORT_SETTING_SWITCH" | wc -m)
  long_setting_switch_len=$(echo -n "$LONG_SETTING_SWITCH" | wc -m)

  while [[ "$1" != "" ]]; do
    case $1 in
      -h | --help)
        show_help_msg
        exit 1
        ;;
      *)
        if [[ $(echo "$1" | head -c "$short_setting_switch_len") = "$SHORT_SETTING_SWITCH" ]]; then
          compression_setting=$(truncate_char_from_beginning "$1" "$short_setting_switch_len")
        elif [[ $(echo "$1" | head -c "$long_setting_switch_len") = "$LONG_SETTING_SWITCH" ]]; then
          compression_setting=$(truncate_char_from_beginning "$1" "$long_setting_switch_len")
        else
          # Unrecognisable input parameter
          show_help_msg
          exit 1
        fi
        ;;
    esac
    shift
  done

  if [[ -z "${compression_setting}" ]]; then
  # True if not set i.e., the length of the tested is zero
    compression_setting=ebook
  fi

  ghostscript_dir_and_exec=$(command -v gs)

  if [[ -z "${ghostscript_dir_and_exec}" ]]; then
    show_ghostscript_not_installed_msg
    exit 1
  else
    case "${compression_setting}" in
      prepress | ebook | screen)
        ;;
      *)
        show_setting_not_recognised_msg
        exit 1
        ;;
    esac
  fi

  compress_pdf "${compression_setting}" "${ghostscript_dir_and_exec}"
}

#######################################
# Called from the bottom of this script. Call Ghostscript command
# Arguments:
#   Compression setting
#   Ghostscript binary file location in an absolute path
# Returns:
#   None
#######################################
compress_pdf() {
  #`declare` stipulates a variable as "local" by default. `-r` makes it readonly
  declare -r SUBDIR_NAME=compressed

  local compression_setting
  local ghostscript_dir_and_exec
  local subdir_path
  local log_filename_in_full_path
  local filename_only

  # Output is without the trailing directory separator, so add "/" at the end
  dir_path=$(pwd)/

  compression_setting=$1
  ghostscript_dir_and_exec=$2

  subdir_path="${dir_path}/${SUBDIR_NAME}/"

  # `-f` silently ignores non-existent file(s) to avoid "rm: cannot remove '': No such file or directory"
  rm -rf "${subdir_path}"
  mkdir "${subdir_path}"

  # Use this script name as part of log file name
  log_filename_in_full_path="${subdir_path}""$(basename "$0")".log

  for filename_in_full_path in "${dir_path}"/*.pdf; do
    filename_only=$(basename "${filename_in_full_path}")

    echo "${filename_only}" >> "${log_filename_in_full_path}"

    # (command) runs in a subshell
    # `&>> file` appends stderr and stdout to file
    # source: https://ops.tips/gists/redirect-all-outputs-of-a-bash-script-to-a-file/
    (
      "${ghostscript_dir_and_exec}" -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
        -dPDFSETTINGS=/"${compression_setting}" -dNOPAUSE -dQUIET -dBATCH \
        -sOutputFile="${subdir_path}${filename_only}" "${filename_in_full_path}"
    ) &>> "${log_filename_in_full_path}"
  done
}

# https://nenadsprojects.wordpress.com/2012/12/27/bash_source/ 
#
#                   Sourced     Not-Sourced
# ${BASH_SOURCE[0]} this.sh     this.sh
# ${BASH_SOURCE[1]} sourcing.sh
# $0                sourcing.sh this.sh
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  # Not sourced from anywhere else
  check_inputs "$@"
fi