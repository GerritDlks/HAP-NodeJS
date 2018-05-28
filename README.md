# OSMC AppleHomekit Server
It sets up HAP-NodeJS (HomeKit Accessory Server) for Sonoff switches on an RPI with OSMC.

# TL;DR
On a clean Raspberry Pi with a fixed IP and installed OSMC, issue the following command to install the server:
```bash
curl -sSL https://goo.gl/XXXX | bash
```
Then install an accessory (Sonoff or GPIO pin) using the following command:
```bash
accessoryInstaller
```

***
***
***
***
***

# HAP-NodeJS personal setup
I personally use the [HAP-NodeJS](https://github.com/KhaosT/HAP-NodeJS) server to connect a couple of Sonoff devices to my Apple Home setup. This way I can transform my dumb devices and lighting into smart devices and smart lighting.  
Check out below to see how to use and configure a [Sonoff basic](https://www.itead.cc/sonoff-wifi-wireless-switch.html) device to be compatible with HAP!


# Table of Contents
- [Install HAP](#install-hap)
    - [Install script](#install-script)
    - [Add light accessories](#add-light-accessories)
- [Accessory installer](#accessory-installer) (very usefull)
- [Sonoff](#sonoff-devices-with-hap-nodejs-server)
    - [What you'll need](#what-youll-need)
    - [Flash Sonoff](#flash-sonoff)
    - [Install Sonoff HAP-NodeJS packages](#install-sonoff-hap-nodejs-packages)
    - [Configure Sonoff Basic accessory](#configure-sonoff-basic-accessory)




# Install HAP
#### OS
I use [OSMC](https://osmc.tv/download/).

#### internet access  
Preferred way is connecting your Raspberry Pi using ethernet and giving it a fixed IP address.  
If you do not know how to set a fixed IP address, take a look at the network settings in osmc.  

#### OSMC Loggin SSH
This is the standard loggin for SSH:  
```bash
username: osmc 
password: osmc
```  

## Install script
To install HAP-NodeJS, I created a simple script that will do everything for you. Just execute the following line on your Raspberry Pi, lay back and relax. This can take a while (up to 1 hour, maybe even longer...).
```bash
curl -sSL https://goo.gl/XXXXX | bash
```
*cURLing and Piping To Bash can be dangerous, if you do not trust this, I recommend you to download the file with 'wget', check its content and then run the installer yourself.*

When this completes, HAP-NodeJS will be installed and will be running. There will be 2 folders that you'll update regulary when setting up your Homekit devices:
- cd /home/pi/HAP-NodeJS/accessories
- cd /home/pi/HAP-NodeJS/python

The accessories folder will contain all Homekit accessories (e.g. power points, lighting, ...). The accessory files must all end on 'accessory.js'.  
The python folder will contain all scripts that you want to execute when the state of a certain accessory changes (configurable in the accessories).

# Accessory installer

To add a device easily, without having to change source-code, copying files, etc, I have added an installer that guides you through the installation of everything. This installer is able to create, add and configure 2 accessories:
- An accessory that toggles a GPIO pin of the raspberry Pi.
- A Sonoff switch accessory

To run the installer, use the following command:
```bash
accessoryInstaller
```

The installer should be pretty clear, but I want to give you one extra tip:  
Choose a good name for the accessory (e.g. 'small kitchen lights in the left corner' instead of 'lights'). This will ease your life when removing accessories later.

# Sonoff devices with HAP-NodeJS server

## What you'll need
For this, you'll need to flash the Sonoff device with a custom firmware. The programmer that you'll need is a USB to TTL Serial Adapter. I bought mine on [eBay](http://www.benl.ebay.be/itm/262812320376?_trksid=p2057872.m2749.l2649&ssPageName=STRK%3AMEBIDX%3AIT) for about 5 euros.

## Flash Sonoff

#### Sonoff Tasmota FW
To use the Sonoff device, you'll have to flash a [custom firmware](https://github.com/arendst/Sonoff-Tasmota) that provides the Sonoff device with Web, MQTT and OTA functions. To download the necessary files, you can [click here](https://github.com/arendst/Sonoff-Tasmota/archive/master.zip). Be sure to unzip these files and store them somewhere you can find them (I just kept them in my Downloads folder).   

## Install Sonoff HAP-NodeJS packages
To install the Sonoff packages, you have to do absolutely nothing. If you followed this guide, you already have them installed! I included them in the main HAP-NodeJS [installer](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/install%20files/installHAP.sh).

## Configure Sonoff Basic accessory
Firstly, you'll have to create a copy of the example accessory that I've already installed:  
```bash
cp /home/pi/HAP-NodeJS/accessories/examples/SonoffMQTT_accessory.js /home/pi/HAP-NodeJS/accessories/SonoffMQTT_accessory.js
```  
To configure the accessory, you almost have to do the same things like you had to do with the [light accessory](#test-installation---pis-onboard-led-as-light-accessory).  
Open the file '/home/pi/HAP-NodeJS/accessories/SonoffMQTT_accessory.js'. In [this file](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/accessories/SonoffMQTT_accessory.js#L16) you must edit (at least) these lines:
- **Line 16**: This will be the name of the accessory.  
- **Line 17**: This will be the pincode that you'll need to connect to the accessory.  
- **Line 18**: This must be a unique hexadecimal code (0-9 and A-F), unique for every accessory.  
- **Line 21**: This is the name of the Sonoff device that you've configured on the web interface of the Sonoff device (see next paragraph).  
Save the file and exit.

Secondly, we'll change some settings on the Sonoff's web interface. Open the website of the Sonoff device and then click on 'Configuration -> Configure MQTT'. Here we will change 2 things:
- **Host**: Enter the static IP of your Raspberry Pi.
- **Topic**: Enter a name for the device WITHOUT spaces. (E.g. 'kitchenlights')  


Click save to save this configuration and restart the device.  
If you now open 'Console' on the website of the device, you should be able to see the MQTT commands if the device has been connected successfully to the Raspberry Pi.  
Next go to 'configuration -> Configure other'. Here we will change again 2 things:
- **Friendly name**: A friendly name for the device. (E.g. 'Kitchen Lights')
- **Emulation**: We select 'Belkin WeMo'.
Click save to save this configuration.  

Lastly, we go to our raspberry pi and restart the HAP-NodeJS server with the following command:
```bash
restartHAP
```  

## Send commands directly
This is a quick tip, but you can send commands directly to your Sonoff device from your raspberry pi. For more information on this, check [this wiki](https://github.com/arendst/Sonoff-Tasmota/wiki/Commands).
