#!/bin/bash
# 脚本名称: cloudshell-ssh-setup.sh
# 作用: 自动检测系统、安装 OpenSSH Server、生成密钥、配置免密登录并启动服务。

# ===============================================
# 💥 请务必替换为您的 SSH 公钥！
# ===============================================
YOUR_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICG6K7/WZFA44vcIjxwvoKq0LOSC4OaJLxfWjegSk8u4 ssh-ed25519-20251207015540"

# ===============================================
# 1. 自动检测并安装 OpenSSH Server
# ===============================================
echo "--- 🛠️ 步骤 1: 检测系统并安装 SSH 服务 ---"

if command -v yum &> /dev/null; then
    echo "📦 检测到 Amazon Linux/CentOS (yum)。正在安装 openssh-server..."
    sudo yum install -y openssh-server
elif command -v apt-get &> /dev/null; then
    echo "📦 检测到 Debian/Ubuntu (apt)。正在安装 openssh-server..."
    sudo apt-get update
    sudo apt-get install -y openssh-server
else
    echo "❌ 错误: 未找到 yum 或 apt 包管理器，无法自动安装 SSHD。"
    exit 1
fi

# ===============================================
# 2. 生成 SSH 主机密钥 (修复 no hostkeys available 错误)
# ===============================================
echo "--- 🔑 步骤 2: 生成 SSH 主机密钥 ---"
# -A 参数会自动为所有支持的密钥类型生成缺失的主机密钥
sudo ssh-keygen -A

# ===============================================
# 3. 配置用户公钥 (免密登录)
# ===============================================
echo "--- 👤 步骤 3: 配置免密登录公钥 ---"

# 确定目标目录 (Cloud Shell 中通常是 root)
TARGET_DIR="$HOME/.ssh"
AUTH_KEYS="$TARGET_DIR/authorized_keys"

if [ -z "$YOUR_PUBLIC_KEY" ] || [[ "$YOUR_PUBLIC_KEY" != ssh-* ]]; then
    echo "❌ 错误：请在脚本中设置有效的 YOUR_PUBLIC_KEY！"
    exit 1
fi

mkdir -p "$TARGET_DIR"
chmod 700 "$TARGET_DIR"

if grep -qF "$YOUR_PUBLIC_KEY" "$AUTH_KEYS" 2>/dev/null; then
    echo "✅ 公钥已存在，跳过。"
else
    echo "$YOUR_PUBLIC_KEY" >> "$AUTH_KEYS"
    echo "✅ 公钥已添加。"
fi
chmod 600 "$AUTH_KEYS"

# ===============================================
# 4. 启动 SSHD 服务 (解决 Connection refused)
# ===============================================
echo "--- 🚀 步骤 4: 启动 SSHD 服务 ---"

# 先尝试停止可能已经运行的旧进程 (避免端口冲突)
sudo pkill sshd || true

# 确保运行目录存在 (Ubuntu 有时需要)
sudo mkdir -p /run/sshd

# 手动启动 sshd (因为没有 systemctl)
if [ -f "/usr/sbin/sshd" ]; then
    sudo /usr/sbin/sshd
    echo "✅ SSHD 启动命令已执行。"
else
    echo "❌ 错误: 找不到 /usr/sbin/sshd 文件，安装可能失败。"
    exit 1
fi

# ===============================================
# 5. 验证与完成
# ===============================================
echo "--- 🎉 检查服务状态 ---"
if pgrep sshd > /dev/null; then
    echo "✅ 成功！SSHD 服务正在运行。"
    echo "🔗 连接命令 (本地):"
    echo "ssh -i <您的私钥路径> root@<Tailscale-IP>"
else
    echo "❌ 警告: SSHD 似乎未能启动，请运行 'ps aux | grep sshd' 检查。"
fi
