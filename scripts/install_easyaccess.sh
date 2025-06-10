#!/bin/bash
set -e

echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[+] Installing dependencies..."
sudo apt install -y git build-essential cmake python3 python3-pip gcc g++ libgl1 libglu1-mesa libx11-dev xvfb wine

echo "[+] Installing Box86..."
cd ~
git clone https://github.com/ptitSeb/box86
cd box86
mkdir build; cd build
cmake .. -DRPI4=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j$(nproc)
sudo make install

echo "[+] Creating EasyAccess 2.0 directory..."
mkdir -p ~/ea2
echo "[!] Place your EasyAccess 2.0 client (eClient.exe) inside ~/ea2 before running!"

echo "[+] Creating run script..."
cat << 'EOF' > ~/ea2/run_easyaccess.sh
#!/bin/bash
cd ~/ea2
export BOX86_LOG=1
export WINEDEBUG=-all
Xvfb :1 -screen 0 1024x768x16 &
export DISPLAY=:1
box86 wine eClient.exe
EOF

chmod +x ~/ea2/run_easyaccess.sh

echo "[+] Creating systemd service..."
sudo tee /etc/systemd/system/easyaccess.service > /dev/null << EOF
[Unit]
Description=Weintek EasyAccess 2.0 Client
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=/home/$USER/ea2/run_easyaccess.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "[+] Enabling systemd service..."
sudo systemctl daemon-reexec
sudo systemctl enable easyaccess.service

echo "[+] Setup complete!"
echo "🔁 Reboot your Pi and EasyAccess 2.0 will start automatically!"
