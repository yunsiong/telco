#!/bin/sh

if [ -n "$TELCO_BUILD_VARIANT" ]; then
  echo $TELCO_BUILD_VARIANT
  exit 0
fi

case $(uname -s) in
  Linux)
    if ldd /bin/ls | grep -q musl; then
      echo musl
      exit 0
    fi
    ;;
esac

exit 0
