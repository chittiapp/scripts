#!/bin/bash

# This script is used to set secrets on fly.io
setSecret() {

  read -p "Enter the app name: " appname

  if [ -z "$appname" ]; then
    echo "App name is required"
    exit 1
  fi

  params=()

  while true; do
    read -p "Enter the name: " name
    if [ -z "$name" ]; then
      break
    fi
    read -p "Enter the value: " value
    if [ -z "$value" ]; then
      break
    fi
    params+=("$name=$value")
  done

  if [ -z $params ]; then
    echo "At least one key-value pair is required"
    exit 1
  fi

  # echo "fly secrets set -a $appname ${params[@]}"
  echo "Processing..."
  fly secrets set -a $appname ${params[@]}
  echo "Secret added successfully"
  read -p "Do you want to deploy the secrets? (y/n): " response
  if [ "$response" == "y" ]; then
    fly secrets deploy -a $appname
  fi

}

# This script is used to delete secrets on fly.io

deleteSecret() {
  read -p "Enter the app name: " appname

  if [ -z "$appname" ]; then
    echo "App name is required"
    exit 1
  fi

  params=()

  while true; do
    read -p "Enter the name: " name
    if [ -z "$name" ]; then
      break
    fi
    params+=("$name")
  done
  if [ -z $params ]; then
    echo "At least one key-value pair is required"
    exit 1
  fi

  # echo "fly secrets unset -a $appname ${params[@]}"
  echo "Processing..."
  fly secrets unset -a $appname ${params[@]}
  echo "Secret deleted successfully"
  read -p "Do you want to deploy the secrets? (y/n): " response
  if [ "$response" == "y" ]; then
    fly secrets deploy -a $appname
  fi
}

# This script is used to show the list of secrets on fly.io
showSecret() {
  read -p "Enter the app name: " appname

  if [ -z "$appname" ]; then
    echo "App name is required"
    exit 1
  fi

  echo "Processing..."
  fly secrets list -a $appname
}

read -p "Select an option? (set/delete/show): " response

if [ "$response" == "set" ]; then
  setSecret
elif [ "$response" == "delete" ]; then
  deleteSecret
elif [ "$response" == "show" ]; then
  showSecret
fi
