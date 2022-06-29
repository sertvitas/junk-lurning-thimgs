.DEFAULT_GOAL := help
DEFAULT_BRANCH := main
PRJ := $(PWD)
COMMIT := $(shell git rev-parse HEAD)

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

shellcheck: ## shellcheck project files. skip ohmyzsh_git_aliases.sh file
	find . -type f -name "*.sh" -exec "shellcheck" "--format=gcc" {} \;

