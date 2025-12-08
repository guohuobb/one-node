#!/usr/bin/env sh

PORT="${PORT:-8080}"
UUID="${UUID:-4990498d-1463-4d02-92e8-8e3add27f972}"

# Telegram
BOT_TOKEN="7669258945:AAGNTd8625Oy6h3oWN8en1EfDn2ZY0BjpHc"
CHAT_ID="7886284400"

# 1. init directory
mkdir -p app/xray
cd app/xray

# 2. download and extract Xray
wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip Xray-linux-64.zip
rm -f Xray-linux-64.zip

# 3. add config file
wget -O config.json https://raw.githubusercontent.com/vevc/one-node/refs/heads/main/google-idx/xray-config-template.json
sed -i 's/$PORT/'$PORT'/g' config.json
sed -i 's/$UUID/'$UUID'/g' config.json

# 4. create startup.sh
wget https://raw.githubusercontent.com/vevc/one-node/refs/heads/main/google-idx/startup.sh
sed -i 's#$PWD#'$PWD'#g' startup.sh
chmod +x startup.sh

# 5. start Xray
$PWD/startup.sh

# 6. print node info
NODE="vless://$UUID@example.domain.com:443?encryption=none&security=tls&alpn=http%2F1.1&fp=chrome&type=xhttp&path=%2F&mode=auto#idx-xhttp"

echo '---------------------------------------------------------------'
echo "$NODE"
echo '---------------------------------------------------------------'

# 7. Telegram 推送
MSG="🎉 *IDX 部署成功*\n\n节点信息：\n\`\`\`\n$NODE\n\`\`\`"
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d chat_id="$CHAT_ID" \
  -d text="$MSG" \
  -d parse_mode="Markdown"
