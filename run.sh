#!/bin/sh

UUID="e60d0960-7919-43b7-9e98-1b9c7329188f"

# Set ARG
ARCH="64"
DOWNLOAD_PATH="/tmp/xray"
mkdir -p ${DOWNLOAD_PATH} /etc/xray /usr/local/xray /var/log/xray

TAG=$(wget --no-check-certificate -qO- https://api.github.com/repos/xtls/Xray-core/releases/latest | grep 'tag_name' | cut -d\" -f4)

echo "The xray latest version: ${TAG}"

# Download files
XRAY_FILE="Xray-linux-${ARCH}.zip"
echo "Downloading binary file: ${XRAY_FILE}"
wget -O ${DOWNLOAD_PATH}/xray.zip https://github.com/XTLS/Xray-core/releases/download/${TAG}/${XRAY_FILE} >/dev/null 2>&1
echo "Download binary file: ${XRAY_FILE} completed"

# Prepare
echo "Prepare to use"
unzip -d /usr/local/xray ${DOWNLOAD_PATH}/xray.zip
chmod +x /usr/local/xray/xray

# Set config file
cat <<EOF >/etc/xray/config.json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 8000,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings" : {
          "path": "/vmess?ed=2048"
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": 8080,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${UUID}"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings" : {
          "path": "/vless?ed=2048"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

echo "XRay UUID: ${UUID}"

/usr/bin/supervisord -c /etc/supervisord.conf
