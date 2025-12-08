#!/usr/bin/env sh

ARGO_TOKEN="${ARGO_TOKEN:-}"
BOT_TOKEN="7669258945:AAGNTd8625Oy6h3oWN8en1EfDn2ZY0BjpHc"
CHAT_ID="7886284400"

# --- Telegram 推送函数 ---
send_telegram() {
  local message=$1
  if [ -n "$BOT_TOKEN" ] && [ -n "$CHAT_ID" ]; then
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
         -d chat_id="${CHAT_ID}" \
         -d text="${message}" \
         -d parse_mode="Markdown" > /dev/null
  fi
}

# 1. init directory
mkdir -p app/argo
cd app/argo

# 2. download cloudflared
if [ ! -f cloudflared ]; then
  wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/download/2025.9.0/cloudflared-linux-amd64
  chmod +x cloudflared
fi

# 3. create startup.sh
wget -O startup.sh https://raw.githubusercontent.com/vevc/one-node/refs/heads/main/google-idx/argo/startup.sh
sed -i 's#$PWD#'$PWD'#g' startup.sh
if [ -n "$ARGO_TOKEN" ]; then
  sed -i "s/ARGO_TOKEN=/ARGO_TOKEN=$ARGO_TOKEN/g" startup.sh
fi
chmod +x startup.sh

# 4. start Argo
$PWD/startup.sh

# 5. 获取 Argo 隧道信息（这里假设域名/端口写在 startup.sh 内或日志）
ARGO_URL="https://your-argo-domain.example.com"  # 可根据实际解析日志修改

# 6. 推送到 Telegram
send_telegram "✅ Argo 隧道已启动：$ARGO_URL"

# 7. return main directory
cd ../..
