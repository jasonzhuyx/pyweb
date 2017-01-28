# Go Makefile for go-coding
# Set OS platform
# See http://stackoverflow.com/questions/714100/os-detecting-makefile
# TODO: macro commands 'cp', 'mkdir', 'mv', 'rm', etc. for Windows
ifeq ($(shell uname),Darwin) # Mac OS
	OS_PLATFORM := darwin
	OS_PLATFORM_NAME := Mac OS
else
	ifeq ($(OS),Windows_NT) # Windows
		OS_PLATFORM := windows
		OS_PLATFORM_NAME := Windows
	else
		OS_PLATFORM := linux
		OS_PLATFORM_NAME := Linux
	endif
endif

# Set build parameters
OWNER := jasonzhuyx
PROJECT := pyweb
PROJECT_PACKAGE := github.com/$(OWNER)/$(PROJECT)

HUB_ACCOUNT := jasonzhuyx
DOCKER_IMAG := pyweb
DOCKER_TAGS := $(HUB_ACCOUNT)/$(DOCKER_IMAG)

# TODO: Test the Makefile macros
# to represent "ifdef VAR1 || VAR2", use
#		ifneq ($(call ifdef_any,VAR1 VAR2),) # ifneq ($(VAR1)$(VAR2),)
# to represent "ifdef VAR1 && VAR2", use
#		ifeq ($(call ifdef_none,VAR1 VAR2),) # ifneq ($(and $(VAR1),$(VAR2)),)
ifdef_any := $(filter-out undefined,$(foreach v,$(1),$(origin $(v))))
ifdef_none := $(filter undefined,$(foreach v,$(1),$(origin $(v))))


.PHONY: clean cmd run test

default: cmd
all: build-all test start

clean:
	@echo "============================================================"
	@echo "Cleaning build..."
	@echo "DONE: [$@]"

clean-docker:
ifeq ("$(wildcard /.dockerenv)","")
	# make in a docker host environment
	docker rm -f $(docker ps -a|grep ${DOCKER_IMAG}|awk '{print $1}') 2>/dev/null || true
	docker rmi -f $(docker images -a|grep ${DOCKER_TAGS} 2>&1|awk '{print $1}') 2>/dev/null || true
endif

clean-all: clean-docker clean
	@echo "DONE: [$@]"


cmd:
ifeq ("$(wildcard /.dockerenv)","")
	@echo ""
	@echo `date +%Y-%m-%d:%H:%M:%S` "Start bash in container '$(DOCKER_IMAG)'"
	./run.sh "/bin/bash"
else
	@echo "env in the container:"
	@echo "------------------------------------------------------------------------"
	@env | sort
	@echo "------------------------------------------------------------------------"
endif
	@echo "DONE: [$@]"


docker_build.log: Dockerfile
ifeq ("$(wildcard /.dockerenv)","")
	# make in a docker host environment
	@echo ""
	@echo `date +%Y-%m-%d:%H:%M:%S` "Building '$(DOCKER_TAGS)'"
	@echo "------------------------------------------------------------------------"
	docker build -t $(DOCKER_TAGS) . | tee docker_build.log
	@echo "------------------------------------------------------------------------"
	@echo ""
	docker images --all | grep -e 'REPOSITORY' -e '$(DOCKER_TAGS)'
	@echo "........................................................................"
	@echo "DONE: {docker build}"
	@echo ""
endif

build: docker_build.log
	@echo "DONE: [$@]"

start: build
	@echo "............................................................"
	@echo "Running $(PROJECT) server ..."
	@python server.py
	@echo "DONE: [$@]"

show-env:
	@echo "............................................................"
	@echo "OS Platform: "$(OS_PLATFORM_NAME)
	@echo "------------------------------------------------------------"
	@echo " SHELL = $(SHELL)"
	@echo ""
	@env | sort
	@echo ""

test:
	@echo "............................................................"
	@echo "Running tests ... "
	@echo "DONE: [$@]"
