# Configure variables
DEFAULT_AWS_REGION := us-west-2
DEFAULT_AWS_BUCKET := aws-taxi
DEFAULT_AWS_PROFILE := default
DEFAULT_AWS_ACCOUNT := 145245897735

DK := docker

read_input = $(shell read -p $(1) REPLY; \
        if [ -z "$${REPLY}" ]; then echo $(2); else echo $${REPLY}; fi)

all: help
help:
	@echo "  debug  debugging run"


.PHONY: debug
debug:
	@echo "Starting DynamoDB local..."
	cd ../scripts/ && ./run_ddb.sh start
	@echo "Debugging entire website..."
	BOKEH_LOG_LEVEL=debug bokeh serve ../main --args --debug -vv
