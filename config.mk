DESTDIR ?=
PREFIX ?= /usr

TELCO := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Features ordered by binary footprint, from largest to smallest
TELCO_V8 ?= auto
TELCO_CONNECTIVITY ?= enabled
TELCO_DATABASE ?= enabled
TELCO_JAVA_BRIDGE ?= auto
TELCO_OBJC_BRIDGE ?= auto
TELCO_SWIFT_BRIDGE ?= auto

TELCO_AGENT_EMULATED ?= yes

# Include jailbreak-specific integrations
TELCO_JAILBREAK ?= auto

TELCO_ASAN ?= no

ifeq ($(TELCO_ASAN), yes)
TELCO_FLAGS_COMMON := -Doptimization=1 -Db_sanitize=address
TELCO_FLAGS_BOTTLE := -Doptimization=1 -Db_sanitize=address
else
TELCO_FLAGS_COMMON := -Doptimization=s -Db_ndebug=true --strip
TELCO_FLAGS_BOTTLE := -Doptimization=s -Db_ndebug=true --strip
endif

TELCO_MAPPER := -Dmapper=auto

XCODE11 ?= /Applications/Xcode-11.7.app

PYTHON ?= $(shell which python3)
PYTHON_VERSION := $(shell $(PYTHON) -c 'import sys; v = sys.version_info; print("{0}.{1}".format(v[0], v[1]))')
PYTHON_NAME ?= python$(PYTHON_VERSION)
PYTHON_PREFIX ?=
PYTHON_INCDIR ?=

PYTHON3 ?= python3

NODE ?= $(shell which node)
NODE_BIN_DIR := $(shell dirname $(NODE) 2>/dev/null)
NPM ?= $(NODE_BIN_DIR)/npm

MESON ?= $(PYTHON3) $(TELCO)/releng/meson/meson.py

tests ?=
