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

# Main commands
.PHONY: setup
setup: addkey vim-setup git-setup install-tools 

.PHONY: get-conf
get-conf: check-server-id get-db-conf get-nginx-conf get-service-file get-envsh

.PHONY: deploy-conf
deploy-conf: check-server-id deploy-db-conf deploy-nginx-conf deploy-service-file deploy-envsh

.PHONY: bench
bench: check-server-id mv-logs build deploy-conf restart watch-service-log

.PHONY: slow-query
slow-query:
	sudo pt-query-digest $(DB_SLOW_LOG)

.PHONY: alp
alp:
	sudo alp ltsv --file=$(NGINX_LOG) --config=/home/isucon/tool-config/alp/config.yml

.PHONY: pprof-record
pprof-record:
	go tool pprof http://localhost:6060/debug/pprof/profile

.PHONY: pprof-check
pprof-check:
	$(eval latest := $(shell ls -rt pprof/ | tail -n 1))
	go tool pprof -http=localhost:8090 pprof/$(latest)

.PHONY: access-db
access-db:
	mysql -h $(MYSQL_HOST) -P $(MYSQL_PORT) -u $(MYSQL_USER) -p$(MYSQL_PASS) $(MYSQL_DBNAME)

# Components
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
	# trdsql
	wget https://github.com/noborus/trdsql/releases/download/v0.10.0/trdsql_v0.10.0_linux_amd64.zip \
		&& unzip trdsql_v0.10.0_linux_amd64.zip \
		&& sudo install ./trdsql_v0.10.0_linux_amd64/trdsql /usr/local/bin/trdsql \
		&& rm -rf trdsql_v0.10.0_linux_amd64.zip trdsql_v0.10.0_linux_amd64
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
	ssh-keygen -t ed25519
	@echo "# git-setup"
	@echo "/*" >> $(GITIGNORE_PATH)
	@echo "!$(BIN_NAME)" >> $(GITIGNORE_PATH)
	@echo "!webapp" >> $(GITIGNORE_PATH)
	@echo "!Makefile" >> $(GITIGNORE_PATH)
	@echo "!.gitignore" >> $(GITIGNORE_PATH)
	@echo "!env.sh" >> $(GITIGNORE_PATH)
	@echo "!results" >> $(GITIGNORE_PATH)
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
	sudo rsync -qauh --no-o --no-g ~$(DB_PATH) $(DB_DIR_PATH)

.PHONY: deploy-nginx-conf
deploy-nginx-conf:
	sudo rsync -qauh --no-o --no-g ~$(NGINX_PATH) $(NGINX_DIR_PATH)

.PHONY: deploy-service-conf
deploy-service-conf:
	sudo rsync -qauh --no-o --no-g ~$(SYSTEMD_PATH) $(SYSTEMD_DIR_PATH)

.PHONY: deploy-envsh
deploy-envsh:
	sudo rsync -qauh --no-o --no-g ~$(ENVSH_PATH) $(ENVSH_DIR_PATH)

.PHONY: build
build:
	cd $(BUILD_DIR) && \
		go buildl -o $(BIN_NAME)

.PHONY: restart
restart:
	sudo systemctl daemon-reload
	sudo systemctl restart mysql
	sudo systemctl restart nginx
	sudo systemctl restart $(SERVICE_NAME)

.PHONY: mv-logs
mv-logs:
	sudo truncate $(NGINX_LOG) -s 0
	sudo truncate $(NGINX_ERROR_LOG) -s 0
	sudo truncate $(DB_SLOW_LOG) -s 0
	sudo truncate $(DB_ERROR_LOG) -s 0
	sudo nginx -s reopen
	sudo systemctl restart mysql

.PHONY: watch-service-log
watch-service-log:
	sudo journalctl -u $(SERVICE_NAME) -n10 -f
