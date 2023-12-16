sudo apt-get update -y
sudo apt install -y ubuntu-gnome-desktop

sudo apt install -y xserver-xorg-core
sudo apt install -y tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer


sudo systemctl start gdm
sudo systemctl enable gdm

sudo apt-get install -y ubuntu-restricted-extras
