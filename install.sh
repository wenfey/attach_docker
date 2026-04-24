#!/bin/bash
# ==========================================
# 檔案: install.sh
# 說明: attach_docker 一鍵安裝腳本
# 執行: curl -sSL https://raw.../install.sh | bash
# ==========================================
set -e

GITHUB_USER="wenfey"
GITHUB_REPO="attach_docker"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$BRANCH"

BIN_DIR="$HOME/.local/bin"

echo -e "\033[1;36m🚀 開始安裝 attach_docker...\033[0m"

# 1. 建立目錄
mkdir -p "$BIN_DIR"

# 2. 下載主程式
echo "📥 下載主程式..."
# 加上 -f 參數，如果網址錯誤 (404) 會直接報錯，不會存入垃圾內容
curl -sSLf "$RAW_URL/bin/attach_docker" -o "$BIN_DIR/attach_docker"
chmod +x "$BIN_DIR/attach_docker"

# 3. 檢查並注入 PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "⚙️  將 $BIN_DIR 加入 ~/.bashrc 的 PATH 中..."
    echo -e '\n# attach_docker' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# 4. 完工與補全提示
echo -e "\n\033[1;32m✅ attach_docker 主程式安裝完成！🎉\033[0m"
echo -e "----------------------------------------------------"
echo -e "💡 \033[1;33m提示：我們支援超強的 Bash 自動補全功能！\033[0m"
echo -e "強烈建議您執行以下指令來啟用它："
echo -e ""
echo -e "   \033[1;36mattach_docker --install-completion\033[0m"
echo -e "----------------------------------------------------"
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "\033[1;31m(請先執行 source ~/.bashrc 或重開終端機，讓新指令生效)\033[0m"
fi
