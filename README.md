# Pi-hole QEI (Quick and Easy Install)
Repository for automatically preparing Raspberry Pi OS Lite with firstboot setup for Pi-Hole and Unbound DNS.

Supports both: Windows (with WSL) and Unix systems.

## How to use

### Modify

In root directory there's a file called `prep_img_args`. Modify provided arguments accordingly to your needs.
1. PIHOLE_IP - static IP of your choosing (check `arp -a` to see which IP addresses in your network are already taken - requires net-tools on Unix systems)
1. PIHOLE_HOST - hostname of the Raspberry Pi
1. PIHOLE_USER - name of pi user
1. PIHOLE_PASS - password for pi user

### Run

On Windows simply launch `prep_wsl.bat` - you will be asked to run the scripts as administrator - this is to make sure that Hyper-V and WSL are installed and enabled.

On Linux you have to launch `sudo prep_wsl.sh`. Make sure you have all required packages: `sudo curl xz file openssl`, as well as sudo access.

### Install

After scripts are executed, you will have a file called Image.img located in the root directory of this project. Use Etcher, Raspberry Pi Imager or dd.

## Important

Keep in mind that if you plan on using Raspberry Pi Imager - DO NOT use advanced settings as they will overwrite firstboot script that sets everything up.
