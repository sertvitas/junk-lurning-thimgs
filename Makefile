.DEFAULT_GOAL := help
.PHONY: gitconfig vim powerline
DEFAULT_BRANCH := main
PRJ := $(PWD)
COMMIT := $(shell git rev-parse HEAD)
BIN = $(HOME)/bin
BASHRCD = $(HOME)/bashrc.d
POWERLINE = $(HOME)/.config/powerline
# OS = 'Darwin' or 'Linux'
OS = $(shell uname -s)
# get epoch seconds at the start of the make run
EPOCH = $(shell date +%s)
MKDIR = mkdir -p
LN = ln -vs
LNF = ln -vsf


help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

home: ## configure home directory
	# manage all of my executables in $HOME/bin
	$(MKDIR) $(HOME)/bin
	# manage temporary/scratch files in $HOME/tmp
	$(MKDIR) $(HOME)/tmp
	# manage project files in $HOME/projects
	$(MKDIR) $(HOME)/projects

powerline: ## install and configure powerline
	pip3 install --user powerline-status
	pip3 install --user powerline-gitstatus
	$(MKDIR) $(POWERLINE)/colorschemes
	$(MKDIR) $(POWERLINE)/themes/shell
	$(LN) $(PRJ)/powerline/colorschemes_default.json  $(POWERLINE)/colorschemes/default.json
	$(LN) $(PRJ)/powerline/themes_shell_default.json  $(POWERLINE)/themes/shell/default.json

bash: ## configure bash environment
	$(MKDIR) $(BASHRCD)
	# some desc
	$(LN) $(PRJ)/bashrc.d/add_home_bin_to_path.sh  $(BASHRCD)/add_home_bin_to_path.sh
	$(LN) $(PRJ)/bashrc.d/aliases.sh  $(BASHRCD)/aliases.sh
	$(LN) $(PRJ)/bashrc.d/aws_functions.sh $(BASHRCD)/aws_functions.sh
	$(LN) $(PRJ)/bashrc.d/bash_functions.sh $(BASHRCD)/bash_functions.sh
	$(LN) $(PRJ)/bashrc.d/bash_powerline.sh $(BASHRCD)/bash_powerline.sh
	$(LN) $(PRJ)/bashrc.d/editor.sh  $(BASHRCD)/editor.sh
	$(LN) $(PRJ)/bashrc.d/fzf.sh  $(BASHRCD)/fzf.sh
	$(LN) $(PRJ)/bashrc.d/git_aliases.sh $(BASHRCD)/git_aliases.sh
	$(LN) $(PRJ)/bashrc.d/git_functions.sh $(BASHRCD)/git_functions.sh
	$(LN) $(PRJ)/bashrc.d/go.sh $(BASHRCD)/go.sh
	$(LN) $(PRJ)/bashrc.d/ohmyzsh_git_aliases.sh  $(BASHRCD)/ohmyzsh_git_aliases.sh
	$(LN) $(PRJ)/bashrc.d/packer.sh $(BASHRCD)/packer.sh
	$(LN) $(PRJ)/bashrc.d/ssh_aliases.sh $(BASHRCD)/ssh_aliases.sh
	$(LN) $(PRJ)/bashrc.d/temp_aliases.sh  $(BASHRCD)/temp_aliases.sh
	$(LN) $(PRJ)/bashrc.d/terragrunt_aliases.sh  $(BASHRCD)/terragrunt_aliases.sh
	$(LN) $(PRJ)/bashrc.d/tmux_aliases.sh $(BASHRCD)/tmux_aliases.sh
	sed -i.$(EPOCH) '/\.bashrc\.local/d' $(HOME)/.bashrc
	echo '. $(HOME)/.bashrc.local' >> $(HOME)/.bashrc
	$(LN) $(PRJ)/bashrc.local $(HOME)/.bashrc.local

gitconfig: ## deploy user gitconfig
	$(LN) $(PRJ)/gitconfig $(HOME)/.gitconfig

gpg: home ## download gpg scripts
	curl --silent -o $(BIN)/encrypt https://raw.githubusercontent.com/natemarks/pipeline-scripts/main/scripts/encrypt
	curl --silent -o $(BIN)/decrypt https://raw.githubusercontent.com/natemarks/pipeline-scripts/main/scripts/decrypt
	chmod 755 $(BIN)/encrypt
	chmod 755 $(BIN)/decrypt

stayback: ## configure stayback
	$(MKDIR) $(HOME)/.stayback
	$(HOME)/bin/decrypt $(PWD)/stayback.json.gpg
	$(LN) $(PRJ)/stayback.json  $(HOME)/.stayback.json

vim: ## configure vim
	$(LN) $(PRJ)/vim/vimrc  $(HOME)/.vimrc

shellcheck: ## shellcheck project files. skip ohmyzsh_git_aliases.sh file
	find . -type f -name "*.sh" ! -name 'ohmyzsh_git_aliases.sh' -exec "shellcheck" "--format=gcc" {} \;

packages: ## install required packages
    # dconf/uuid for gogh colors
	sudo apt-get install -y \
	curl \
	git \
    tree \
    make \
    wget \
    zip \
    unzip \
    seahorse-nautilus \
    fzf \
    ripgrep \
    silversearcher-ag \
    jq \
    fonts-powerline \
    dconf-cli \
    uuid-runtime \
    tmux \
    shellcheck \
    hunspell;

ssh-config: ## ssh config
	$(LN) $(PRJ)/ssh/config  $(HOME)/.ssh/config

rm-bash: ## remove bashrc config before replacing
	-rm -rf $(BASHRCD)
	-rm -f $(HOME)/.bashrc.local

rm-gpg: ## cleanup gpg scripts before replacing
	-rm -f $(BIN)/encrypt
	-rm -f $(BIN)/decrypt

rm-powerline: ## remove the powerline files before replacing
	-rm -f $(POWERLINE)/colorschemes/default.json
	-rm -f $(POWERLINE)/themes/shell/default.json

rm-ssh-config: ## remove gitconfig before replacing
	-rm -f $(HOME)/.ssh/config

rm-gitconfig: ## remove gitconfig before replacing
	-rm -f $(HOME)/.gitconfig

remove-all: rm-bash rm-gpg rm-powerline rm-ssh-config rm-gitconfig ## destroy everything you love

all: packages gpg powerline bash gitconfig ssh-config ## configure everything
