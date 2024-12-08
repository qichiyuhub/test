# 需要检测的依赖项列表
DEPENDENCIES=("wget" "nft")


第一次提交

# 检查并安装缺失的依赖项
for DEP in "${DEPENDENCIES[@]}"; do
    if ! command -v $DEP &> /dev/null; then
        echo -e "${RED}$DEP 未安装。${NC}"
        read -p "是否安装 $DEP?(y/n): " install_dep
        if [[ "$install_dep" =~ ^[Yy]$ ]]; then
            sudo apt-get update
            sudo apt-get install -y $DEP
            if [[ $? -ne 0 ]]; then
                echo -e "${RED}安装 $DEP 失败，请手动安装 $DEP 并重新运行此脚本。${NC}"
                exit 1
            fi
            echo -e "${GREEN}$DEP 安装成功。${NC}"
        else
            echo -e "${RED}由于未安装 $DEP，脚本无法继续运行。${NC}"
            exit 1
        fi
    fi
done

# 检查系统是否支持
echo "检查系统类型和版本..."
if [[ "$(uname -s)" != "Linux" ]]; then
    echo -e "${RED}当前系统不支持运行此脚本。${NC}"
    exit 1
fi

# 检查发行版
if grep -qi 'debian' /etc/os-release; then
    echo -e "${GREEN}系统为Debian,支持运行此脚本。${NC}"
elif grep -qi 'ubuntu' /etc/os-release; then
    echo -e "${GREEN}系统为Ubuntu,支持运行此脚本。${NC}"
elif grep -qi 'armbian' /etc/os-release; then
    echo -e "${GREEN}系统为Armbian,支持运行此脚本。${NC}"
elif grep -qi 'openwrt' /etc/os-release; then
    echo "系统为OpenWRT,未来版本支持。"
    # 在这里预留OpenWRT的操作
    echo -e "${RED}OpenWRT版本尚未支持,敬请期待。${NC}"
    exit 1
else
    echo -e "${RED}当前系统不是Debian/Ubuntu/Armbian,不支持运行此脚本。${NC}"
    exit 1
fi

# 确保脚本目录存在并设置权限
sudo mkdir -p "$SCRIPT_DIR"
sudo chown "$(whoami)":"$(whoami)" "$SCRIPT_DIR"

# 下载并执行主脚本
echo "正在下载主脚本..."
wget -q -O "$SCRIPT_DIR/menu.sh" "$MAIN_SCRIPT_URL"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}下载主脚本失败,请检查网络连接。${NC}"
    exit 1
fi

# 删除引导脚本
if [ -f "$0" ]; then
    rm "$0"
    echo -e "${GREEN}引导脚本已删除。${NC}"
fi

echo "正在执行主脚本..."
chmod +x "$SCRIPT_DIR/menu.sh"
bash "$SCRIPT_DIR/menu.sh"

# 清理临时文件
rm "$SCRIPT_DIR/menu.sh"
