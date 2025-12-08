#!/usr/bin/env sh

PORT="${PORT:-8080}"
UUID="${UUID:-2584b733-9095-4bec-a7d5-62b473540f7a}"
BOT_TOKEN="${BOT_TOKEN:-7669258945:AAGNTd8625Oy6h3oWN8en1EfDn2ZY0BjpHc}"
CHAT_ID="${CHAT_ID:-7886284400}"

# -------------------------
# ⭐ 哪吒配置（process.env 风格）
# -------------------------
NEZHA_SERVER="${NEZHA_SERVER:-z.kkkk.hidns.co:80}"   # v1 填域名:端口；v0 填域名
NEZHA_PORT="${NEZHA_PORT:-}"                         # v1 留空；v0 填端口
NEZHA_KEY="${NEZHA_KEY:-ZPRVZUoCu50Wz0ZiL4mSf2zZelRDh1K5}"

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

# 6. Telegram 推送
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
 -d chat_id="$CHAT_ID" \
 -d text="IDX 节点已部署成功：

$NODE_URL
"

# -------------------------
# ⭐ 哪吒探针安装
# -------------------------

cd ..
mkdir -p nezha
cd nezha

wget -O nezha-agent https://github.com/naiba/nezha/releases/latest/download/nezha-agent_linux_amd64
chmod +x nezha-agent

# 使用你要求的 NEZHA_SERVER / PORT / KEY
nohup ./nezha-agent \
  -s "$NEZHA_SERVER" \
  -p "$NEZHA_KEY" \
  >/dev/null 2>&1 &

# -------------------------

# 7. 启动 Xray
nohup $PWD/../xray/startup.sh >/dev/null 2>&1 &

# 8. 本地输出
echo '---------------------------------------------------------------'
echo "$NODE_URL"
echo "哪吒监控已启动 → $NEZHA_SERVER"
echo '---------------------------------------------------------------'
