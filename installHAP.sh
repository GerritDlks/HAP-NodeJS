# --------------------------------------------------------------------
# OSMC installHAP
# --------------------------------------------------------------------
# Credits: https://github.com/Kevin-De-Koninck/Apple-Homekit-server
# Edited by GerritDlks
#--------------
# prerequisites
#--------------
# - OSMC
# - internet access
# - SSH access

# --------------------------------------------------------------------

# Pi housekeeping
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get autoclean -y
sudo apt-get autoremove -y
sudo apt-get install git make -y
sudo apt-get install g++ -y
sudo apt-get install whiptail -y
sudo apt-get install cron -y

# Disable power management for better WiFi stability
if lsusb | grep -q RTL8192CU; then
    echo "options 8192cu rtw_power_mgnt=0" | sudo tee -a /etc/modprobe.d/8192cu.conf > /dev/null
fi

# Install node
cd
sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
cd

 # install packages
sudo apt-get install git git-core libavahi-compat-libdnssd-dev libnss-mdns vim -y

#get vimrc file
sudo wget https://gist.githubusercontent.com/Kevin-De-Koninck/5edc9e5d46ebf6a8e3c8b75a98253a76/raw/e0a26db71f21f1bb6827e8503eb631c4db01e742/.vimrc

# Install HAP-nodeJS
# https://github.com/KhaosT/HAP-NodeJS
cd ~
sudo apt-get remove nodejs nodejs-legacy -y
sudo wget http://node-arm.herokuapp.com/node_latest_armhf.deb
sudo dpkg -i node_latest_armhf.deb
sudo rm -rf node_latest_armhf.deb
sudo npm install -g node-gyp
sudo git clone https://github.com/KhaosT/HAP-NodeJS.git
cd HAP-NodeJS/
sudo npm install
sudo npm install node-cmd

# Create Python script folder
sudo mkdir ~/HAP-NodeJS/python

# Install MQTT (Mosquito) for most of your own Home automation devices like Sonoff switches
cd ~/HAP-NodeJS
if ! type mosquitto>/dev/null; then
sudo apt-get install libc6 -y
sudo apt-get install libev4 -y
sudo apt-get install libuv1 -y
sudo apt --fix-broken install -y
		sudo wget http://ftp.us.debian.org/debian/pool/main/libw/libwebsockets/libwebsockets8_2.0.3-2_armhf.deb
        sudo wget http://ftp.us.debian.org/debian/pool/main/o/openssl/libssl1.1_1.1.0h-4_armhf.deb
        sudo wget http://repo.mosquitto.org/debian/pool/main/m/mosquitto/mosquitto_1.5-0mosquitto1_armhf.deb
		sudo dpkg -i libssl1.1_1.1.0h-4_armhf.deb
        sudo dpkg -i libwebsockets8_2.0.3-2_armhf.deb
        sudo dpkg -i mosquitto_1.5-0mosquitto1_armhf.deb
        sudo rm -rf libssl1.1_1.1.0h-4_armhf.deb
        sudo rm -rf libwebsockets8_2.0.3-2_armhf.deb
        sudo rm -rf mosquitto_1.5-0mosquitto1_armhf.deb
fi
cd ~/HAP-NodeJS
sudo npm install mqtt --save
# Copy accessories into example folder (so they won't spam your home app)
sudo mkdir ~/HAP-NodeJS/accessories/examples
sudo mv ~/HAP-NodeJS/accessories/*js ~/HAP-NodeJS/accessories/examples

# Install SonoffMQTT_accessory example
cd ~/HAP-NodeJS/accessories/
sudo wget https://raw.githubusercontent.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/master/accessories/SonoffMQTT_accessory.js



# Start HAP-NodeJS
cd ~/HAP-NodeJS
sudo npm install forever -g
sudo forever start BridgedCore.js

# Autmoatically start at boot
  #remove trailing white lines
#  while ! tail -n1 /etc/rc.local | grep -q exit; do
#      sudo sed -i '$ d' /etc/rc.local
#  done

  # Check if 'exit 0' is on the last line, if so, insert line before, else echo error
#  if tail -n1 /etc/rc.local | grep -q exit; then
#      sudo sed -i -e '$i sudo forever start ~/HAP-NodeJS/BridgedCore.js \n' /etc/rc.local
#  else
#      echo "COULD NOT APPEND 'sudo forever start ~/HAP-NodeJS/BridgedCore.js' to '/etc/rc.local', before 'exit 0'"
#  fi

# Create script that will restart HAP-NodeJS
echo "cd ~/HAP-NodeJS/ && sudo forever stopall" | sudo tee -a ~/HAP-NodeJS/startHAP.sh > /dev/null
echo "cd ~/HAP-NodeJS/ && sudo forever start BridgedCore.js " | sudo tee -a ~/HAP-NodeJS/startHAP.sh > /dev/null
sudo chmod 777 ~/HAP-NodeJS/startHAP.sh
sudo chmod +x ~/HAP-NodeJS/startHAP.sh

#Now get and install the custom accessory installer
cd ~/HAP-NodeJS/
sudo wget https://raw.githubusercontent.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/master/install%20files/accessoryInstaller.sh
sudo chmod +x ~/HAP-NodeJS/accessoryInstaller.sh


# execute the script every day and keep the pi busy (ping every 5 minutes) so it doesn't slack over time
#cd
#sudo crontab -l > mycron
#echo "@daily ~/HAP-NodeJS/startHAP.sh" >> mycron
#echo "*/5 * * * * ping -c 5 google.com" >> mycron
#sudo crontab mycron
#sudo rm -f mycron

# Create aliasses to start, stop and restart HAP-NodeJS
echo 'alias startHAP="cd ~/HAP-NodeJS/ && sudo forever start BridgedCore.js"' >> ~/.bashrc
echo 'alias stopHAP="cd ~/HAP-NodeJS/ && sudo forever stopall"' >> ~/.bashrc
echo 'alias restartHAP="~/HAP-NodeJS/startHAP.sh"' >> ~/.bashrc
echo 'alias accessoryInstaller="~/HAP-NodeJS/accessoryInstaller.sh"' >> ~/.bashrc
source ~/.bashrc

clear
echo "If there were no errors, HAP-NodeJS server is installed and on your Pi."
echo "HAP-NodeJS will automatically start when your Pi is booting up. If you want to stop the HAP-NodeJS, use 'sudo forever stopall'."
echo "------------------------------"
echo "It is recmmended to reboot your Raspberry Pi at this stage."
