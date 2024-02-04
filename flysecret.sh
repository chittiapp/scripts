#!/bin/bash

# This script is used to get the all the applications on fly.io
getAppList() {
  applist=()
  apps=$(fly app list)
  applist+=($(echo "$apps" | awk '{print $1}'))
  unset applist[0]
  echo ${applist[@]}
}

# This script is used to set secrets on fly.io
setSecret() {

  appname=""
  appList=$(getAppList)
  PS3="------------- "$'\n'"Enter the number: "

  select app in ${appList[@]}; do
    echo "----------------------------------------"
    if [ -z "$app" ]; then
      echo "Invalid app name"
      exit 1
    fi
    appname=$app
    break
  done

  params=()
  echo "----------------------------------------"
  echo "Enter without any value to the next step"
  echo "----------------------------------------"

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
  read -p "Do you want to deploy the secrets? (y/n): " answer
  if [ "$answer" == "y" ]; then
    fly secrets deploy -a $appname
  fi

}

# This script is used to delete secrets on fly.io

deleteSecret() {
  appname=""
  appList=$(getAppList)
  PS3="------------- "$'\n'"Enter the number: "

  select app in ${appList[@]}; do
    echo "----------------------------------------"
    if [ -z "$app" ]; then
      echo "Invalid app name"
      exit 1
    fi
    appname=$app
    break
  done

  params=()
  echo "----------------------------------------"
  echo "Enter without any value to the next step"
  echo "----------------------------------------"

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
  read -p "Do you want to deploy the secrets? (y/n): " answer
  if [ "$answer" == "y" ]; then
    fly secrets deploy -a $appname
  fi
}

# This script is used to show the list of secrets on fly.io
showSecret() {
  appList=$(getAppList)
  PS3="------------- "$'\n'"Enter the number: "

  select app in ${appList[@]}; do
    if [ -z "$app" ]; then
      echo "Invalid app name"
      break
    fi
    echo "Processing..."
    fly secrets list -a $app
    break
  done

}

read -p "Select an option? (set/delete/show): " answer

if [ "$answer" == "set" ]; then
  setSecret
elif [ "$answer" == "delete" ]; then
  deleteSecret
elif [ "$answer" == "show" ]; then
  showSecret
fi
