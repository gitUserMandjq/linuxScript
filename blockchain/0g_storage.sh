#!/bin/bash

# 节点安装功能
function install_dependencies() {
	if [[ "$(uname)" == "Darwin" ]]; then
    	brew install llvm cmake
	elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
    	sudo apt-get update
		sudo apt-get install clang cmake build-essential
		sudo apt-get install screen
		# 检查 go 是否已安装
		if ! command -v go &> /dev/null
		then
			echo 'go未安装，新增开始执行安装......'
			# Download the Go installer
			wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
			# Extract the archive
			sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
			# Add /usr/local/go/bin to the PATH environment variable by adding the following line to your ~/.profile.
			export PATH=$PATH:/usr/local/go/bin
		fi

		# 检查 Git 是否已安装
		if ! command -v git &> /dev/null
		then
	    	# 如果 Git 未安装，则进行安装
	    	echo "未检测到 Git，正在安装..."
	    	sudo apt install git -y
		else
	    	# 如果 Git 已安装，则不做任何操作
	    	echo "Git 已安装。"
		fi
	else
    	echo "Unknown OS"
	fi
	# 安装rust
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

# 安装节点
function install_storage_node() {
	install_dependencies
	# 下载源码
	git clone https://github.com/0glabs/0g-storage-node.git

	cd 0g-storage-node
	git submodule update --init

	# Build in release mode
	cargo build --release

	read -p "请输入miner_id(必须保证唯一，不以0x开头): " miner_id
	sed -i "s/miner_id = .*/miner_id = \"$miner_id\"/" run/config.toml
	read -p "请输入miner_key(私钥，不以0x开头): " miner_key
    sed -i "s/miner_key = .*/miner_key = \"$miner_key\"/" run/config.toml

	cd run
	screen -dmS 0g_storage ../target/release/zgs_node --config config.toml
}

function start_storage_node() {
    cd 0g-storage-node/run
    screen -dmS 0g_storage ../target/release/zgs_node --config config.toml
}

function check_service_log() {
    current_date=$(date +"%Y-%m-%d")
    tail -f /root/0g-storage-node/run/log/zgs.log.$current_date
}

# 主菜单
function main_menu() {
	echo "请选择要执行的操作:"
    echo "1. 安装常规节点"
    echo "2. 查看常规版本节点日志"
    echo "3. 重启节点"
    read -p "请输入选项（1-3）: " OPTION

    case $OPTION in
    1) install_storage_node ;;
    2) check_service_log ;;
    3) start_storage_node;;
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu