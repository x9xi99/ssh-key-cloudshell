#!/bin/bash

# ===============================================
# 💥 注意：替换为您自己的 Tailscale 认证密钥（如果需要）
# ===============================================

# 您的 SSH 公钥 (已替换为您提供的公钥)
YOUR_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICG6K7/WZFA44vcIjxwvoKq0LOSC4OaJLxfWjegSk8u4 ssh-ed25519-20251207015540" 

# ===============================================
# 脚本核心逻辑
# ===============================================

echo "--- 🔑 步骤 1: 配置 SSH 免密登录 ---"

SSH_DIR="$HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"
USER_NAME=$(whoami)

if [ -z "$YOUR_PUBLIC_KEY" ] || [[ "$YOUR_PUBLIC_KEY" != ssh-* ]]; then
    echo "❌ 错误：公钥变量设置无效！"
    exit 1
fi

# 1. 创建 .ssh 目录并设置严格权限 (700)
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 2. 将公钥添加到 authorized_keys 文件，并检查是否已存在
if grep -qF "$YOUR_PUBLIC_KEY" "$AUTH_KEYS"; then
    echo "✅ 公钥已存在，跳过添加。"
else
    echo "$YOUR_PUBLIC_KEY" >> "$AUTH_KEYS"
    echo "✅ SSH 公钥已添加。"
fi

# 3. 设置 authorized_keys 文件权限 (600)
chmod 600 "$AUTH_KEYS"

echo "--- 🎉 恭喜！设置完成 ---"
echo "您现在可以从本地设备使用您的私钥免密登录 Cloud Shell 的 Tailscale IP。"

# 脚本结束
