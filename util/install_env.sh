# Print commands and exit on errors
set -xe

export DEBIAN_FRONTEND=noninteractive

# Add repository with P4 packages
# https://build.opensuse.org/project/show/home:p4lang
echo 'deb http://download.opensuse.org/repositories/home:/p4lang/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/home:p4lang.list
curl -fsSL https://download.opensuse.org/repositories/home:p4lang/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_p4lang.gpg > /dev/null

apt-get update 

apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

##注意1 mininet之前是git拉到本地安装，但是目前mininet已经支持apt安装 官方大概是没更新
##注意2 p4lang安装是很慢的 但是国内也能直接装
apt-get install -y --no-install-recommends --fix-missing\
  make \
  ca-certificates \
  curl \
  git \
  iproute2 \
  net-tools \
  python3 \
  python3-pip \
  tcpdump \
  unzip \
  valgrind \
  vim \
  wget \
  xcscope-el \
  xterm \
  libbpf \
  p4lang-p4c \
  p4lang-bmv2 \
  p4lang-pi \
  mininet

##注意3 这个必须是在su里安装，否则不能用
pip3 install -U scapy ipaddr ptf psutil grpcio pylint testresources mininet