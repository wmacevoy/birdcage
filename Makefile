DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SHELL := /bin/bash
ifeq ($(OS),Windows_NT)
    LDFLAGS=-lbcrypt -Wl,--subsystem,console
	MKTARGETDIR=mkdir $(subst /,\,$(dir $@))
else
	MKTARGETDIR=mkdir -p $(dir $@)
endif

CXXFLAGS=-O -g -std=c++17 -I$(INC)

BUILD=build
SRC=src
LIB=lib
INC=include
TMP=tmp
BIN=bin
TESTSRC=tests
TESTBIN=tests/$(BIN)
VERSION_MAJOR=1
VERSION_MINOR=0
VERSION_PATCH=0
VER=$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
 
$(BUILD)/$(TMP)/monitor.cpp.o : $(TESTSRC)/monitor.cpp
	$(MKTARGETDIR)
	$(CXX) -o $@ $(CXXFLAGS) $< $(LDFLAGS)

$(BUILD)/$(TESTBIN)/monitor.exe : $(BUILD)/$(TMP)/monitor.cpp.o
	$(MKTARGETDIR)
	$(CXX) -o $@ $(CXXFLAGS) $< $(LDFLAGS)

$(BUILD)/$(TMP)/randomize.cpp.o : $(SRC)/randomize.cpp $(INC)/birdcage/randomize.h
	$(MKTARGETDIR)
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(BUILD)/$(TMP)/testrandomize.cpp.o : $(TESTSRC)/testrandomize.cpp $(INC)/birdcage/randomize.h
	$(MKTARGETDIR)
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(BUILD)/$(TESTBIN)/testrandomize.exe : $(BUILD)/$(TMP)/testrandomize.cpp.o $(BUILD)/$(TMP)/randomize.cpp.o
	$(MKTARGETDIR)
	$(CXX) -o $@ $(CXXFLAGS) $^ $(LDFLAGS)

.PHONY: test-randomize
test-randomize: $(BUILD)/$(TESTBIN)/testrandomize.exe $(BUILD)/$(TESTBIN)/monitor.exe
	$(BUILD)/$(TESTBIN)/monitor.exe pass $(BUILD)/$(TESTBIN)/testrandomize.exe

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
all : tests

.PHONY: tests
tests : test-randomize test-canary test-securedata test-securearray

.PHONY: clean
clean :
	rm -rf $(BUILD)/$(BIN) $(BUILD)/$(TESTBIN) $(BUILD)/$(TMP)
