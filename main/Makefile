# Configure variables
DEFAULT_AWS_REGION := us-west-2
DEFAULT_AWS_PROFILE := default
DEFAULT_AWS_ACCOUNT := 145245897735

DK := docker

read_input = $(shell read -p $(1) REPLY; \
        if [ -z "$${REPLY}" ]; then echo $(2); else echo $${REPLY}; fi)

all: help
help:
	@echo "  debug  debugging run"
	@echo "  build  build Docker image"
	@echo "  push   push image"
	@echo "  pull   show pull command"

.PHONY: debug
debug:
	@echo "Starting DynamoDB local..."
	cd ../scripts/ && ./run_ddb.sh start
	@echo "Debugging entire website..."
	BOKEH_LOG_LEVEL=debug bokeh serve ../main --args --debug -vv

.PHONY: build
build:
	$(DK) build -t main .

.PHONY: push
push:
	sudo $(DK) tag taxi:latest $(DEFAULT_AWS_ACCOUNT).dkr.ecr.$(DEFAULT_AWS_REGION).amazonaws.com/taxi:latest
	sudo $(DK) push $(DEFAULT_AWS_ACCOUNT).dkr.ecr.$(DEFAULT_AWS_REGION).amazonaws.com/taxi:latest

.PHONY: pull
pull:
	@echo "Copy and paste following commands to Docker instance"
	@echo "\`aws ecr get-login --region $(DEFAULT_AWS_REGION)\`"
	@echo $(DK) pull $(DEFAULT_AWS_ACCOUNT).dkr.ecr.$(DEFAULT_AWS_REGION).amazonaws.com/taxi:latest

