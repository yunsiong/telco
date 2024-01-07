TELCO_VERSION := $(shell git describe --tags --always --long | sed 's,-,.,g' | cut -f1-3 -d'.')

include releng/system.mk

FOR_HOST ?= $(build_machine)
SHELL := $(shell which bash)

telco_gum_flags := \
	--default-library static \
	$(TELCO_FLAGS_COMMON) \
	-Djailbreak=$(TELCO_JAILBREAK) \
	-Dgumpp=enabled \
	-Dgumjs=enabled \
	-Dv8=$(TELCO_V8) \
	-Ddatabase=$(TELCO_DATABASE) \
	-Dtelco_objc_bridge=$(TELCO_OBJC_BRIDGE) \
	-Dtelco_swift_bridge=$(TELCO_SWIFT_BRIDGE) \
	-Dtelco_java_bridge=$(TELCO_JAVA_BRIDGE) \
	-Dtests=enabled \
	$(NULL)
telco_core_flags := \
	--default-library static \
	$(TELCO_FLAGS_COMMON) \
	-Dconnectivity=$(TELCO_CONNECTIVITY) \
	$(TELCO_MAPPER)

telco_tools = \
	telco \
	telco-ls-devices \
	telco-ps \
	telco-kill \
	telco-ls \
	telco-rm \
	telco-pull \
	telco-push \
	telco-discover \
	telco-trace \
	telco-join \
	telco-create \
	telco-compile \
	telco-apk \
	$(NULL)

build/telco-env-%.rc: releng/setup-env.sh build/telco-version.h
	@if [ $* != $(build_machine) ]; then \
		cross=yes; \
	else \
		cross=no; \
	fi; \
	for machine in $(build_machine) $*; do \
		if [ ! -f build/telco-env-$$machine.rc ]; then \
			TELCO_HOST=$$machine \
			TELCO_CROSS=$$cross \
			TELCO_ASAN=$(TELCO_ASAN) \
			XCODE11="$(XCODE11)" \
			./releng/setup-env.sh || exit 1; \
		fi \
	done
build/telco_thin-env-%.rc: releng/setup-env.sh build/telco-version.h
	@if [ $* != $(build_machine) ]; then \
		cross=yes; \
	else \
		cross=no; \
	fi; \
	for machine in $(build_machine) $*; do \
		if [ ! -f build/telco_thin-env-$$machine.rc ]; then \
			TELCO_HOST=$$machine \
			TELCO_CROSS=$$cross \
			TELCO_ASAN=$(TELCO_ASAN) \
			TELCO_ENV_NAME=telco_thin \
			XCODE11="$(XCODE11)" \
			./releng/setup-env.sh || exit 1; \
		fi \
	done
	@cd $(TELCO)/build/; \
	[ ! -e telco-env-$*.rc ] && ln -s telco_thin-env-$*.rc telco-env-$*.rc; \
	[ ! -d telco-$* ] && ln -s telco_thin-$* telco-$*; \
	[ ! -d sdk-$* ] && ln -s telco_thin-sdk-$* sdk-$*; \
	[ ! -d toolchain-$* ] && ln -s telco_thin-toolchain-$* toolchain-$*; \
	true
build/telco_gir-env-%.rc: releng/setup-env.sh build/telco-version.h
	@if [ $* != $(build_machine) ]; then \
		cross=yes; \
	else \
		cross=no; \
	fi; \
	for machine in $(build_machine) $*; do \
		if [ ! -f build/telco_gir-env-$$machine.rc ]; then \
			TELCO_HOST=$$machine \
			TELCO_CROSS=$$cross \
			TELCO_ASAN=$(TELCO_ASAN) \
			TELCO_ENV_NAME=telco_gir \
			XCODE11="$(XCODE11)" \
			./releng/setup-env.sh || exit 1; \
		fi \
	done
	@cd $(TELCO)/build/; \
	[ ! -e telco-env-$*.rc ] && ln -s telco_gir-env-$*.rc telco-env-$*.rc; \
	[ ! -d telco-$* ] && ln -s telco_gir-$* telco-$*; \
	[ ! -d sdk-$* ] && ln -s telco_gir-sdk-$* sdk-$*; \
	[ ! -d toolchain-$* ] && ln -s telco_gir-toolchain-$* toolchain-$*; \
	true

build/telco-version.h: releng/generate-version-header.py .git/HEAD
	@$(PYTHON3) releng/generate-version-header.py > $@.tmp
	@mv $@.tmp $@

define meson-setup
	$(call meson-setup-for-env,telco,$1)
endef

define meson-setup-thin
	$(call meson-setup-for-env,telco_thin,$1)
endef

define meson-setup-for-env
	meson_args="--native-file build/$1-$(build_machine).txt"; \
	if [ $2 != $(build_machine) ]; then \
		meson_args="$$meson_args --cross-file build/$1-$2.txt"; \
	fi; \
	$(MESON) setup $$meson_args
endef
