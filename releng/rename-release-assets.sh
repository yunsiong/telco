#!/bin/bash

if [ -z "$TELCO_VERSION" ]; then
  echo "TELCO_VERSION must be set" > /dev/stderr
  exit 1
fi

set -e

cd build/release-assets
for name in *; do
  if echo $name | grep -q $TELCO_VERSION; then
    continue
  fi
  case $name in
    telco-*-devkit-*)
      new_name=$(echo $name | sed -e "s,devkit-,devkit-$TELCO_VERSION-,")
      ;;
    telco-server-*|telco-portal-*|telco-inject-*|telco-gadget-*|telco-swift-*|telco-clr-*|telco-qml-*|gum-graft-*)
      new_name=$(echo $name | sed -E -e "s,^(telco|gum)-([^-]+),\\1-\\2-$TELCO_VERSION,")
      ;;
    *)
      new_name=""
      ;;
  esac
  if [ -n "$new_name" ]; then
    mv -v $name $new_name
  fi
done
