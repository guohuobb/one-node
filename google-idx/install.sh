#!/usr/bin/env sh

PORT="${PORT:-8080}"
UUID="${UUID:-2584b733-9095-4bec-a7d5-62b473540f7a}"
BOT_TOKEN="${BOT_TOKEN:-7669258945:AAGNTd8625Oy6h3oWN8en1EfDn2ZY0BjpHc}"
CHAT_ID="${CHAT_ID:-7886284400}"

# 1. init directory
mkdir -p app/xray
cd app/xray

# 2. download and extract Xray
wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip Xray-linux-64.zip
rm -f Xray-linux-64.zip

# 3. add config file
wget -O config.json https://raw.githubusercontent.com/guohuobb/one-node/main/google-idx/xray-config-template.json
sed -i 's/$PORT/'$PORT'/g' config.json
sed -i 's/$UUID/'$UUID'/g' config.json

# 4. create startup.sh
wget https://raw.githubusercontent.com/guohuobb/one-node/main/google-idx/startup.sh
sed -i 's#$PWD#'$PWD'#g' startup.sh
chmod +x startup.sh

# 5. 生成节点链接（推送用）
NODE_URL="vless://$UUID@example.domain.com:443?encryption=none&security=tls&alpn=http%2F1.1&fp=chrome&type=xhttp&path=%2F&mode=auto#idx-xhttp"

# 6. 立即推送 Telegram（不会被阻塞）
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
 -d chat_id="$CHAT_ID" \
 -d text="IDX 节点已部署成功：

$NODE_URL
"

# 7. 启动 Xray（后台运行，不阻塞）
nohup $PWD/startup.sh >/dev/null 2>&1 &

# 8. 本地输出
echo '---------------------------------------------------------------'
echo "$NODE_URL"
echo '---------------------------------------------------------------'
