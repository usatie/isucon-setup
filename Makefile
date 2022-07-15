#include $HOME/env.sh

# Environment Variables
# SERVER_ID: defined in env.sh

# Configure specific values before use
USER:=isucon
BIN_NAME:=isucondition
BUILD_DIR:=/home/isucon/webapp/go
SERVICE_NAME:=$(BIN_NAME).go.service

DB_PATH:=/etc/mysql
NGINX_PATH:=/etc/nginx
SYSTEMD_PATH:=/etc/systemd/system

NGINX_LOG:=/var/log/nginx/access.log
NGINX_ERROR_LOG:=/var/log/nginx/error.log
DB_SLOW_LOG:=/var/log/mysql/mysql-slow.log
DB_ERROR_LOG:=/var/log/mysql/error.log

# Main commands
.PHONY: oh-my-zsh
oh-my-zsh:
	sudo apt update
	sudo apt upgrade
	sudo apt install zsh
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

.PHONY: setup
setup: install-tools git-setup

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

	# zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

.PHONY: zshrc-setup
zshrc-setup:
	@echo 'export VISUAL=vim' >> ~/.zshrc
	@echo 'export EDITOR="$VISUAL"' >> ~/.zshrc
	@echo 'plugins+=(zsh-autosuggestions)' >> ~/.zshrc
	@echo 'source $ZSH/oh-my-zsh.sh' >> ~/.zshrc
	exec $SHELL

.PHONY: bashrc-setup
bashrc-setup:
	echo 'export VISUAL=vim' >> ~/.bashrc
	echo 'export EDITOR="$VISUAL"' >> ~/.bashrc

.PHONY: git-setup
git-setup:
	git config --global user.email "isucon@example.com"
	git config --global user.name "isucon"

	ssh-keygen -t ed25519

.PHONY: vim-setup
vim-setup:
	@echo 'set term=xterm-256color' >> ~/.vimrc
	@echo 'syntax on' >> ~/.vimrc
	@echo 'set tabstop=4' >> ~/.vimrc
	@echo 'set shiftwidth=4' >> ~/.vimrc
	@echo 'set autoindent' >> ~/.vimrc
	@echo 'set number' >> ~/.vimrc
	@echo "set viminfo='100,<200,s10,h'" >> ~/.vimrc

	@echo 'call plug#begin()' >> ~/.vimrc
	@echo "  Plug 'prabirshrestha/vim-lsp'" >> ~/.vimrc
	@echo "  Plug 'mattn/vim-lsp-settings'" >> ~/.vimrc
	@echo "  Plug 'mattn/vim-goimports'" >> ~/.vimrc
	@echo 'call plug#end()' >> ~/.vimrc

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

.PHONY: set-as-s2
set-as-s2:
	echo "SERVER_ID=s2" >> env.sh

.PHONY: set-as-s3
set-as-s3:
	echo "SERVER_ID=s3" >> env.sh

.PHONY: get-db-conf
get-db-conf:
	sudo cp -R $(DB_PATH)/* ~/$(SERVER_ID)/etc/mysql
	sudo chown $(USER) -R ~/$(SERVER_ID)/etc/mysql

.PHONY: get-nginx-conf
get-nginx-conf:
	sudo cp -R $(NGINX_PATH)/* ~/$(SERVER_ID)/etc/nginx
	sudo chown $(USER) -R ~/$(SERVER_ID)/etc/nginx

.PHONY: get-service-file
get-service-file:
	sudo cp -R $(SYSTEMD_PATH)/* ~/$(SERVER_ID)/etc/systemd/system/$(SERVICE_NAME)
	sudo chown $(USER) -R ~/$(SERVER_ID)/etc/systemd/system/$(SERVICE_NAME)

.PHONY: get-envsh
get-envsh:
	cp ~/env.sh ~/$(SERVER_ID)/home/isucon/env.sh

.PHONY: deploy-db-conf
deploy-db-conf:
	sudo cp -R ~/$(SERVER_ID)/etc/mysql/* $(DB_PATH)

.PHONY: deploy-nginx-conf
deploy-nginx-conf:
	sudo cp -R ~/$(SERVER_ID)/etc/nginx/* $(NGINX_PATH)

.PHONY: deploy-envsh
deploy-envsh:
	cp ~/$(SERVER_ID)/home/isucon/env.sh ~/env.sh

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
