#!/bin/bash
# 脚本名称: cloudshell-ssh-key-only.sh
# 作用: 在 Google Cloud Shell 中安装 SSH 公钥，实现免密登录。

# ===============================================
# 💥 必须替换为您的 SSH 公钥！
# ===============================================

# 您的 SSH 公钥 (以 ssh-ed25519 或 ssh-rsa 开头)
# 示例：ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICG6K7/WZFA44vcIjxwvoKq0LOSC4OaJLxfWjegSk8u4 ssh-ed25519-20251207015540
YOUR_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICG6K7/WZFA44vcIjxwvoKq0LOSC4OaJLxfWjegSk8u4 ssh-ed25519-20251207015540" 

# ===============================================
# 脚本核心逻辑
# ===============================================

echo "--- 🔑 步骤 1: 配置 SSH 免密登录 ---"

SSH_DIR="$HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"
USER_NAME=$(whoami)

# 检查公钥变量是否有效
if [ -z "$YOUR_PUBLIC_KEY" ] || [[ "$YOUR_PUBLIC_KEY" != ssh-* ]]; then
    echo "❌ 错误：公钥变量设置无效！请在脚本中设置正确的 YOUR_PUBLIC_KEY。"
    exit 1
fi

# 1. 创建 .ssh 目录并设置严格权限 (700)
echo "创建或检查 $SSH_DIR 目录..."
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 2. 将公钥添加到 authorized_keys 文件，并检查是否已存在
echo "检查并添加公钥到 $AUTH_KEYS..."
# grep -qF：静默、定长字符串匹配，检查公钥是否已存在
if grep -qF "$YOUR_PUBLIC_KEY" "$AUTH_KEYS"; then
    echo "✅ 公钥已存在，跳过添加。"
else
    echo "$YOUR_PUBLIC_KEY" >> "$AUTH_KEYS"
    echo "✅ SSH 公钥已添加。"
fi

# 3. 设置 authorized_keys 文件权限 (600)
chmod 600 "$AUTH_KEYS"

echo "--- 🎉 恭喜！设置完成 ---"
echo "请确保您的 Tailscale 客户端已启动。"
echo "您现在可以从本地设备使用您的私钥免密登录。"
echo "用户名: $USER_NAME"
# 脚本结束
