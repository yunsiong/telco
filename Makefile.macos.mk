include config.mk

build_arch := $(shell releng/detect-arch.sh)
ios_arm64eoabi_target := $(shell test -d /Applications/Xcode-11.7.app && echo build/telco-ios-arm64eoabi/usr/lib/pkgconfig/telco-core-1.0.pc)
test_args := $(addprefix -p=,$(tests))

HELP_FUN = \
	my (%help, @sections); \
	while(<>) { \
		if (/^([\w-]+)\s*:.*\#\#(?:@([\w-]+))?\s(.*)$$/) { \
			$$section = $$2 // 'options'; \
			push @sections, $$section unless exists $$help{$$section}; \
			push @{$$help{$$section}}, [$$1, $$3]; \
		} \
	} \
	$$target_color = "\033[32m"; \
	$$variable_color = "\033[36m"; \
	$$reset_color = "\033[0m"; \
	print "\n"; \
	print "\033[31mUsage:$${reset_color} make $${target_color}TARGET$${reset_color} [$${variable_color}VARIABLE$${reset_color}=value]\n\n"; \
	print "Where $${target_color}TARGET$${reset_color} specifies one or more of:\n"; \
	print "\n"; \
	for (@sections) { \
		print "  /* $$_ */\n"; $$sep = " " x (23 - length $$_->[0]); \
		printf("  $${target_color}%-23s$${reset_color}    %s\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
		print "\n"; \
	} \
	print "And optionally also $${variable_color}VARIABLE$${reset_color} values:\n"; \
	print "  $${variable_color}PYTHON$${reset_color}                     Absolute path of Python interpreter including version suffix\n"; \
	print "  $${variable_color}NODE$${reset_color}                       Absolute path of Node.js binary\n"; \
	print "\n"; \
	print "For example:\n"; \
	print "  \$$ make $${target_color}python-macos $${variable_color}PYTHON$${reset_color}=/usr/local/bin/python3.6\n"; \
	print "  \$$ make $${target_color}node-macos $${variable_color}NODE$${reset_color}=/usr/local/bin/node\n"; \
	print "\n";

help:
	@LC_ALL=C perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)


include releng/telco.mk

distclean: clean-submodules
	rm -rf build/
	rm -rf deps/

clean: clean-submodules
	rm -f build/*-clang*
	rm -f build/*-pkg-config
	rm -f build/*-stamp
	rm -f build/*.rc
	rm -f build/*.tar.bz2
	rm -f build/*.txt
	rm -f build/telco-version.h
	rm -rf build/telco-*-*
	rm -rf build/telco_thin-*-*
	rm -rf build/fs-*-*
	rm -rf build/ft-*-*
	rm -rf build/tmp-*-*
	rm -rf build/tmp_thin-*-*
	rm -rf build/fs-tmp-*-*
	rm -rf build/ft-tmp-*-*

clean-submodules:
	cd telco-gum && git clean -xfd
	cd telco-core && git clean -xfd
	cd telco-python && git clean -xfd
	cd telco-node && git clean -xfd
	cd telco-tools && git clean -xfd


define make-ios-env-rule
build/telco-env-ios-$1.rc: releng/setup-env.sh build/telco-version.h
	@if [ $1 != $$(build_machine) ]; then \
		cross=yes; \
	else \
		cross=no; \
	fi; \
	for machine in $$(build_machine) ios-$1; do \
		if [ ! -f build/telco-env-$$$$machine.rc ]; then \
			TELCO_HOST=$$$$machine \
			TELCO_CROSS=$$$$cross \
			TELCO_PREFIX="$$(abspath build/telco-ios-$1/usr)" \
			TELCO_ASAN=$$(TELCO_ASAN) \
			XCODE11="$$(XCODE11)" \
			./releng/setup-env.sh || exit 1; \
		fi \
	done
endef

$(eval $(call make-ios-env-rule,arm64))
$(eval $(call make-ios-env-rule,arm64e))
$(eval $(call make-ios-env-rule,arm64eoabi))
$(eval $(call make-ios-env-rule,x86_64-simulator))
$(eval $(call make-ios-env-rule,arm64-simulator))

build/telco-ios-%/usr/lib/pkgconfig/telco-gum-1.0.pc: build/telco-env-ios-%.rc build/.telco-gum-submodule-stamp
	. build/telco-env-ios-$*.rc; \
	builddir=build/tmp-ios-$*/telco-gum; \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,ios-$*) \
			--prefix /usr \
			$(telco_gum_flags) \
			telco-gum $$builddir || exit 1; \
	fi \
		&& $(MESON) compile -C $$builddir \
		&& DESTDIR="$(abspath build/telco-ios-$*)" $(MESON) install -C $$builddir
	@touch $@
build/telco-ios-%/usr/lib/pkgconfig/telco-core-1.0.pc: build/.telco-core-submodule-stamp build/telco-ios-%/usr/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco-env-ios-$*.rc; \
	builddir=build/tmp-ios-$*/telco-core; \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,ios-$*) \
			--prefix /usr \
			$(telco_core_flags) \
			-Dassets=installed \
			telco-core $$builddir || exit 1; \
	fi \
		&& $(MESON) compile -C $$builddir \
		&& DESTDIR="$(abspath build/telco-ios-$*)" $(MESON) install -C $$builddir
	@touch $@


gum-macos: build/telco-macos-$(build_arch)/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for macOS
gum-ios: build/telco-ios-arm64/usr/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for iOS
gum-watchos: build/telco_thin-watchos-arm64/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for watchOS
gum-tvos: build/telco_thin-tvos-arm64/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for tvOS
gum-android-x86: build/telco-android-x86/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Android/x86
gum-android-x86_64: build/telco-android-x86_64/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Android/x86-64
gum-android-arm: build/telco-android-arm/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Android/arm
gum-android-arm64: build/telco-android-arm64/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Android/arm64

define make-gum-rules
build/$1-%/lib/pkgconfig/telco-gum-1.0.pc: build/$1-env-%.rc build/.telco-gum-submodule-stamp
	. build/$1-env-$$*.rc; \
	builddir=build/$2-$$*/telco-gum; \
	if [ ! -f $$$$builddir/build.ninja ]; then \
		$$(call meson-setup-for-env,$1,$$*) \
			--prefix $$(TELCO)/build/$1-$$* \
			$$(telco_gum_flags) \
			telco-gum $$$$builddir || exit 1; \
	fi; \
	$$(MESON) install -C $$$$builddir || exit 1
	@touch -c $$@
endef
$(eval $(call make-gum-rules,telco,tmp))
$(eval $(call make-gum-rules,telco_thin,tmp_thin))

ifeq ($(build_arch), arm64)
check-gum-macos: build/telco-macos-arm64/lib/pkgconfig/telco-gum-1.0.pc build/telco-macos-arm64e/lib/pkgconfig/telco-gum-1.0.pc ##@gum Run tests for macOS
	build/tmp-macos-arm64/telco-gum/tests/gum-tests $(test_args)
	runner=build/tmp-macos-arm64e/telco-gum/tests/gum-tests; \
	if $$runner --help &>/dev/null; then \
		$$runner $(test_args); \
	fi
else
check-gum-macos: build/telco-macos-x86_64/lib/pkgconfig/telco-gum-1.0.pc
	build/tmp-macos-x86_64/telco-gum/tests/gum-tests $(test_args)
endif


core-macos: build/telco-macos-$(build_arch)/lib/pkgconfig/telco-core-1.0.pc ##@core Build for macOS
core-ios: build/telco-ios-arm64/usr/lib/pkgconfig/telco-core-1.0.pc ##@core Build for iOS
core-watchos: build/telco_thin-watchos-arm64/lib/pkgconfig/telco-core-1.0.pc ##@core Build for watchOS
core-tvos: build/telco_thin-tvos-arm64/lib/pkgconfig/telco-core-1.0.pc ##@core Build for tvOS
core-android-x86: build/telco-android-x86/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Android/x86
core-android-x86_64: build/telco-android-x86_64/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Android/x86-64
core-android-arm: build/telco-android-arm/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Android/arm
core-android-arm64: build/telco-android-arm64/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Android/arm64

build/tmp-macos-arm64/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco-macos-arm64/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco-env-macos-arm64.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,macos-arm64) \
			--prefix $(TELCO)/build/telco-macos-arm64 \
			$(telco_core_flags) \
			-Dhelper_modern=$(TELCO)/build/tmp-macos-arm64e/telco-core/src/telco-helper \
			-Dhelper_legacy=$(TELCO)/build/tmp-macos-arm64/telco-core/src/telco-helper \
			-Dagent_modern=$(TELCO)/build/tmp-macos-arm64e/telco-core/lib/agent/telco-agent.dylib \
			-Dagent_legacy=$(TELCO)/build/tmp-macos-arm64/telco-core/lib/agent/telco-agent.dylib \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-macos-arm64e/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco-macos-arm64e/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco-env-macos-arm64e.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,macos-arm64e) \
			--prefix $(TELCO)/build/telco-macos-arm64e \
			$(telco_core_flags) \
			-Dhelper_modern=$(TELCO)/build/tmp-macos-arm64e/telco-core/src/telco-helper \
			-Dhelper_legacy=$(TELCO)/build/tmp-macos-arm64/telco-core/src/telco-helper \
			-Dagent_modern=$(TELCO)/build/tmp-macos-arm64e/telco-core/lib/agent/telco-agent.dylib \
			-Dagent_legacy=$(TELCO)/build/tmp-macos-arm64/telco-core/lib/agent/telco-agent.dylib \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-macos-x86_64/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco-macos-x86_64/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco-env-macos-x86_64.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,macos-x86_64) \
			--prefix $(TELCO)/build/telco-macos-x86_64 \
			$(telco_core_flags) \
			-Dhelper_modern=$(TELCO)/build/tmp-macos-x86_64/telco-core/src/telco-helper \
			-Dagent_modern=$(TELCO)/build/tmp-macos-x86_64/telco-core/lib/agent/telco-agent.dylib \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-android-x86/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco-android-x86/lib/pkgconfig/telco-gum-1.0.pc
	if [ "$(TELCO_AGENT_EMULATED)" == "yes" ]; then \
		agent_emulated_legacy=$(TELCO)/build/tmp-android-arm/telco-core/lib/agent/telco-agent.so; \
	fi; \
	. build/telco-env-android-x86.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,android-x86) \
			--prefix $(TELCO)/build/telco-android-x86 \
			$(telco_core_flags) \
			-Dagent_emulated_legacy=$$agent_emulated_legacy \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-android-x86_64/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco-android-x86_64/lib/pkgconfig/telco-gum-1.0.pc
	if [ "$(TELCO_AGENT_EMULATED)" == "yes" ]; then \
		agent_emulated_modern=$(TELCO)/build/tmp-android-arm64/telco-core/lib/agent/telco-agent.so; \
		agent_emulated_legacy=$(TELCO)/build/tmp-android-arm/telco-core/lib/agent/telco-agent.so; \
	fi; \
	. build/telco-env-android-x86_64.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,android-x86_64) \
			--prefix $(TELCO)/build/telco-android-x86_64 \
			$(telco_core_flags) \
			-Dhelper_modern=$(TELCO)/build/tmp-android-x86_64/telco-core/src/telco-helper \
			-Dhelper_legacy=$(TELCO)/build/tmp-android-x86/telco-core/src/telco-helper \
			-Dagent_modern=$(TELCO)/build/tmp-android-x86_64/telco-core/lib/agent/telco-agent.so \
			-Dagent_legacy=$(TELCO)/build/tmp-android-x86/telco-core/lib/agent/telco-agent.so \
			-Dagent_emulated_modern=$$agent_emulated_modern \
			-Dagent_emulated_legacy=$$agent_emulated_legacy \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-android-arm/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco-android-arm/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco-env-android-arm.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,android-arm) \
			--prefix $(TELCO)/build/telco-android-arm \
			$(telco_core_flags) \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-android-arm64/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco-android-arm64/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco-env-android-arm64.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,android-arm64) \
			--prefix $(TELCO)/build/telco-android-arm64 \
			$(telco_core_flags) \
			-Dhelper_modern=$(TELCO)/build/tmp-android-arm64/telco-core/src/telco-helper \
			-Dhelper_legacy=$(TELCO)/build/tmp-android-arm/telco-core/src/telco-helper \
			-Dagent_modern=$(TELCO)/build/tmp-android-arm64/telco-core/lib/agent/telco-agent.so \
			-Dagent_legacy=$(TELCO)/build/tmp-android-arm/telco-core/lib/agent/telco-agent.so \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp_thin-%/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco_thin-%/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco_thin-env-$*.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup-thin,$*) \
			--prefix $(TELCO)/build/telco_thin-$* \
			$(telco_core_flags) \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@

ifeq ($(TELCO_AGENT_EMULATED), yes)
legacy_agent_emulated_dep := build/tmp-android-arm/telco-core/.telco-agent-stamp
modern_agent_emulated_dep := build/tmp-android-arm64/telco-core/.telco-agent-stamp
endif

build/telco-macos-x86_64/lib/pkgconfig/telco-core-1.0.pc: build/tmp-macos-x86_64/telco-core/.telco-helper-and-agent-stamp
	@rm -f build/tmp-macos-x86_64/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-macos-x86_64.rc && $(MESON) install -C build/tmp-macos-x86_64/telco-core
	@touch $@
build/telco-macos-arm64/lib/pkgconfig/telco-core-1.0.pc: build/tmp-macos-arm64/telco-core/.telco-helper-and-agent-stamp build/tmp-macos-arm64e/telco-core/.telco-helper-and-agent-stamp
	@rm -f build/tmp-macos-arm64/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-macos-arm64.rc && $(MESON) install -C build/tmp-macos-arm64/telco-core
	@touch $@
build/telco-macos-arm64e/lib/pkgconfig/telco-core-1.0.pc: build/tmp-macos-arm64/telco-core/.telco-helper-and-agent-stamp build/tmp-macos-arm64e/telco-core/.telco-helper-and-agent-stamp
	@rm -f build/tmp-macos-arm64e/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-macos-arm64e.rc && $(MESON) install -C build/tmp-macos-arm64e/telco-core
	@touch $@
build/telco-android-x86/lib/pkgconfig/telco-core-1.0.pc: build/tmp-android-x86/telco-core/.telco-helper-and-agent-stamp $(legacy_agent_emulated_dep)
	@rm -f build/tmp-android-x86/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-android-x86.rc && $(MESON) install -C build/tmp-android-x86/telco-core
	@touch $@
build/telco-android-x86_64/lib/pkgconfig/telco-core-1.0.pc: build/tmp-android-x86/telco-core/.telco-helper-and-agent-stamp build/tmp-android-x86_64/telco-core/.telco-helper-and-agent-stamp $(legacy_agent_emulated_dep) $(modern_agent_emulated_dep)
	@rm -f build/tmp-android-x86_64/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-android-x86_64.rc && $(MESON) install -C build/tmp-android-x86_64/telco-core
	@touch $@
build/telco-android-arm/lib/pkgconfig/telco-core-1.0.pc: build/tmp-android-arm/telco-core/.telco-helper-and-agent-stamp
	@rm -f build/tmp-android-arm/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-android-arm.rc && $(MESON) install -C build/tmp-android-arm/telco-core
	@touch $@
build/telco-android-arm64/lib/pkgconfig/telco-core-1.0.pc: build/tmp-android-arm/telco-core/.telco-helper-and-agent-stamp build/tmp-android-arm64/telco-core/.telco-helper-and-agent-stamp
	@rm -f build/tmp-android-arm64/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-android-arm64.rc && $(MESON) install -C build/tmp-android-arm64/telco-core
	@touch $@
build/telco_thin-%/lib/pkgconfig/telco-core-1.0.pc: build/tmp_thin-%/telco-core/.telco-ninja-stamp
	. build/telco_thin-env-$*.rc && $(MESON) install -C build/tmp_thin-$*/telco-core
	@touch $@

build/tmp-macos-%/telco-core/.telco-helper-and-agent-stamp: build/tmp-macos-%/telco-core/.telco-ninja-stamp
	. build/telco-env-macos-$*.rc && ninja -C build/tmp-macos-$*/telco-core src/telco-helper lib/agent/telco-agent.dylib
	@touch $@
build/tmp-macos-%/telco-core/.telco-agent-stamp: build/tmp-macos-%/telco-core/.telco-ninja-stamp
	. build/telco-env-macos-$*.rc && ninja -C build/tmp-macos-$*/telco-core lib/agent/telco-agent.dylib
	@touch $@
build/tmp-android-%/telco-core/.telco-helper-and-agent-stamp: build/tmp-android-%/telco-core/.telco-ninja-stamp
	. build/telco-env-android-$*.rc && ninja -C build/tmp-android-$*/telco-core src/telco-helper lib/agent/telco-agent.so
	@touch $@
build/tmp-android-%/telco-core/.telco-agent-stamp: build/tmp-android-%/telco-core/.telco-ninja-stamp
	. build/telco-env-android-$*.rc && ninja -C build/tmp-android-$*/telco-core lib/agent/telco-agent.so
	@touch $@

ifeq ($(build_arch), arm64)
check-core-macos: build/telco-macos-arm64/lib/pkgconfig/telco-core-1.0.pc build/telco-macos-arm64e/lib/pkgconfig/telco-core-1.0.pc ##@core Run tests for macOS
	build/tmp-macos-arm64/telco-core/tests/telco-tests $(test_args)
	runner=build/tmp-macos-arm64e/telco-core/tests/telco-tests; \
	if $$runner --help &>/dev/null; then \
		$$runner $(test_args); \
	fi
else
check-core-macos: build/telco-macos-x86_64/lib/pkgconfig/telco-core-1.0.pc
	build/tmp-macos-x86_64/telco-core/tests/telco-tests $(test_args)
endif


python-macos: build/tmp-macos-$(build_arch)/telco-$(PYTHON_NAME)/.telco-stamp ##@python Build Python bindings for macOS

define make-python-rule
build/$2-%/telco-$$(PYTHON_NAME)/.telco-stamp: build/.telco-python-submodule-stamp build/$1-%$(PYTHON_PREFIX)/lib/pkgconfig/telco-core-1.0.pc
	. build/$1-env-$$*.rc; \
	builddir=$$(@D); \
	if [ ! -f $$$$builddir/build.ninja ]; then \
		$$(call meson-setup-for-env,$1,$$*) \
			--prefix $$(TELCO)/build/$1-$$*$(PYTHON_PREFIX) \
			$$(TELCO_FLAGS_COMMON) \
			-Dpython=$$(PYTHON) \
			-Dpython_incdir=$$(PYTHON_INCDIR) \
			telco-python $$$$builddir || exit 1; \
	fi; \
	$$(MESON) install -C $$$$builddir || exit 1
	@touch $$@
endef
$(eval $(call make-python-rule,telco,tmp))
$(eval $(call make-python-rule,telco_thin,tmp_thin))

check-python-macos: python-macos ##@python Test Python bindings for macOS
	export PYTHONPATH="$(shell pwd)/build/telco-macos-$(build_arch)/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-python \
		&& $(PYTHON) -m unittest discover


node-macos: build/telco-macos-$(build_arch)/lib/node_modules/telco ##@node Build Node.js bindings for macOS

define make-node-rule
build/$1-%/lib/node_modules/telco: build/$1-%/lib/pkgconfig/telco-core-1.0.pc build/.telco-node-submodule-stamp
	@$$(NPM) --version &>/dev/null || (echo -e "\033[31mOops. It appears Node.js is not installed.\nCheck PATH or set NODE to the absolute path of your Node.js binary.\033[0m"; exit 1;)
	export PATH=$$(NODE_BIN_DIR):$$$$PATH TELCO=$$(TELCO) \
		&& cd telco-node \
		&& rm -rf telco-0.0.0.tgz build node_modules \
		&& $$(NPM) install \
		&& $$(NPM) pack \
		&& rm -rf ../$$@/ ../$$@.tmp/ \
		&& mkdir -p ../$$@.tmp/build/ \
		&& tar -C ../$$@.tmp/ --strip-components 1 -x -f telco-0.0.0.tgz \
		&& rm telco-0.0.0.tgz \
		&& mv build/Release/telco_binding.node ../$$@.tmp/build/ \
		&& rm -rf build \
		&& mv node_modules ../$$@.tmp/ \
		&& mv ../$$@.tmp ../$$@
endef
$(eval $(call make-node-rule,telco,tmp))
$(eval $(call make-node-rule,telco_thin,tmp_thin))

define run-node-tests
	export PATH=$3:$$PATH TELCO=$2 \
		&& cd telco-node \
		&& git clean -xfd \
		&& $5 install \
		&& $4 \
			--expose-gc \
			../build/$1/lib/node_modules/telco/node_modules/.bin/_mocha \
			-r ts-node/register \
			--timeout 60000 \
			test/*.ts
endef
check-node-macos: node-macos ##@node Test Node.js bindings for macOS
	$(call run-node-tests,telco-macos-$(build_arch),$(TELCO),$(NODE_BIN_DIR),$(NODE),$(NPM))


tools-macos: build/tmp-macos-$(build_arch)/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Build CLI tools for macOS

define make-tools-rule
build/$2-%/telco-tools-$$(PYTHON_NAME)/.telco-stamp: build/.telco-tools-submodule-stamp build/$2-%/telco-$$(PYTHON_NAME)/.telco-stamp
	. build/$1-env-$$*.rc; \
	builddir=$$(@D); \
	if [ ! -f $$$$builddir/build.ninja ]; then \
		$$(call meson-setup-for-env,$1,$$*) \
			--prefix $$(TELCO)/build/$1-$$* \
			-Dpython=$$(PYTHON) \
			telco-tools $$$$builddir || exit 1; \
	fi; \
	$$(MESON) install -C $$$$builddir || exit 1
	@touch $$@
endef
$(eval $(call make-tools-rule,telco,tmp))
$(eval $(call make-tools-rule,telco_thin,tmp_thin))

check-tools-macos: tools-macos ##@tools Test CLI tools for macOS
	export PYTHONPATH="$(shell pwd)/build/telco-macos-$(build_arch)/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-tools \
		&& $(PYTHON) -m unittest discover


.PHONY: \
	distclean clean clean-submodules git-submodules git-submodule-stamps \
	gum-macos \
		gum-ios gum-watchos gum-tvos \
		gum-android-x86 gum-android-x86_64 \
		gum-android-arm gum-android-arm64 \
		check-gum-macos \
		telco-gum-update-submodule-stamp \
	core-macos \
		core-ios core-watchos core-tvos \
		core-android-x86 core-android-x86_64 \
		core-android-arm core-android-arm64 \
		check-core-macos \
		telco-core-update-submodule-stamp \
	python-macos \
		python-macos-universal \
		check-python-macos \
		telco-python-update-submodule-stamp \
	node-macos \
		check-node-macos \
		telco-node-update-submodule-stamp \
	tools-macos \
		check-tools-macos \
		telco-tools-update-submodule-stamp
.SECONDARY:
