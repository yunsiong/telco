#!/bin/sh

if [ -n "$TELCO_BUILD_OS" ]; then
  echo $TELCO_BUILD_OS
  exit 0
fi

echo $(uname -s | tr '[A-Z]' '[a-z]' | sed 's,^darwin$,macos,')
