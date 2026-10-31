# Odroid C1 build instructions 

## On you build machine:
```bash
docker build --pull -t libreelec tools/docker/bionic
docker run -v ~/work/me:/home/docker -h libreelec -it libreelec
```

## Inside the docker container:
```bash
cd ~/clearelec
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386

PROJECT=S805 DEVICE=Odroid_C1 ARCH=arm tools/download-tool
PROJECT=S805 DEVICE=Odroid_C1 ARCH=arm make image
```
## Back on you build machine:
You need to run the following script with an SD card plugged in to fix up the boot partition. Make sure the device matches that of SD card.
```bash
sudo ./fixup.sh /dev/sdb
```

### Profit