##########################################################################
##########################################################################

VERSION_MAJOR:=1
VERSION_MINOR:=04

# 20241015-000458-90730ec
# local
GHOULS_REVENGE_BUILD_SUFFIX?=local-build

##########################################################################
##########################################################################

ifeq ($(OS),Windows_NT)
PYTHON:=py -3
UNAME:=Windows_NT
else
UNAME:=$(shell uname -s)
PYTHON:=/usr/bin/python3
endif

##########################################################################
##########################################################################

_V:=$(if $(VERBOSE),,@)
TASS_ARGS:=--case-sensitive -Wall --cbm-prg $(if $(VERBOSE),,--quiet) --long-branch

##########################################################################
##########################################################################

PWD:=$(shell $(PYTHON) submodules/shellcmd.py/shellcmd.py realpath .)

# How to run shellcmd.py from any folder.
SHELLCMD:=$(PYTHON) $(PWD)/submodules/shellcmd.py/shellcmd.py

# submodules/beeb/bin (absolute path).
BEEB_BIN:=$(PWD)/submodules/beeb/bin

# bin (absolute path)
BIN:=$(PWD)/bin

# Where intermediate build output goes (absolute path).
BUILD:=$(PWD)/build

# Too late, I found I'd need more than one !BOOT, etc...
GP_BUILD:=$(PWD)/build/party

# Where the BeebLink volume is (absolute path).
BEEB_VOLUME:=$(PWD)/beeb/ghouls-revenge

# Where final Beeb-visible build output goes (absolute path).
GP_BEEB_OUTPUT:=$(BEEB_VOLUME)/x
BEEB_OUTPUT:=$(BEEB_VOLUME)/y
BEEB_OUTPUT_2:=$(BEEB_VOLUME)/z

# Name stem for disk images. Extension (etc.) appended.
OUTPUT_DISK_IMAGE_STEM?=ghouls-revenge
GP_OUTPUT_DISK_IMAGE_STEM?=ghouls-party

ifeq ($(OS),Windows_NT)
TASS:=$(PWD)/bin/64tass.exe
BASICTOOL:=$(PWD)/bin/basictool.exe
ZX02:=$(PWD)/bin/zx02.exe
else
TASS:=64tass
BASICTOOL:=$(PWD)/submodules/basictool/basictool
ZX02:=$(PWD)/submodules/zx02/build/zx02
endif

##########################################################################
##########################################################################

# A Python expression - False or True 
GPARTY_CHEAT:=False

##########################################################################
##########################################################################

.PHONY:build
build: _output_folders

ifneq ($(OS),Windows_NT)
	$(_V)cd submodules/basictool/src && $(MAKE) all
	$(_V)cd submodules/zx02 && $(MAKE) all
endif

# Convert title screen
	$(_V)$(MAKE) _title_screen

# Convert !BOOT
	$(_V)echo *RUN GRUN > "$(BUILD)/$$.!BOOT"
	$(_V)echo V$(VERSION_MAJOR).$(VERSION_MINOR) >> "$(BUILD)/$$.!BOOT"
	$(_V)echo Build ID: $(GHOULS_REVENGE_BUILD_SUFFIX) >> "$(BUILD)/$$.!BOOT"
	$(_V)$(PYTHON) "$(BEEB_BIN)/text2bbc.py" "$(BUILD)/$$.!BOOT"

# Convert README
	$(_V)$(SHELLCMD) copy-file "src/README.txt" "$(BUILD)/README.txt"
	$(_V)echo V$(VERSION_MAJOR).$(VERSION_MINOR) >> "$(BUILD)/README.txt"
	$(_V)echo Build ID: $(GHOULS_REVENGE_BUILD_SUFFIX) >> "$(BUILD)/README.txt"
	$(_V)$(SHELLCMD) copy-file "$(BUILD)/README.txt" "$(BUILD)/$$.README"
	$(_V)$(PYTHON) "$(BEEB_BIN)/text2bbc.py" "$(BUILD)/$$.README"

# Create levels stuff
	$(_V)$(MAKE) _asm PC=glevels BEEB=GLEVELS
	$(_V)$(PYTHON) "$(BIN)/levels.py" --output "$(BUILD)/levels.generated.s65" --output-list "$(BUILD)/levels.txt"

# Create GMC
	$(_V)$(MAKE) _asm PC=gmc BEEB=GMC TASS_EXTRA_ARGS=-Deditor=false
	$(_V)$(MAKE) _asm PC=gmc BEEB=GEDMC TASS_EXTRA_ARGS=-Deditor=true
	$(_V)$(MAKE) _asm PC=gmenu BEEB=GMENU
	$(_V)$(MAKE) _asm PC=grun BEEB=GRUN "TASS_EXTRA_ARGS=-Dversion_major=\'$(VERSION_MAJOR)\' -Dversion_minor=\'$(VERSION_MINOR)\' -Dbuild_suffix=\'$(GHOULS_REVENGE_BUILD_SUFFIX)\'"
	$(_V)$(MAKE) _asm PC=gdummy BEEB=GDUMMY

# Compressed screen stuff
	$(_V)$(MAKE) _asm PC=gscrp BEEB=GSCRP PRG2BBC_EXTRA_ARGS=--execution-address

# Create GBAS and GBASD
	$(_V)$(PYTHON) "$(BIN)/bbpp.py" -Ddebug=False --asm-symbols "$(BUILD)/GMC.symbols" "" -o "$(BUILD)/gbas.bas" "src/ghouls.bas"
	$(_V)$(BASICTOOL) --tokenise --basic-2 --output-binary "$(BUILD)/gbas.bas" "$(BUILD)/$$.GBAS"
	$(_V)$(PYTHON) $(BIN)/bbpp.py -Ddebug=True --asm-symbols "$(BUILD)/GMC.symbols" "" -o "$(BUILD)/gbasd.bas" "src/ghouls.bas"
	$(_V)$(BASICTOOL) --tokenise --basic-2 --output-binary "$(BUILD)/gbasd.bas" "$(BUILD)/$$.GBASD"

# Build disk images. Re-run make to ensure the $(shell cat gets re-evaluated.
	$(_V)$(MAKE) _disk_images

# Extract side 0 of .ssd to create individual drive in BeebLink
# volume.
	$(_V)$(SHELLCMD) rm-tree "$(BEEB_OUTPUT)"
	$(_V)$(SHELLCMD) mkdir "$(BEEB_OUTPUT)"
	$(_V)$(PYTHON) "$(BEEB_BIN)/ssd_extract.py" -o "$(BEEB_OUTPUT)" -0 "$(OUTPUT_DISK_IMAGE_STEM).ssd"

# Copy disk images somewhere useful for BeebLink.
	$(_V)$(SHELLCMD) copy-file "$(OUTPUT_DISK_IMAGE_STEM).ssd" "$(BEEB_OUTPUT_2)/S.GHOULS"
	$(_V)$(SHELLCMD) copy-file "$(OUTPUT_DISK_IMAGE_STEM).40.ssd" "$(BEEB_OUTPUT_2)/S.GHOULS40"
	$(_V)$(SHELLCMD) copy-file "$(OUTPUT_DISK_IMAGE_STEM).adl" "$(BEEB_OUTPUT_2)/L.GHOULSA"
	$(_V)$(SHELLCMD) copy-file "$(OUTPUT_DISK_IMAGE_STEM).adm" "$(BEEB_OUTPUT_2)/M.GHOULSA"
	$(_V)$(SHELLCMD) copy-file "$(OUTPUT_DISK_IMAGE_STEM).ads" "$(BEEB_OUTPUT_2)/S.GHOULSA"

# Ghouls Party
	$(_V)$(MAKE) _party_stuff
	$(_V)$(MAKE) _asm PC=gmc BEEB=GPMC "TASS_EXTRA_ARGS=-Deditor=false -Dparty=true"
	$(_V)$(MAKE) _asm PC=gparty_setup BEEB=GPSETUP
	$(_V)$(MAKE) _asm PC=../build/party_levels.generated BEEB=GPMETA
	$(_V)$(SHELLCMD) copy-file "src/gparty_boot.txt" "$(GP_BUILD)/$$.!BOOT"
	$(_V)echo V$(VERSION_MAJOR).$(VERSION_MINOR) >> "$(GP_BUILD)/$$.!BOOT"
	$(_V)echo Build ID: $(GHOULS_REVENGE_BUILD_SUFFIX) >> "$(GP_BUILD)/$$.!BOOT"
	$(_V)$(PYTHON) "$(BEEB_BIN)/text2bbc.py" "$(GP_BUILD)/$$.!BOOT"
	$(_V)$(PYTHON) "$(BIN)/bbpp.py" --asm-symbols "$(BUILD)/GPMC.symbols" "" -o "$(BUILD)/gparty.bas" -Dversion="$(VERSION_MAJOR).$(VERSION_MINOR)" -Dcheat=$(GPARTY_CHEAT) "src/gparty.bas"
	$(_V)$(BASICTOOL) --tokenise --basic-2 --output-binary "$(BUILD)/gparty.bas" "$(BUILD)/$$.GPARTY"
	$(_V)$(PYTHON) "$(BIN)/bbpp.py" --asm-symbols "$(BUILD)/GPMC.symbols" "" --asm-symbols "$(BUILD)/party_stuff.symbols" "" -o "$(BUILD)/gparty_loader.bas" -Dcheat=$(GPARTY_CHEAT) "src/gparty_loader.bas"
	$(_V)$(BASICTOOL) --tokenise --basic-2 --output-binary "$(BUILD)/gparty_loader.bas" "$(BUILD)/$$.GPLOAD"
	$(_V)$(MAKE) _party_disk_images

	$(_V)$(SHELLCMD) rm-tree "$(GP_BEEB_OUTPUT)"
	$(_V)$(SHELLCMD) mkdir "$(GP_BEEB_OUTPUT)"
	$(_V)$(PYTHON) "$(BEEB_BIN)/ssd_extract.py" -o "$(GP_BEEB_OUTPUT)" -0 "$(GP_OUTPUT_DISK_IMAGE_STEM).ssd"

	$(_V)$(SHELLCMD) copy-file "$(GP_OUTPUT_DISK_IMAGE_STEM).ssd" "$(BEEB_OUTPUT_2)/S.GPARTY"
	$(_V)$(SHELLCMD) copy-file "$(GP_OUTPUT_DISK_IMAGE_STEM).40.ssd" "$(BEEB_OUTPUT_2)/S.GPARTY40"
	$(_V)$(SHELLCMD) copy-file "$(GP_OUTPUT_DISK_IMAGE_STEM).adl" "$(BEEB_OUTPUT_2)/L.GPARTYA"
	$(_V)$(SHELLCMD) copy-file "$(GP_OUTPUT_DISK_IMAGE_STEM).adm" "$(BEEB_OUTPUT_2)/M.GPARTYA"
	$(_V)$(SHELLCMD) copy-file "$(GP_OUTPUT_DISK_IMAGE_STEM).ads" "$(BEEB_OUTPUT_2)/S.GPARTYA"

# Print some info
	$(_V)$(SHELLCMD) blank-line
	$(_V)$(PYTHON) "$(BIN)/budgets.py" "$(BUILD)" "$(BUILD)"
	$(_V)$(SHELLCMD) blank-line

##########################################################################
##########################################################################

.PHONY:_party_stuff
# same setup as for _disk_images
_party_stuff: _LEVELS:=$(shell $(SHELLCMD) cat -f $(BUILD)/levels.txt)
_party_stuff:
	$(_V)$(PYTHON) "$(BIN)/make_party_stuff.py" $(if $(VERBOSE),--verbose,) --zx02 "$(ZX02)" --zx02-cache-path "$(BUILD)/zx02_cache" --rom-output-stem "$(BUILD)/\$$.GPARTY" --s65-output "$(BUILD)/party_levels.generated.s65" --scores-output "$(GP_BUILD)/$$.GPTIMES" --symbols-output "$(BUILD)/party_stuff.symbols" --metadata-output "$(BUILD)/party_stuff.json" $(_LEVELS)

.PHONY:_party_disk_images
_party_disk_images: _FILES:="$(GP_BUILD)/$$.GPTIMES" "$(GP_BUILD)/$$.!BOOT" "$(BUILD)/$$.GPLOAD" "$(BUILD)/$$.GPSETUP" "$(BUILD)/$$.GPARTY0" "$(BUILD)/$$.GPMC" "$(BUILD)/$$.GPARTY" "$(BUILD)/$$.README" "$(BUILD)/$$.GPMETA" "$(BEEB_VOLUME)/2/$$.TPRINT" "$(BEEB_VOLUME)/2/$$.TMERGE" "$(GP_BUILD)/$$.BTIMES"
_party_disk_images: _SSD_OPTIONS:=--title "GHOULS P" --opt4 3 --must-exist
_party_disk_images: _ADF_OPTIONS:=--title "GHOULS PARTY" --opt4 3
_party_disk_images:
	$(_V)$(SHELLCMD) copy-file "$(BEEB_VOLUME)/2/6.TI251108" "$(GP_BUILD)/$$.BTIMES"
	$(_V)$(PYTHON) "$(BEEB_BIN)/ssd_create.py" -o "$(GP_OUTPUT_DISK_IMAGE_STEM).ssd" $(_SSD_OPTIONS) $(_FILES)
	$(_V)$(PYTHON) "$(BEEB_BIN)/ssd_create.py" -o "$(GP_OUTPUT_DISK_IMAGE_STEM).40.ssd" $(_SSD_OPTIONS) --40 $(_FILES)

	$(_V)$(PYTHON) "$(BEEB_BIN)/adf_create.py" -o "$(GP_OUTPUT_DISK_IMAGE_STEM).adl" --type l $(_ADF_OPTIONS) $(_FILES)
	$(_V)$(PYTHON) "$(BEEB_BIN)/adf_create.py" -o "$(GP_OUTPUT_DISK_IMAGE_STEM).adm" --type m $(_ADF_OPTIONS) $(_FILES)
	$(_V)$(PYTHON) "$(BEEB_BIN)/adf_create.py" -o "$(GP_OUTPUT_DISK_IMAGE_STEM).ads" --type s $(_ADF_OPTIONS) $(_FILES)

##########################################################################
##########################################################################

.PHONY:_disk_images
# It's possible levels.txt won't exist, meaning _LEVELS ends up empty.
# But by the time make _ssd is actually executed, as part of make
# build, it will be present.
_disk_images: _LEVELS:=$(shell $(SHELLCMD) cat -f $(BUILD)/levels.txt)
# $.BLANK gets added separately as it isn't included in the menus.
_disk_images: _FILES:=\
"$(BUILD)/$$.!BOOT" \
"$(BUILD)/$$.GRUN" \
"$(BUILD)/$$.GSCRP" \
"$(BUILD)/$$.GDUMMY" \
"$(BUILD)/$$.GMENU" \
"$(BUILD)/$$.GMC" \
"$(BUILD)/$$.GBAS" \
"$(BUILD)/$$.GBASD" \
"$(BUILD)/$$.GEDMC" \
$(_LEVELS) \
"$(BEEB_VOLUME)/2/$$.BLANK" \
"$(BUILD)/$$.README"
_disk_images: _SSD_OPTIONS:=--all-locked --title "GHOULS R" --opt4 3 --must-exist
_disk_images: _ADF_OPTIONS:=--all-non-writeable --title "GHOULS REVENGE" --opt4 3 
_disk_images:
	$(_V)$(PYTHON) "$(BEEB_BIN)/ssd_create.py" -o "$(OUTPUT_DISK_IMAGE_STEM).ssd" $(_SSD_OPTIONS) $(_FILES)
	$(_V)$(PYTHON) "$(BEEB_BIN)/ssd_create.py" -o "$(OUTPUT_DISK_IMAGE_STEM).40.ssd" $(_SSD_OPTIONS) --40 --must-exist $(_FILES)

	$(_V)$(PYTHON) "$(BEEB_BIN)/adf_create.py" -o "$(OUTPUT_DISK_IMAGE_STEM).adl" --type l $(_ADF_OPTIONS) $(_FILES)
	$(_V)$(PYTHON) "$(BEEB_BIN)/adf_create.py" -o "$(OUTPUT_DISK_IMAGE_STEM).adm" --type m $(_ADF_OPTIONS) $(_FILES)
	$(_V)$(PYTHON) "$(BEEB_BIN)/adf_create.py" -o "$(OUTPUT_DISK_IMAGE_STEM).ads" --type s $(_ADF_OPTIONS) $(_FILES)

##########################################################################
##########################################################################

.PHONY:_title_screen
_title_screen: $(BUILD)/title.zx02

$(BUILD)/title.zx02 : $(BUILD)/title.bbc
	$(_V)$(ZX02) "$<" "$@"

$(BUILD)/title.bbc : src/GhoulsRevenge.png
	$(_V)$(PYTHON) "$(BEEB_BIN)/png2bbc.py" -o "$@" "$<" 2

##########################################################################
##########################################################################

.PHONY:_asm
_asm:
	$(_V)$(TASS) $(TASS_ARGS) $(TASS_EXTRA_ARGS) -L "$(BUILD)/$(BEEB).lst" -l "$(BUILD)/$(BEEB).symbols" -o "$(BUILD)/$(BEEB).prg" "src/$(PC).s65"
	$(_V)$(PYTHON) "$(BEEB_BIN)/prg2bbc.py" $(PRG2BBC_EXTRA_ARGS) --io "$(BUILD)/$(BEEB).prg" "$(BUILD)/$$.$(BEEB)"

##########################################################################
##########################################################################

.PHONY:_output_folders
_output_folders:
	$(_V)$(SHELLCMD) mkdir "$(BUILD)"
	$(_V)$(SHELLCMD) mkdir "$(BEEB_OUTPUT_2)"
	$(_V)$(SHELLCMD) mkdir "$(GP_BUILD)"

##########################################################################
##########################################################################

.PHONY:clean
clean:
	$(_V)$(SHELLCMD) rm-tree "$(BUILD)"
	$(_V)$(SHELLCMD) rm-tree "$(BEEB_OUTPUT)"
	$(_V)$(SHELLCMD) rm-tree "$(BEEB_OUTPUT_2)"
	$(_V)$(SHELLCMD) rm-tree "$(GP_BEEB_OUTPUT)"
	$(_V)$(SHELLCMD) rm-file -f "$(OUTPUT_DISK_IMAGE_STEM).ssd"
	$(_V)$(SHELLCMD) rm-file -f "$(OUTPUT_DISK_IMAGE_STEM).40.ssd"
	$(_V)$(SHELLCMD) rm-file -f "$(OUTPUT_DISK_IMAGE_STEM).ads"
	$(_V)$(SHELLCMD) rm-file -f "$(OUTPUT_DISK_IMAGE_STEM).adm"
	$(_V)$(SHELLCMD) rm-file -f "$(OUTPUT_DISK_IMAGE_STEM).adl"
ifneq ($(OS),Windows_NT)
	$(_V)cd submodules/basictool/src && $(MAKE) clean
	$(_V)cd submodules/zx02 && $(MAKE) clean
endif

##########################################################################
##########################################################################

# This can be run locally, but it doesn't clean up after itself, and
# will leave some extra disk images in the working copy that aren't
# gitignored.
#
# The build is run twice so that every ADFS disk image has its own
# disk ID.
.PHONY:ci_build
ci_build:
	$(_V)$(MAKE) build _ci_zip OUTPUT_DISK_IMAGE_STEM=$(OUTPUT_DISK_IMAGE_STEM)-$(shell $(MAKE) ci_echo_versioned_suffix) GP_OUTPUT_DISK_IMAGE_STEM=$(GP_OUTPUT_DISK_IMAGE_STEM)-$(shell $(MAKE) ci_echo_versioned_suffix)
	$(_V)$(MAKE) build _ci_zip OUTPUT_DISK_IMAGE_STEM=$(OUTPUT_DISK_IMAGE_STEM)-$(shell $(MAKE) ci_echo_build_suffix) GP_OUTPUT_DISK_IMAGE_STEM=$(GP_OUTPUT_DISK_IMAGE_STEM)-$(shell $(MAKE) ci_echo_build_suffix)

.PHONY:_ci_zip
_ci_zip:
	$(_V)zip -9j "$(OUTPUT_DISK_IMAGE_STEM).zip" "$(OUTPUT_DISK_IMAGE_STEM).ssd" "$(OUTPUT_DISK_IMAGE_STEM).40.ssd" "$(OUTPUT_DISK_IMAGE_STEM).ads" "$(OUTPUT_DISK_IMAGE_STEM).adm" "$(OUTPUT_DISK_IMAGE_STEM).adl" "$(GP_OUTPUT_DISK_IMAGE_STEM).ssd" "$(GP_OUTPUT_DISK_IMAGE_STEM).40.ssd" "$(GP_OUTPUT_DISK_IMAGE_STEM).ads" "$(GP_OUTPUT_DISK_IMAGE_STEM).adm" "$(GP_OUTPUT_DISK_IMAGE_STEM).adl" "$(BUILD)/README.txt"

# If testing ci_build locally, ci_clean will remove all the junk it
# produces - along with anything else that matches the not very
# careful wildcards it uses. Good luck.
.PHONY:ci_clean
ci_clean:
	$(_V)$(MAKE) clean
	$(_V)$(SHELLCMD) rm-file -f $(wildcard *.ssd) $(wildcard *.ads) $(wildcard *.adm) $(wildcard *.adl) $(wildcard *.zip)

.PHONY:ci_echo_versioned_suffix
ci_echo_versioned_suffix:
	@echo v$(VERSION_MAJOR).$(VERSION_MINOR)

.PHONY:ci_echo_build_suffix
ci_echo_build_suffix:
	@echo $(GHOULS_REVENGE_BUILD_SUFFIX)

##########################################################################
##########################################################################

.PHONY:_tom_laptop
# _tom_laptop: CONFIG=Master 128 (MOS 3.20)
_tom_laptop: CONFIG=B/Acorn 1770
ifeq ($(UNAME),Darwin)
_tom_laptop: export CC=cc
endif
_tom_laptop:
	$(MAKE) --no-print-directory build
	-curl --connect-timeout 0.25 --silent -G 'http://localhost:48075/reset/b2' --data-urlencode "config=$(CONFIG)"
#	-curl --connect-timeout 0.25 --silent -H 'Content-Type:application/binary' --upload-file '$(OUTPUT_DISK_IMAGE_STEM).ssd' 'http://localhost:48075/run/b2?name=$(OUTPUT_DISK_IMAGE_STEM).ssd'
	-curl --connect-timeout 0.25 --silent -H 'Content-Type:application/binary' --upload-file '$(GP_OUTPUT_DISK_IMAGE_STEM).ssd' 'http://localhost:48075/run/b2?name=$(GP_OUTPUT_DISK_IMAGE_STEM).ssd'


.PHONY:_tom_windows_laptop
_tom_windows_laptop: CONFIG=B/Acorn 1770 + BeebLink
_tom_windows_laptop:
#	@$(MAKE) _tom_laptop

	@$(MAKE) build DUMMY=1
	-curl --connect-timeout 0.25 --silent -G 'http://localhost:48075/reset/b2' --data-urlencode "config=$(CONFIG)"

##########################################################################
##########################################################################

# Phony target for manual invocation. It doesn't run on every build,
# because it needs the VC++ command line tools on the path, something
# I don't want to require.

.PHONY:zx02_windows
zx02_windows: SRC:=$(PWD)/submodules/zx02/src
zx02_windows: _output_folders
	cd "$(BUILD)" && cl /W4 /Zi /O2 /Fe$(PWD)/bin/zx02.exe "$(SRC)/compress.c" "$(SRC)/memory.c" "$(SRC)/optimize.c" "$(SRC)/zx02.c"

##########################################################################
##########################################################################

# mads 2.1.7 build 33 (1 Aug 24) (2024/08/01)
# Syntax: mads source [options]
# -b:address      Generate binary file at specified address <address>
# -bc             Activate branch condition test
# -c              Activate case sensitivity for labels
# -d:label=value  Define a label and set it to <value>
# -f              Allow mnemonics at the first column of a line
# -fv:value       Set raw binary fill byte to <value>
# -hc[:filename]  Generate ".h" header file for CA65
# -hm[:filename]  Generate ".hea" header file for MADS
# -i:path         Use additional include directory, can be specified multiple times
# -l[:filename]   Generate ".lst" listing file
# -m:filename     Include macro definitions from file
# -ml:value       Set left margin for listing to <value>
# -o:filename     Set object file name
# -p              Display fully qualified file names in listing and error messages
# -vu             Verify code inside unreferenced procedures
# -x              Exclude unreferenced procedures from code generation
# -xp             Display warnings for unreferenced procedures

.PHONY:zx02_code_test
zx02_code_test: _MADS:=../../not-my/Mad-Assembler/bin/windows_x86_64/mads.exe
zx02_code_test: _output_folders
	"$(_MADS)" -d:comp_data=$$4000 -d:out_addr=$$3000 -b:$$900 -o:$(BUILD)/zx02-optim-mads.xex -l:$(BUILD)/zx02-optim-mads.lst submodules/zx02/6502/zx02-optim.asm
	dd if=$(BUILD)/zx02-optim-mads.xex of=$(BUILD)/zx02-optim-mads.bin bs=1 skip=6
	"$(TASS)" $(TASS_ARGS) -L $(BUILD)/zx02-optim-64tass.lst -o "$(BUILD)/zx02-optim-64tass.prg" "src/zx02-optim-test.s65"
	$(PYTHON) "$(BEEB_BIN)/prg2bbc.py" "$(BUILD)/zx02-optim-64tass.prg" "$(BUILD)/zx02-optim-64tass.bbc"
	$(SHELLCMD) cmp "$(BUILD)/zx02-optim-mads.bin" "$(BUILD)/zx02-optim-64tass.bbc"
