SHELL := $(shell env bash -c 'which bash')

ifeq ($(OS),Windows_NT)
    LDFLAGS=-lbcrypt -Wl,--subsystem,console
	MKTARGETDIR=mkdir $(dir $@) || true
	FS:=$(shell echo "\\")
else
	MKTARGETDIR=mkdir -p $(dir $@)
	FS:=/
endif

DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
TOOLS=tools
BUILD=build
SRC=src
LIB=lib
INC=include
TMP=tmp
BIN=bin
TESTSRC=tests
TESTBIN=tests$(FS)$(BIN)
VERSION_MAJOR=1
VERSION_MINOR=0
VERSION_PATCH=0
VER=$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)


CXXFLAGS=-O -g -std=c++17 -I$(INC)


.PHONY: power-on-self-test
power-on-self-test:
	"$(SHELL)" -c 'type mkdir'
	"$(SHELL)" -c 'type bash'
	"$(SHELL)" -c 'echo "$(BASH)"'


.PHONY: tools
tools : mkreldir.exe

mkreldir.exe : $(TOOLS)$(FS)mkreldir.cpp
	$(CXX) -o $@ $(CXXFLAGS) $(TOOLS)$(FS)mkreldir.cpp

$(TOOLS)$(FS)monitor.exe : $(TOOLS)$(FS)monitor.cpp
	$(CXX) -o $@ $(CXXFLAGS) $(TOOLS)$(FS)monitor.cpp

$(BUILD)$(FS)$(TMP)$(FS)monitor.cpp.o : $(TESTSRC)$(FS)monitor.cpp
	$(MKTARGETDIR)
	$(CXX) -c -o $@ $(CXXFLAGS) $< $(LDFLAGS)

$(BUILD)$(FS)$(TESTBIN)$(FS)monitor.exe : $(BUILD)$(FS)$(TMP)$(FS)monitor.cpp.o
	$(MKTARGETDIR)
	$(CXX) -o $@ $(CXXFLAGS) $< $(LDFLAGS)

$(BUILD)$(FS)$(TMP)$(FS)randomize.cpp.o : $(SRC)$(FS)randomize.cpp $(INC)$(FS)birdcage$(FS)randomize.h
	$(MKTARGETDIR)
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(BUILD)$(FS)$(TMP)$(FS)testrandomize.cpp.o : $(TESTSRC)$(FS)testrandomize.cpp $(INC)$(FS)birdcage$(FS)randomize.h
	$(MKTARGETDIR)
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(BUILD)$(FS)$(TESTBIN)$(FS)testrandomize.exe : $(BUILD)$(FS)$(TMP)$(FS)testrandomize.cpp.o $(BUILD)$(FS)$(TMP)$(FS)randomize.cpp.o
	$(MKTARGETDIR)
	$(CXX) -o $@ $(CXXFLAGS) $^ $(LDFLAGS)

.PHONY: test-randomize
test-randomize: $(BUILD)$(FS)$(TESTBIN)$(FS)testrandomize.exe $(BUILD)$(FS)$(TESTBIN)$(FS)monitor.exe
	$(BUILD)$(FS)$(TESTBIN)$(FS)monitor.exe pass $(BUILD)$(FS)$(TESTBIN)$(FS)testrandomize.exe

$(BUILD)/$(TMP)/canary.cpp.o : $(SRC)/canary.cpp $(INC)/birdcage/canary.h $(INC)/birdcage/randomize.h
	$(MKTARGETDIR)
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(BUILD)/$(TMP)/testcanary.cpp.o : $(TESTSRC)/testcanary.cpp $(INC)/birdcage/canary.h $(INC)/birdcage/randomize.h
	$(MKTARGETDIR)
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(BUILD)/$(TESTBIN)/testcanary.exe : $(BUILD)/$(TMP)/testcanary.cpp.o $(BUILD)/$(TMP)/canary.cpp.o $(BUILD)/$(TMP)/randomize.cpp.o
	$(MKTARGETDIR)
	$(CXX) -o $@ $(CXXFLAGS) $^ $(LDFLAGS)

.PHONY: test-canary
test-canary: $(BUILD)/$(TESTBIN)/testcanary.exe $(BUILD)/$(TESTBIN)/monitor.exe
	$(BUILD)/$(TESTBIN)/monitor.exe pass $(BUILD)/$(TESTBIN)/testcanary.exe --ok=true && \
		$(BUILD)/$(TESTBIN)/monitor.exe fail $(BUILD)/$(TESTBIN)/testcanary.exe --ok=false

$(BUILD)/$(TMP)/securedata.cpp.o : $(SRC)/securedata.cpp $(INC)/birdcage/securedata.h $(INC)/birdcage/canary.h $(INC)/birdcage/randomize.h
	$(MKTARGETDIR)
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(BUILD)/$(TMP)/testsecuredata.cpp.o : $(TESTSRC)/testsecuredata.cpp $(INC)/birdcage/securedata.h $(INC)/birdcage/canary.h $(INC)/birdcage/randomize.h
	$(MKTARGETDIR)
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(BUILD)/$(TESTBIN)/testsecuredata.exe : $(BUILD)/$(TMP)/testsecuredata.cpp.o $(BUILD)/$(TMP)/securedata.cpp.o $(BUILD)/$(TMP)/canary.cpp.o $(BUILD)/$(TMP)/randomize.cpp.o
	$(MKTARGETDIR)
	$(CXX) -o $@ $(CXXFLAGS) $^ $(LDFLAGS)

.PHONY: test-securedata
test-securedata : $(BUILD)/$(TESTBIN)/testsecuredata.exe $(BUILD)/$(TESTBIN)/monitor.exe
	$(BUILD)/$(TESTBIN)/monitor.exe pass $(BUILD)/$(TESTBIN)/testsecuredata.exe --ok=true && \
		$(BUILD)/$(TESTBIN)/monitor.exe fail $(BUILD)/$(TESTBIN)/testsecuredata.exe --ok=false

$(BUILD)/$(TMP)/testsecurearray.cpp.o : $(TESTSRC)/testsecurearray.cpp $(INC)/birdcage/securearray.h $(INC)/birdcage/securedata.h $(INC)/birdcage/canary.h $(INC)/birdcage/randomize.h
	$(MKTARGETDIR)
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(BUILD)/$(TESTBIN)/testsecurearray.exe : $(BUILD)/$(TMP)/testsecurearray.cpp.o $(BUILD)/$(TMP)/securedata.cpp.o $(BUILD)/$(TMP)/canary.cpp.o $(BUILD)/$(TMP)/randomize.cpp.o
	$(MKTARGETDIR)
	$(CXX) -o $@ $(CXXFLAGS) $^ $(LDFLAGS)

.PHONY: test-securearray
test-securearray : $(BUILD)/$(TESTBIN)/testsecurearray.exe $(BUILD)/$(TESTBIN)/monitor.exe
	$(BUILD)/$(TESTBIN)/monitor.exe pass $(BUILD)/$(TESTBIN)/testsecurearray.exe --ok=true && \
		$(BUILD)/$(TESTBIN)/monitor.exe fail $(BUILD)/$(TESTBIN)/testsecurearray.exe --ok=false

.PHONY: all
all : power-on-self-test tools tests

.PHONY: tests
tests : tools test-randomize test-canary test-securedata test-securearray

.PHONY: clean
clean :
	rm -rf mkreldir.exe $(BUILD)/$(BIN) $(BUILD)/$(TESTBIN) $(BUILD)/$(TMP)
