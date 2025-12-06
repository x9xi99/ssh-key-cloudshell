# 🚀 Cloud Shell SSH 免密登录配置

[![GitHub Workflow Status](https://img.shields.io/badge/Status-Config_Ready-brightgreen)](https://github.com/c9si09/ssh-key-cloudshell)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

该仓库包含一个用于 **Google Cloud Shell (GCS)** 的自动化脚本 (`cloudshell-ssh-key-only.sh`)。其主要目标是通过 **SSH 密钥认证**实现对 GCS 实例的**无密码远程登录**。

这使得您能够通过 **Tailscale** 或其他内部网络方案分配的 **内网 IP**（例如 `100.x.x.x`）进行安全、快速地访问命令行终端。

## ⚙️ 工作原理

脚本执行时，会完成以下关键步骤：

1.  **创建目录：** 确保 `$HOME/.ssh/` 目录存在并设置了严格的权限 (`700`)。
2.  **安装公钥：** 将您预设的 **SSH 公钥** 写入到 `$HOME/.ssh/authorized_keys` 文件中。
3.  **设置权限：** 设置 `authorized_keys` 文件的权限为 `600`。

## ⚠️ 先决条件

在运行本脚本之前，请**务必**完成以下准备工作：

### 1. 准备 SSH 密钥对
* 您已在**本地计算机**上生成了 SSH 密钥对（推荐使用 `ssh-ed25519`）。
* **免密要求：** 为了实现真正的“免密登录”，请确保您的**私钥**文件在生成时**没有设置 Passphrase（密码）**。

### 2. 更新脚本中的公钥
* 您已将您的 **SSH 公钥**（以 `ssh-ed25519` 或 `ssh-rsa` 开头）替换到 GitHub 仓库中 `cloudshell-ssh-key-only.sh` 文件内的 `YOUR_PUBLIC_KEY` 变量。

### 3. Tailscale 运行
```bash
docker run -d \
  --name tailscale-exit-node \
  --hostname=my-docker-exit-node \
  --network host \
  -v /path/to/ts-state:/var/lib/tailscale \
  -e TS_AUTHKEY="你的密钥" \
  -e TS_EXTRA_ARGS="--advertise-exit-node" \
  tailscale/tailscale:latest
```
* 您已通过 **Docker** 或其他方式在 Cloud Shell 中启动了 **Tailscale 客户端**，并成功连接到您的 Tailnet，获得了内网 IP 地址。

## 🎯 一键安装与配置

在 Google Cloud Shell 终端中，只需运行以下**单行命令**即可立即下载并执行配置脚本：

```bash
curl -fsSL [https://raw.githubusercontent.com/c9si09/ssh-key-cloudshell/main/cloudshell-ssh-key-only.sh](https://raw.githubusercontent.com/c9si09/ssh-key-cloudshell/main/cloudshell-ssh-key-only.sh) | bash
```

**提示：** 这种管道符 (`| bash`) 方式直接执行脚本内容，无需单独使用 `chmod +x` 赋予权限。

## 🔗 连接方式

脚本成功运行后，您可以在**本地终端**使用以下命令连接到 Cloud Shell：

```bash
# 替换为您的私钥文件路径，您的GCP用户名，以及Tailscale分配给Cloud Shell的IP
ssh -i ~/.ssh/cloudshell_key <YOUR_GCP_USERNAME>@<TAILSCALE_IP_100.X.X.X> -p 22
```

> 默认 SSH 端口为 `22`。由于您使用的是 Tailscale 内网 IP，此连接是安全的。

---

## 贡献

欢迎任何改进或建议！如果您有更优化的配置方法，请随时提交 Pull Request。
```
