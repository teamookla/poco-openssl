#!/bin/bash

# Array of Visual Studio versions in decreasing order of precedence
declare -a vs_versions=("2017" "2015" "2013" "2012" "2010" "2008")

# Function to check and set VSDIR for a specific version
check_version() {
  local version="$1"
  local options=("Community" "Professional" "Enterprise")

  vs_dir="C:/Program Files (x86)/Microsoft Visual Studio ${version}/VC/"
  if [ -e "${vs_dir}" ]; then
      VSDIR="${vs_dir}"
      return
  fi

  if [ "${version}" == "2017" ] && [ -z "${VSDIR}" ]; then
    for option in "${options[@]}"; do
      local vs_dir="C:/Program Files (x86)/Microsoft Visual Studio/${version}/${option}/VC/"
      if [ -e "${vs_dir}" ]; then
          VSDIR="${vs_dir}"
          return
      fi
    done
  fi
}

# Check if VSDIR is still not set
if [ -z "${VSDIR}" ]; then
  echo "Error: No Visual C++ environment found."
  echo "Please run this script from a Visual Studio Command Prompt"
  echo "or set the environment manually."
  exit 1
else
  echo "Found Visual C++ environment at ${VSDIR}"
fi
