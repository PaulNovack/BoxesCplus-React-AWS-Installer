export DEBIAN_FRONTEND=noninteractive
sudo apt-get remove needrestart
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
wget https://cdn.mysql.com//Downloads/Connector-C++/libmysqlcppconn9_8.0.29-1ubuntu20.04_amd64.deb
sudo DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install g++ -y 
sudo DEBIAN_FRONTEND=noninteractive apt-get install rsync zip openssh-server make -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install libmysqlcppconn-dev libboost-all-dev gcc -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install build-essential -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install gcc-multilib net-tools vim curl nodejs npm -y
sudo dpkg -i libmysqlcppconn9_8.0.29-1ubuntu20.04_amd64.deb
mkdir code
cd code
mkdir boxes
git clone https://github.com/PaulNovack/boxesCPlus.git /home/ubuntu/code/boxes/boxesCPlus
git clone https://github.com/PaulNovack/boxesReact.git /home/ubuntu/code/boxes/boxesReact
git clone https://github.com/PaulNovack/served.git /home/ubuntu/code/served
cd /home/ubuntu/code/served
mkdir build
cd build
cmake ../served && make
sudo cp -r /home/ubuntu/code/served/src/served /usr/local/include/served
git clone https://github.com/mysql/mysql-connector-cpp.git /home/ubuntu/code/mysql-connector-cpp
sudo mkdir /usr/local/include/mysql-connector-c++-8.0.29-src
sudo cp -r /home/ubuntu/code/mysql-connector-cpp/include /usr/local/include/mysql-connector-c++-8.0.29-src/include
sudo apt clean -y
sudo apt update -y
sudo apt upgrade -y
sudo cp /home/ubuntu/code/boxes/boxesCPlus/dist/Debug/GNU-Linux/libserved.so /usr/lib/libserved.so
sudo cp /home/ubuntu/code/boxes/boxesCPlus/dist/Debug/GNU-Linux/libmysqlcppconn8.so /usr/lib/libmysqlcppconn8.so
sudo ldconfig
cd /home/ubuntu/code/boxes/boxesCPlus
make
cd /home/ubuntu/code/boxes/boxesReact
curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs -y
sudo npm install -g npm@latest -y
npm update
npm run build > /dev/null 2>&1
sudo /home/ubuntu/code/boxes/boxesCPlus/dist/Debug/GNU-Linux/boxescplus </dev/null &>/dev/null &




