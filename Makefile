include $(HOME)/env.sh

# Environment Variables
# SERVER_ID: defined in env.sh

# Configure specific values before use
GITHUB_USER_1:=usatie
GITHUB_USER_2:=hiroshi-kubota-rh
GITHUB_USER_3:=nao215912

USER:=isucon
BIN_NAME:=isucondition
BUILD_DIR:=$(HOME)/webapp/go
SERVICE_NAME:=$(BIN_NAME).go.service

# paths should be abosolute path
DB_PATH:=/etc/mysql
NGINX_PATH:=/etc/nginx
SYSTEMD_PATH:=/etc/systemd
ENVSH_PATH:=$(HOME)/env.sh
DB_DIR_PATH:=/etc
NGINX_DIR_PATH:=/etc
SYSTEMD_DIR_PATH:=/etc
ENVSH_DIR_PATH:=$(HOME)

GITIGNORE_PATH:=$(HOME)/.gitignore
ZSHRC_PATH:=$(HOME)/.zshrc
BASHRC_PATH:=$(HOME)/.bashrc
VIMRC_PATH:=$(HOME)/.vimrc

NGINX_LOG:=/var/log/nginx/access.log
NGINX_ERROR_LOG:=/var/log/nginx/error.log
DB_SLOW_LOG:=/var/log/mysql/mysql-slow.log
DB_ERROR_LOG:=/var/log/mysql/error.log

ALP_CONFIG_DIR:=$(HOME)/tool-config/alp
ALP_CONFIG:=$(ALP_CONFIG_DIR)/config.yml
TRDSQL_DIR:=$(HOME)/tool-config/trdsql
TRDSQL_SQL:=$(TRDSQL_DIR)/access.sql

DURATION=75
RESULT_DIR:=$(HOME)/results
RESULT_TOP_DIR:=$(RESULT_DIR)/top
RESULT_DSTAT_DIR:=$(RESULT_DIR)/dstat
RESULT_APP_DIR:=$(RESULT_DIR)/app
RESULT_SLOW_DIR:=$(RESULT_DIR)/slow
RESULT_ALP_DIR:=$(RESULT_DIR)/alp

# Main commands
.PHONY: setup
setup: addkey vim-setup git-setup install-tools makedir

.PHONY: get-conf
get-conf: check-server-id get-db-conf get-nginx-conf get-service-file get-envsh

.PHONY: deploy-conf
deploy-conf: check-server-id deploy-db-conf deploy-nginx-conf deploy-service-file deploy-envsh

.PHONY: bench
bench: check-server-id rotate build deploy-conf restart
	# Stats
	$(MAKE) top &
	$(MAKE) dstat &
	$(MAKE) pprof-record &
	
	# App log
	@$(MAKE) app-log &

	# wait for bench to finish
	sleep $(DURATION)

	# Digests
	$(MAKE) slow-query
	$(MAKE) alp

.PHONY: top
top:
	mkdir -p $(RESULT_TOP_DIR)
	$(eval n := $(shell ls -l $(RESULT_TOP_DIR) | wc | awk '{print $$1}'))
	LINES=20 top -b -d 1 -n $(DURATION) -w > $(RESULT_TOP_DIR)/$(n).$(SERVER_ID).log

.PHONY: dstat
dstat:
	mkdir -p $(RESULT_DSTAT_DIR)
	$(eval n := $(shell ls -l $(RESULT_DSTAT_DIR) | wc | awk '{print $$1}'))
	dstat -tcdm --tcp -n 1 $(DURATION) > $(RESULT_DSTAT_DIR)/$(n).$(SERVER_ID).log

.PHONY: app-log
app-log:
	@mkdir -p $(RESULT_APP_DIR)
	@$(eval n = $(shell ls -l $(RESULT_APP_DIR) | wc | awk '{print $$1}'))
	sudo journalctl -f -u $(SERVICE_NAME) \
		| tee $(RESULT_APP_DIR)/$(n).$(SERVER_ID).log

.PHONY: slow-query
slow-query:
	mkdir -p $(RESULT_SLOW_DIR)
	$(eval n := $(shell ls -l $(RESULT_SLOW_DIR) | wc | awk '{print $$1}'))
	sudo pt-query-digest --explain h=$(MYSQL_HOST),u=$(MYSQL_USER),p=$(MYSQL_PASS) $(DB_SLOW_LOG) \
		| tee $(RESULT_SLOW_DIR)/$(n).$(SERVER_ID).digest

.PHONY: alp
alp:
	mkdir -p $(RESULT_ALP_DIR)
	$(eval n := $(shell ls -l $(RESULT_ALP_DIR) | wc | awk '{print $$1}'))
	sudo alp ltsv --file=$(NGINX_LOG) --config=$(ALP_CONFIG) \
		| tee $(RESULT_ALP_DIR)/$(n).$(SERVER_ID).digest

.PHONY: pprof-record
pprof-record:
	go tool pprof -raw -seconds $(DURATION) http://localhost:6060/debug/pprof/profile

.PHONY: pprof-check
pprof-check:
	$(eval latest := $(shell ls -rt $(HOME)/pprof/ | tail -n 1))
	go tool pprof -http=localhost:8090 $(HOME)/pprof/$(latest)

.PHONY: access-db
access-db:
	mysql -h $(MYSQL_HOST) -P $(MYSQL_PORT) -u $(MYSQL_USER) -p$(MYSQL_PASS) $(MYSQL_DBNAME)

# Components
.PHONY: makedir
makedir:
	mkdir -p $(ALP_CONFIG_DIR)
	mkdir -p $(TRDSQL_DIR)
	mkdir -p $(RESULT_TOP_DIR)
	mkdir -p $(RESULT_DSTAT_DIR)
	mkdir -p $(RESULT_APP_DIR)
	mkdir -p $(RESULT_SLOW_DIR)
	mkdir -p $(RESULT_ALP_DIR)

.PHONY: install-tools
install-tools:
	# apt install
	sudo apt update
	sudo apt upgrade
	sudo apt install -y percona-toolkit dstat git unzip snapd graphviz tree net-tools iotop apache2-utils
	# alp
	wget https://github.com/tkuchiki/alp/releases/download/v1.0.9/alp_linux_amd64.zip \
		&& unzip alp_linux_amd64.zip \
		&& sudo install ./alp /usr/local/bin/alp \
		&& rm alp_linux_amd64.zip alp
	mkdir -p $(ALP_CONFIG_DIR)
	wget https://raw.githubusercontent.com/usatie/isucon-setup/main/tool-config/alp/config.yml -O $(ALP_CONFIG)
	# trdsql
	wget https://github.com/noborus/trdsql/releases/download/v0.10.0/trdsql_v0.10.0_linux_amd64.zip \
		&& unzip trdsql_v0.10.0_linux_amd64.zip \
		&& sudo install ./trdsql_v0.10.0_linux_amd64/trdsql /usr/local/bin/trdsql \
		&& rm -rf trdsql_v0.10.0_linux_amd64.zip trdsql_v0.10.0_linux_amd64
	mkdir -p $(TRDSQL_DIR)
	wget https://raw.githubusercontent.com/usatie/isucon-setup/main/tool-config/trdsql/access.sql -O $(TRDSQL_SQL)
	# go (goimports/pprof)
	go install golang.org/x/tools/cmd/goimports@latest
	go install github.com/google/pprof@latest

.PHONYE: addkey
addkey:
	mkdir -p ~/.ssh
	curl https://github.com/$(GITHUB_USER_1).keys >> ~/.ssh/authorized_keys
	curl https://github.com/$(GITHUB_USER_2).keys >> ~/.ssh/authorized_keys
	curl https://github.com/$(GITHUB_USER_3).keys >> ~/.ssh/authorized_keys

.PHONY: git-setup
git-setup:
	git config --global user.email "isucon@example.com"
	git config --global user.name "isucon"
	ssh-keygen
	@echo "# git-setup"
	@echo "/*" >> $(GITIGNORE_PATH)
	@echo "/env.sh" >> $(GITIGNORE_PATH)
	@echo "!$(BIN_NAME)" >> $(GITIGNORE_PATH)
	@echo "!webapp" >> $(GITIGNORE_PATH)
	@echo "!Makefile" >> $(GITIGNORE_PATH)
	@echo "!.gitignore" >> $(GITIGNORE_PATH)
	@echo "!results" >> $(GITIGNORE_PATH)
	@echo "!tool-config" >> $(GITIGNORE_PATH)
	@echo "!s1" >> $(GITIGNORE_PATH)
	@echo "!s2" >> $(GITIGNORE_PATH)
	@echo "!s3" >> $(GITIGNORE_PATH)

.PHONY: oh-my-zsh
oh-my-zsh:
	sudo apt update
	sudo apt upgrade
	sudo apt install -y zsh
	sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

.PHONY: zsh-setup
zsh-setup:
	# zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	@echo "# zsh-setup"
	@echo 'export VISUAL=vim' >> $(ZSHRC_PATH)
	@echo 'export EDITOR="$$VISUAL"' >> $(ZSHRC_PATH)
	@echo 'plugins+=(zsh-autosuggestions)' >> $(ZSHRC_PATH)
	@echo 'source $$ZSH/oh-my-zsh.sh' >> $(ZSHRC_PATH)
	@echo 'export PATH=$$HOME/local/go/bin:$$HOME/go/bin:$$PATH' >> $(ZSHRC_PATH)
	@echo 'export GOROOT=/home/isucon/local/go' >> $(ZSHRC_PATH)
	@echo 'Restart zsh by "exec $$SHELL"'

.PHONY: vim-setup
vim-setup:
	@echo "# vim-setup"
	@echo 'set term=xterm-256color' >> $(VIMRC_PATH)
	@echo 'syntax on' >> $(VIMRC_PATH)
	@echo 'set tabstop=4' >> $(VIMRC_PATH)
	@echo 'set shiftwidth=4' >> $(VIMRC_PATH)
	@echo 'set autoindent' >> $(VIMRC_PATH)
	@echo 'set number' >> $(VIMRC_PATH)
	@echo "set viminfo='100,<200,s10,h" >> $(VIMRC_PATH)
	@echo "" >> $(VIMRC_PATH)
	@echo 'call plug#begin()' >> $(VIMRC_PATH)
	@echo "  Plug 'prabirshrestha/vim-lsp'" >> $(VIMRC_PATH)
	@echo "  Plug 'mattn/vim-lsp-settings'" >> $(VIMRC_PATH)
	@echo "  Plug 'mattn/vim-goimports'" >> $(VIMRC_PATH)
	@echo 'call plug#end()' >> $(VIMRC_PATH)
	# vim-plug
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	vim +PlugInstall +qa

.PHONY: check-server-id
check-server-id:
ifdef SERVER_ID
	@echo "SERVER_ID=$(SERVER_ID)"
else
	@echo "SERVER_ID is unset"
	@exit 1
endif

.PHONY: set-as-s1
set-as-s1:
	echo "SERVER_ID=s1" >> env.sh
	mkdir -p $(HOME)/s1

.PHONY: set-as-s2
set-as-s2:
	echo "SERVER_ID=s2" >> env.sh
	mkdir -p $(HOME)/s2

.PHONY: set-as-s3
set-as-s3:
	echo "SERVER_ID=s3" >> env.sh
	mkdir -p $(HOME)/s3

.PHONY: get-db-conf
get-db-conf:
	mkdir -p ~/$(SERVER_ID)$(DB_DIR_PATH)
	sudo rsync -qauh $(DB_PATH) ~/$(SERVER_ID)$(DB_DIR_PATH)
	sudo chown $(USER) -R ~/$(SERVER_ID)$(DB_DIR_PATH)

.PHONY: get-nginx-conf
get-nginx-conf:
	mkdir -p ~/$(SERVER_ID)$(NGINX_DIR_PATH)
	sudo rsync -qauh $(NGINX_PATH) ~/$(SERVER_ID)$(NGINX_DIR_PATH)
	sudo chown $(USER) -R ~/$(SERVER_ID)$(NGINX_DIR_PATH)

.PHONY: get-service-file
get-service-file:
	mkdir -p ~/$(SERVER_ID)$(SYSTEMD_DIR_PATH)
	sudo rsync -qauh $(SYSTEMD_PATH) ~/$(SERVER_ID)$(SYSTEMD_DIR_PATH)
	sudo chown $(USER) -R ~/$(SERVER_ID)$(SYSTEMD_DIR_PATH)

.PHONY: get-envsh
get-envsh:
	mkdir -p ~/$(SERVER_ID)$(ENVSH_DIR_PATH)
	rsync -qauh $(ENVSH_PATH) ~/$(SERVER_ID)$(ENVSH_DIR_PATH)

.PHONY: deploy-db-conf
deploy-db-conf:
	sudo rsync -qauh --no-o --no-g ~/$(SERVER_ID)$(DB_PATH) $(DB_DIR_PATH)

.PHONY: deploy-nginx-conf
deploy-nginx-conf:
	sudo rsync -qauh --no-o --no-g ~/$(SERVER_ID)$(NGINX_PATH) $(NGINX_DIR_PATH)

.PHONY: deploy-service-file
deploy-service-file:
	sudo rsync -qauh --no-o --no-g ~/$(SERVER_ID)$(SYSTEMD_PATH) $(SYSTEMD_DIR_PATH)

.PHONY: deploy-envsh
deploy-envsh:
	sudo rsync -qauh --no-o --no-g ~/$(SERVER_ID)$(ENVSH_PATH) $(ENVSH_DIR_PATH)

.PHONY: build
build:
	cd $(BUILD_DIR) && \
		go build -o $(BIN_NAME)

.PHONY: restart
restart:
	sudo systemctl daemon-reload
	sudo systemctl restart mysql
	sudo systemctl restart nginx
	sudo systemctl restart $(SERVICE_NAME)

.PHONY: rotate
rotate:
	sudo truncate $(NGINX_LOG) -s 0
	sudo truncate $(NGINX_ERROR_LOG) -s 0
	sudo truncate $(DB_SLOW_LOG) -s 0
	sudo truncate $(DB_ERROR_LOG) -s 0
	sudo nginx -s reopen
	sudo systemctl restart mysql

.PHONY: watch-service-log
watch-service-log:
	sudo journalctl -u $(SERVICE_NAME) -n10 -f
