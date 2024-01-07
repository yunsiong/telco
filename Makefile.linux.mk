include config.mk

build_arch := $(shell releng/detect-arch.sh)
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
		print "  /* $$_ */\n"; $$sep = " " x (30 - length $$_->[0]); \
		printf("  $${target_color}%-30s$${reset_color}    %s\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
		print "\n"; \
	} \
	print "And optionally also $${variable_color}VARIABLE$${reset_color} values:\n"; \
	print "  $${variable_color}PYTHON$${reset_color}                            Absolute path of Python interpreter including version suffix\n"; \
	print "  $${variable_color}NODE$${reset_color}                              Absolute path of Node.js binary\n"; \
	print "\n"; \
	print "For example:\n"; \
	print "  \$$ make $${target_color}python-linux-x86_64 $${variable_color}PYTHON$${reset_color}=/opt/python36-64/bin/python3.6\n"; \
	print "  \$$ make $${target_color}node-linux-x86 $${variable_color}NODE$${reset_color}=/opt/node-linux-x86/bin/node\n"; \
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
	rm -rf build/telco_gir-*-*
	rm -rf build/fs-*-*
	rm -rf build/ft-*-*
	rm -rf build/tmp-*-*
	rm -rf build/tmp_thin-*-*
	rm -rf build/tmp_gir-*-*
	rm -rf build/fs-tmp-*-*
	rm -rf build/ft-tmp-*-*

clean-submodules:
	cd telco-gum && git clean -xfd
	cd telco-core && git clean -xfd
	cd telco-python && git clean -xfd
	cd telco-node && git clean -xfd
	cd telco-tools && git clean -xfd


gum-linux-x86: build/telco-linux-x86/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/x86
gum-linux-x86_64: build/telco-linux-x86_64/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/x86-64
gum-linux-x86-thin: build/telco_thin-linux-x86/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/x86 without cross-arch support
gum-linux-x86_64-thin: build/telco_thin-linux-x86_64/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/x86-64 without cross-arch support
gum-linux-x86_64-gir: build/telco_gir-linux-x86_64/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/x86-64 with shared GLib and GIR
gum-linux-arm: build/telco_thin-linux-arm/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/arm
gum-linux-armbe8: build/telco_thin-linux-armbe8/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/armbe8
gum-linux-armhf: build/telco_thin-linux-armhf/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/armhf
gum-linux-arm64: build/telco_thin-linux-arm64/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/arm64
gum-linux-mips: build/telco_thin-linux-mips/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/mips
gum-linux-mipsel: build/telco_thin-linux-mipsel/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/mipsel
gum-linux-mips64: build/telco_thin-linux-mips64/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/mips64
gum-linux-mips64el: build/telco_thin-linux-mips64el/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Linux/MIP64Sel
gum-android-x86: build/telco-android-x86/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Android/x86
gum-android-x86_64: build/telco-android-x86_64/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Android/x86-64
gum-android-arm: build/telco-android-arm/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Android/arm
gum-android-arm64: build/telco-android-arm64/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Android/arm64
gum-qnx-arm: build/telco_thin-qnx-arm/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for QNX/arm
gum-qnx-armeabi: build/telco_thin-qnx-armeabi/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for QNX/armeabi
gum-windows-x86: build/telco-windows-x86-mingw32/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Windows/x86
gum-windows-x86_64: build/telco-windows-x86_64-mingw32/lib/pkgconfig/telco-gum-1.0.pc ##@gum Build for Windows/x86_64


define make-gum-rules
build/$1-%/lib/pkgconfig/telco-gum-1.0.pc: build/$1-env-%.rc build/.telco-gum-submodule-stamp
	. build/$1-env-$$*.rc; \
	builddir=build/$2-$$*/telco-gum; \
	if [ ! -f $$$$builddir/build.ninja ]; then \
		$$(call meson-setup-for-env,$1,$$*) \
			--prefix $$(TELCO)/build/$1-$$* \
			--libdir $$(TELCO)/build/$1-$$*/lib \
			$$(telco_gum_flags) \
			telco-gum $$$$builddir || exit 1; \
	fi; \
	$$(MESON) install -C $$$$builddir || exit 1
	@touch -c $$@
endef
$(eval $(call make-gum-rules,telco,tmp))
$(eval $(call make-gum-rules,telco_thin,tmp_thin))
$(eval $(call make-gum-rules,telco_gir,tmp_gir))

check-gum-linux-x86: gum-linux-x86 ##@gum Run tests for Linux/x86
	build/tmp-linux-x86/telco-gum/tests/gum-tests $(test_args)
check-gum-linux-x86_64: gum-linux-x86_64 ##@gum Run tests for Linux/x86-64
	build/tmp-linux-x86_64/telco-gum/tests/gum-tests $(test_args)
check-gum-linux-x86-thin: gum-linux-x86-thin ##@gum Run tests for Linux/x86 without cross-arch support
	build/tmp_thin-linux-x86/telco-gum/tests/gum-tests $(test_args)
check-gum-linux-x86_64-thin: gum-linux-x86_64-thin ##@gum Run tests for Linux/x86-64 without cross-arch support
	build/tmp_thin-linux-x86_64/telco-gum/tests/gum-tests $(test_args)
check-gum-linux-armhf: gum-linux-armhf ##@gum Run tests for Linux/armhf
	build/tmp_thin-linux-armhf/telco-gum/tests/gum-tests $(test_args)
check-gum-linux-arm64: gum-linux-arm64 ##@gum Run tests for Linux/arm64
	build/tmp_thin-linux-arm64/telco-gum/tests/gum-tests $(test_args)


core-linux-x86: build/telco-linux-x86/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/x86
core-linux-x86_64: build/telco-linux-x86_64/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/x86-64
core-linux-x86-thin: build/telco_thin-linux-x86/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/x86 without cross-arch support
core-linux-x86_64-thin: build/telco_thin-linux-x86_64/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/x86-64 without cross-arch support
core-linux-arm: build/telco_thin-linux-arm/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/arm
core-linux-armbe8: build/telco_thin-linux-armbe8/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/armbe8
core-linux-armhf: build/telco_thin-linux-armhf/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/armhf
core-linux-arm64: build/telco_thin-linux-arm64/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/arm64
core-linux-mips: build/telco_thin-linux-mips/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/mips
core-linux-mipsel: build/telco_thin-linux-mipsel/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/mipsel
core-linux-mips64: build/telco_thin-linux-mips64/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/mips64
core-linux-mips64el: build/telco_thin-linux-mips64el/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Linux/mips64el
core-android-x86: build/telco-android-x86/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Android/x86
core-android-x86_64: build/telco-android-x86_64/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Android/x86-64
core-android-arm: build/telco-android-arm/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Android/arm
core-android-arm64: build/telco-android-arm64/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Android/arm64
core-qnx-arm: build/telco_thin-qnx-arm/lib/pkgconfig/telco-core-1.0.pc ##@core Build for QNX/arm
core-qnx-armeabi: build/telco_thin-qnx-armeabi/lib/pkgconfig/telco-core-1.0.pc ##@core Build for QNX/armeabi
core-windows-x86: build/telco-windows-x86-mingw32/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Windows/x86
core-windows-x86_64: build/telco-windows-x86_64-mingw32/lib/pkgconfig/telco-core-1.0.pc ##@core Build for Windows/x86_64

build/tmp-linux-x86/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco-linux-x86/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco-env-linux-x86.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,linux-x86) \
			--prefix $(TELCO)/build/telco-linux-x86 \
			--libdir $(TELCO)/build/telco-linux-x86/lib \
			$(telco_core_flags) \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-linux-x86_64/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco-linux-x86_64/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco-env-linux-x86_64.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,linux-x86_64) \
			--prefix $(TELCO)/build/telco-linux-x86_64 \
			--libdir $(TELCO)/build/telco-linux-x86_64/lib \
			$(telco_core_flags) \
			-Dhelper_modern=$(TELCO)/build/tmp-linux-x86_64/telco-core/src/telco-helper \
			-Dhelper_legacy=$(TELCO)/build/tmp-linux-x86/telco-core/src/telco-helper \
			-Dagent_modern=$(TELCO)/build/tmp-linux-x86_64/telco-core/lib/agent/telco-agent.so \
			-Dagent_legacy=$(TELCO)/build/tmp-linux-x86/telco-core/lib/agent/telco-agent.so \
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
			--libdir $(TELCO)/build/telco-android-x86/lib \
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
			--libdir $(TELCO)/build/telco-android-x86_64/lib \
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
			--libdir $(TELCO)/build/telco-android-arm/lib \
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
			--libdir $(TELCO)/build/telco-android-arm64/lib \
			$(telco_core_flags) \
			-Dhelper_modern=$(TELCO)/build/tmp-android-arm64/telco-core/src/telco-helper \
			-Dhelper_legacy=$(TELCO)/build/tmp-android-arm/telco-core/src/telco-helper \
			-Dagent_modern=$(TELCO)/build/tmp-android-arm64/telco-core/lib/agent/telco-agent.so \
			-Dagent_legacy=$(TELCO)/build/tmp-android-arm/telco-core/lib/agent/telco-agent.so \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-windows-x86-mingw32/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco-windows-x86-mingw32/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco-env-windows-x86-mingw32.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,windows-x86-mingw32) \
			--prefix $(TELCO)/build/telco-windows-x86-mingw32 \
			--libdir $(TELCO)/build/telco-windows-x86-mingw32/lib \
			$(telco_core_flags) \
			-Dagent_dbghelp_prefix=$(TELCO)/telco-gum/ext/dbghelp \
			-Dagent_symsrv_prefix=$(TELCO)/telco-gum/ext/symsrv \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-windows-x86_64-mingw32/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco-windows-x86_64-mingw32/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco-env-windows-x86_64-mingw32.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,windows-x86_64-mingw32) \
			--prefix $(TELCO)/build/telco-windows-x86_64-mingw32 \
			--libdir $(TELCO)/build/telco-windows-x86_64-mingw32/lib \
			$(telco_core_flags) \
			-Dhelper_modern=$(TELCO)/build/tmp-windows-x86_64-mingw32/telco-core/src/telco-helper.exe \
			-Dhelper_legacy=$(TELCO)/build/tmp-windows-x86-mingw32/telco-core/src/telco-helper.exe \
			-Dagent_modern=$(TELCO)/build/tmp-windows-x86_64-mingw32/telco-core/lib/agent/telco-agent.dll \
			-Dagent_legacy=$(TELCO)/build/tmp-windows-x86-mingw32/telco-core/lib/agent/telco-agent.dll \
			-Dagent_dbghelp_prefix=$(TELCO)/telco-gum/ext/dbghelp \
			-Dagent_symsrv_prefix=$(TELCO)/telco-gum/ext/symsrv \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp_thin-%/telco-core/.telco-ninja-stamp: build/.telco-core-submodule-stamp build/telco_thin-%/lib/pkgconfig/telco-gum-1.0.pc
	. build/telco_thin-env-$*.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup-thin,$*) \
			--prefix $(TELCO)/build/telco_thin-$* \
			--libdir $(TELCO)/build/telco_thin-$*/lib \
			$(telco_core_flags) \
			telco-core $$builddir || exit 1; \
	fi
	@touch $@

ifeq ($(TELCO_AGENT_EMULATED), yes)
legacy_agent_emulated_dep := build/tmp-android-arm/telco-core/.telco-agent-stamp
modern_agent_emulated_dep := build/tmp-android-arm64/telco-core/.telco-agent-stamp
endif

build/telco-linux-x86/lib/pkgconfig/telco-core-1.0.pc: build/tmp-linux-x86/telco-core/.telco-helper-and-agent-stamp
	@rm -f build/tmp-linux-x86/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-linux-x86.rc && $(MESON) install -C build/tmp-linux-x86/telco-core
	@touch $@
build/telco-linux-x86_64/lib/pkgconfig/telco-core-1.0.pc: build/tmp-linux-x86/telco-core/.telco-helper-and-agent-stamp build/tmp-linux-x86_64/telco-core/.telco-helper-and-agent-stamp
	@rm -f build/tmp-linux-x86_64/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-linux-x86_64.rc && $(MESON) install -C build/tmp-linux-x86_64/telco-core
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
build/telco-android-armbe8/lib/pkgconfig/telco-core-1.0.pc: build/tmp-android-armbe8/telco-core/.telco-helper-and-agent-stamp
	@rm -f build/tmp-android-armbe8/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-android-armbe8.rc && $(MESON) install -C build/tmp-android-armbe8/telco-core
	@touch $@
build/telco-android-arm64/lib/pkgconfig/telco-core-1.0.pc: build/tmp-android-arm/telco-core/.telco-helper-and-agent-stamp build/tmp-android-arm64/telco-core/.telco-helper-and-agent-stamp
	@rm -f build/tmp-android-arm64/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-android-arm64.rc && $(MESON) install -C build/tmp-android-arm64/telco-core
	@touch $@
build/telco-windows-x86-mingw32/lib/pkgconfig/telco-core-1.0.pc: build/tmp-windows-x86-mingw32/telco-core/.telco-helper-and-agent-stamp
	@rm -f build/tmp-windows-x86-mingw32/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-windows-x86-mingw32.rc && $(MESON) install -C build/tmp-windows-x86-mingw32/telco-core
	@touch $@
build/telco-windows-x86_64-mingw32/lib/pkgconfig/telco-core-1.0.pc: build/tmp-windows-x86-mingw32/telco-core/.telco-helper-and-agent-stamp build/tmp-windows-x86_64-mingw32/telco-core/.telco-helper-and-agent-stamp
	@rm -f build/tmp-windows-x86_64-mingw32/telco-core/src/telco-data-{helper,agent}*
	. build/telco-env-windows-x86_64-mingw32.rc && $(MESON) install -C build/tmp-windows-x86_64-mingw32/telco-core
	@touch $@
build/telco_thin-%/lib/pkgconfig/telco-core-1.0.pc: build/tmp_thin-%/telco-core/.telco-ninja-stamp
	. build/telco_thin-env-$*.rc && $(MESON) install -C build/tmp_thin-$*/telco-core
	@touch $@

build/tmp-windows-%/telco-core/.telco-helper-and-agent-stamp: build/tmp-windows-%/telco-core/.telco-ninja-stamp
	. build/telco-env-windows-$*.rc && ninja -C build/tmp-windows-$*/telco-core src/telco-helper.exe lib/agent/telco-agent.dll
	@touch $@
build/tmp-%/telco-core/.telco-helper-and-agent-stamp: build/tmp-%/telco-core/.telco-ninja-stamp
	. build/telco-env-$*.rc && ninja -C build/tmp-$*/telco-core src/telco-helper lib/agent/telco-agent.so
	@touch $@
build/tmp-%/telco-core/.telco-agent-stamp: build/tmp-%/telco-core/.telco-ninja-stamp
	. build/telco-env-$*.rc && ninja -C build/tmp-$*/telco-core lib/agent/telco-agent.so
	@touch $@

check-core-linux-x86: core-linux-x86 ##@core Run tests for Linux/x86
	build/tmp-linux-x86/telco-core/tests/telco-tests $(test_args)
check-core-linux-x86_64: core-linux-x86_64 ##@core Run tests for Linux/x86-64
	build/tmp-linux-x86_64/telco-core/tests/telco-tests $(test_args)
check-core-linux-x86-thin: core-linux-x86-thin ##@core Run tests for Linux/x86 without cross-arch support
	build/tmp_thin-linux-x86/telco-core/tests/telco-tests $(test_args)
check-core-linux-x86_64-thin: core-linux-x86_64-thin ##@core Run tests for Linux/x86-64 without cross-arch support
	build/tmp_thin-linux-x86_64/telco-core/tests/telco-tests $(test_args)
check-core-linux-armhf: core-linux-armhf ##@core Run tests for Linux/armhf
	build/tmp_thin-linux-armhf/telco-core/tests/telco-tests $(test_args)
check-core-linux-arm64: core-linux-arm64 ##@core Run tests for Linux/arm64
	build/tmp_thin-linux-arm64/telco-core/tests/telco-tests $(test_args)


python-linux-x86: build/tmp-linux-x86/telco-$(PYTHON_NAME)/.telco-stamp ##@python Build Python bindings for Linux/x86
python-linux-x86_64: build/tmp-linux-x86_64/telco-$(PYTHON_NAME)/.telco-stamp ##@python Build Python bindings for Linux/x86-64
python-linux-x86-thin: build/tmp_thin-linux-x86/telco-$(PYTHON_NAME)/.telco-stamp ##@python Build Python bindings for Linux/x86 without cross-arch support
python-linux-x86_64-thin: build/tmp_thin-linux-x86_64/telco-$(PYTHON_NAME)/.telco-stamp ##@python Build Python bindings for Linux/x86-64 without cross-arch support
python-linux-armhf: build/tmp_thin-linux-armhf/telco-$(PYTHON_NAME)/.telco-stamp ##@python Build Python bindings for Linux/armhf
python-linux-arm64: build/tmp_thin-linux-arm64/telco-$(PYTHON_NAME)/.telco-stamp ##@python Build Python bindings for Linux/arm64

define make-python-rule
build/$2-%/telco-$$(PYTHON_NAME)/.telco-stamp: build/.telco-python-submodule-stamp build/$1-%/lib/pkgconfig/telco-core-1.0.pc
	. build/$1-env-$$*.rc; \
	builddir=$$(@D); \
	if [ ! -f $$$$builddir/build.ninja ]; then \
		$$(call meson-setup-for-env,$1,$$*) \
			--prefix $$(TELCO)/build/$1-$$* \
			--libdir $$(TELCO)/build/$1-$$*/lib \
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

check-python-linux-x86: build/tmp-linux-x86/telco-$(PYTHON_NAME)/.telco-stamp ##@python Test Python bindings for Linux/x86
	export PYTHONPATH="$(shell pwd)/build/telco-linux-x86/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-python \
		&& ${PYTHON} -m unittest discover
check-python-linux-x86_64: build/tmp-linux-x86_64/telco-$(PYTHON_NAME)/.telco-stamp ##@python Test Python bindings for Linux/x86-64
	export PYTHONPATH="$(shell pwd)/build/telco-linux-x86_64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-python \
		&& ${PYTHON} -m unittest discover
check-python-linux-x86-thin: build/tmp_thin-linux-x86/telco-$(PYTHON_NAME)/.telco-stamp ##@python Test Python bindings for Linux/x86 without cross-arch support
	export PYTHONPATH="$(shell pwd)/build/telco_thin-linux-x86/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-python \
		&& ${PYTHON} -m unittest discover
check-python-linux-x86_64-thin: build/tmp_thin-linux-x86_64/telco-$(PYTHON_NAME)/.telco-stamp ##@python Test Python bindings for Linux/x86-64 without cross-arch support
	export PYTHONPATH="$(shell pwd)/build/telco_thin-linux-x86_64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-python \
		&& ${PYTHON} -m unittest discover
check-python-linux-armhf: build/tmp_thin-linux-armhf/telco-$(PYTHON_NAME)/.telco-stamp ##@python Test Python bindings for Linux/armhf
	export PYTHONPATH="$(shell pwd)/build/telco_thin-linux-armhf/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-python \
		&& ${PYTHON} -m unittest discover
check-python-linux-arm64: build/tmp_thin-linux-arm64/telco-$(PYTHON_NAME)/.telco-stamp ##@python Test Python bindings for Linux/arm64
	export PYTHONPATH="$(shell pwd)/build/telco_thin-linux-arm64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-python \
		&& ${PYTHON} -m unittest discover


node-linux-x86: build/telco-linux-x86/lib/node_modules/telco build/.telco-node-submodule-stamp ##@node Build Node.js bindings for Linux/x86
node-linux-x86_64: build/telco-linux-x86_64/lib/node_modules/telco build/.telco-node-submodule-stamp ##@node Build Node.js bindings for Linux/x86-64
node-linux-x86-thin: build/telco_thin-linux-x86/lib/node_modules/telco build/.telco-node-submodule-stamp ##@node Build Node.js bindings for Linux/x86 without cross-arch support
node-linux-x86_64-thin: build/telco_thin-linux-x86_64/lib/node_modules/telco build/.telco-node-submodule-stamp ##@node Build Node.js bindings for Linux/x86-64 without cross-arch support
node-linux-armhf: build/telco_thin-linux-armhf/lib/node_modules/telco build/.telco-node-submodule-stamp ##@node Build Node.js bindings for Linux/armhf
node-linux-arm64: build/telco_thin-linux-arm64/lib/node_modules/telco build/.telco-node-submodule-stamp ##@node Build Node.js bindings for Linux/arm64

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
		&& strip --strip-all ../$$@.tmp/build/telco_binding.node \
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
check-node-linux-x86: node-linux-x86 ##@node Test Node.js bindings for Linux/x86
	$(call run-node-tests,telco-linux-x86,$(TELCO),$(NODE_BIN_DIR),$(NODE),$(NPM))
check-node-linux-x86_64: node-linux-x86_64 ##@node Test Node.js bindings for Linux/x86-64
	$(call run-node-tests,telco-linux-x86_64,$(TELCO),$(NODE_BIN_DIR),$(NODE),$(NPM))
check-node-linux-x86-thin: node-linux-x86-thin ##@node Test Node.js bindings for Linux/x86 without cross-arch support
	$(call run-node-tests,telco_thin-linux-x86,$(TELCO),$(NODE_BIN_DIR),$(NODE),$(NPM))
check-node-linux-x86_64-thin: node-linux-x86_64-thin ##@node Test Node.js bindings for Linux/x86-64 without cross-arch support
	$(call run-node-tests,telco_thin-linux-x86_64,$(TELCO),$(NODE_BIN_DIR),$(NODE),$(NPM))
check-node-linux-armhf: node-linux-armhf ##@node Test Node.js bindings for Linux/armhf
	$(call run-node-tests,telco_thin-linux-armhf,$(TELCO),$(NODE_BIN_DIR),$(NODE),$(NPM))
check-node-linux-arm64: node-linux-arm64 ##@node Test Node.js bindings for Linux/arm64
	$(call run-node-tests,telco_thin-linux-arm64,$(TELCO),$(NODE_BIN_DIR),$(NODE),$(NPM))


tools-linux-x86: build/tmp-linux-x86/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Build CLI tools for Linux/x86
tools-linux-x86_64: build/tmp-linux-x86_64/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Build CLI tools for Linux/x86-64
tools-linux-x86-thin: build/tmp_thin-linux-x86/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Build CLI tools for Linux/x86 without cross-arch support
tools-linux-x86_64-thin: build/tmp_thin-linux-x86_64/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Build CLI tools for Linux/x86-64 without cross-arch support
tools-linux-armhf: build/tmp_thin-linux-armhf/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Build CLI tools for Linux/armhf
tools-linux-arm64: build/tmp_thin-linux-arm64/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Build CLI tools for Linux/arm64

define make-tools-rule
build/$2-%/telco-tools-$$(PYTHON_NAME)/.telco-stamp: build/.telco-tools-submodule-stamp build/$2-%/telco-$$(PYTHON_NAME)/.telco-stamp
	. build/$1-env-$$*.rc; \
	builddir=$$(@D); \
	if [ ! -f $$$$builddir/build.ninja ]; then \
		$$(call meson-setup-for-env,$1,$$*) \
			--prefix $$(TELCO)/build/$1-$$* \
			--libdir $$(TELCO)/build/$1-$$*/lib \
			$$(TELCO_FLAGS_COMMON) \
			-Dpython=$$(PYTHON) \
			telco-tools $$$$builddir || exit 1; \
	fi; \
	$$(MESON) install -C $$$$builddir || exit 1
	@touch $$@
endef
$(eval $(call make-tools-rule,telco,tmp))
$(eval $(call make-tools-rule,telco_thin,tmp_thin))

check-tools-linux-x86: build/tmp-linux-x86/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Test CLI tools for Linux/x86
	export PYTHONPATH="$(shell pwd)/build/telco-linux-x86/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-tools \
		&& ${PYTHON} -m unittest discover
check-tools-linux-x86_64: build/tmp-linux-x86_64/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Test CLI tools for Linux/x86-64
	export PYTHONPATH="$(shell pwd)/build/telco-linux-x86_64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-tools \
		&& ${PYTHON} -m unittest discover
check-tools-linux-x86-thin: build/tmp_thin-linux-x86/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Test CLI tools for Linux/x86 without cross-arch support
	export PYTHONPATH="$(shell pwd)/build/telco_thin-linux-x86/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-tools \
		&& ${PYTHON} -m unittest discover
check-tools-linux-x86_64-thin: build/tmp_thin-linux-x86_64/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Test CLI tools for Linux/x86-64 without cross-arch support
	export PYTHONPATH="$(shell pwd)/build/telco_thin-linux-x86_64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-tools \
		&& ${PYTHON} -m unittest discover
check-tools-linux-armhf: build/tmp_thin-linux-armhf/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Test CLI tools for Linux/armhf
	export PYTHONPATH="$(shell pwd)/build/telco_thin-linux-armhf/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-tools \
		&& ${PYTHON} -m unittest discover
check-tools-linux-arm64: build/tmp_thin-linux-arm64/telco-tools-$(PYTHON_NAME)/.telco-stamp ##@tools Test CLI tools for Linux/arm64
	export PYTHONPATH="$(shell pwd)/build/telco_thin-linux-arm64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd telco-tools \
		&& ${PYTHON} -m unittest discover


.PHONY: \
	help \
	distclean clean clean-submodules git-submodules git-submodule-stamps \
	gum-linux-x86 gum-linux-x86_64 \
		gum-linux-x86-thin gum-linux-x86_64-thin gum-linux-x86_64-gir \
		gum-linux-arm gum-linux-armbe8 gum-linux-armhf gum-linux-arm64 \
		gum-linux-mips gum-linux-mipsel \
		gum-linux-mips64 gum-linux-mips64el \
		gum-android-x86 gum-android-x86_64 \
		gum-android-arm gum-android-arm64 \
		gum-qnx-arm gum-qnx-armeabi \
		gum-windows-x86 gum-windows-x86_64 \
		check-gum-linux-x86 check-gum-linux-x86_64 \
		check-gum-linux-x86-thin check-gum-linux-x86_64-thin \
		check-gum-linux-armhf check-gum-linux-arm64 \
		telco-gum-update-submodule-stamp \
	core-linux-x86 core-linux-x86_64 \
		core-linux-x86-thin core-linux-x86_64-thin \
		core-linux-arm core-linux-armbe8 core-linux-armhf core-linux-arm64 \
		core-linux-mips core-linux-mipsel \
		core-linux-mips64 core-linux-mips64el \
		core-android-x86 core-android-x86_64 \
		core-android-arm core-android-arm64 \
		core-qnx-arm core-qnx-armeabi \
		core-windows-x86 core-windows-x86_64 \
		check-core-linux-x86 check-core-linux-x86_64 \
		check-core-linux-x86-thin check-core-linux-x86_64-thin \
		check-core-linux-armhf check-core-linux-arm64 \
		telco-core-update-submodule-stamp \
	python-linux-x86 python-linux-x86_64 \
		python-linux-x86-thin python-linux-x86_64-thin \
		python-linux-armhf python-linux-arm64 \
		check-python-linux-x86 check-python-linux-x86_64 \
		check-python-linux-x86-thin check-python-linux-x86_64-thin \
		check-python-linux-armhf check-python-linux-arm64 \
		telco-python-update-submodule-stamp \
	node-linux-x86 node-linux-x86_64 \
		node-linux-x86-thin node-linux-x86_64-thin \
		node-linux-armhf node-linux-arm64 \
		check-node-linux-x86 check-node-linux-x86_64 \
		check-node-linux-x86-thin check-node-linux-x86_64-thin \
		check-node-linux-armhf check-node-linux-arm64 \
		telco-node-update-submodule-stamp \
	tools-linux-x86 tools-linux-x86_64 \
		tools-linux-x86-thin tools-linux-x86_64-thin \
		tools-linux-armhf tools-linux-arm64 \
		check-tools-linux-x86 check-tools-linux-x86_64 \
		check-tools-linux-x86-thin check-tools-linux-x86_64-thin \
		check-tools-linux-armhf check-tools-linux-arm64 \
		telco-tools-update-submodule-stamp
.SECONDARY:
