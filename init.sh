sudo apt install certbot -y
if [ -z "$FW_Key" ]
then
    # Example using encryption do deploy sensitive files
    # Key mgmt exercise left to reader
    echo "Please set decryption key to initialize "
    echo "Will continue installation without decrypting in 5 seconds"
    sleep 5
else
    echo "$FW_Key" > ./mcrypt.install
    mdecrypt -f ./mcrypt.install daanmatch-certs.tgz.nc
    shred -u ./mcrypt.install
fi

cat<<EOM
# I like to install GH cmnd line for test servers
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update -y
sudo apt install gh -y
gh auth login
git clone https://github.com/DaanMatch/FieldWorker
EOM
#  Install software
sudo apt update -y
sudo apt install git python3 python3-pip python3-venv -y
sudo apt-get install software-properties-common -y
sudo apt-get install gpg mcrypt -y
sudo apt-get install nginx authbind certbot -y
sudo apt install sqlite -y
sudo apt install net-tools -y
sudo apt install php php-cli php-fpm php-json -y
sudo apt install php-pdo php-mysql php-zip php-gd  php-mbstring php-curl php-xml php-pear php-bcmath -y
# Improve SSL security Should not need both
if [ ! -e /etc/nginx/dhparam.pem ]; then
  sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096 > /dev/null &
fi

# Setup Python Env

python3 -m venv ./venv
source ./venv/bin/activate
pip install -r requirements.txt
#todo: Evaluate https://www.e-tinkers.com/2018/08/how-to-properly-host-flask-application-with-nginx-and-guincorn/
# Setup  Server Env
DOMAIN=daanmatch.com
WILDCARD="*.${DOMAIN}"
sudo certbot -d $DOMAIN -d "${WILDCARD}" --manual --preferred-challenges dns certonly
sudo crontab -u root certbotcrontab

sudo cp reverse-proxy.conf /etc/nginx/sites-enabled
# sudo rm /etc/nginx/sites-available/default
#todo: modify fieldworkerprod.service to sed for USER
servicefile=/etc/systemd/system/fieldworkerprod.service
sudo cp "${USER}"-fieldworkerprod.service $servicefile
sudo chmod 664 $servicefile
nohup sudo apt upgrade -y &
sudo rsync -Pav . /var/www/flask
sudo systemctl restart fieldworkerprod; sudo systemctl restart nginx
sudo systemctl status fieldworkerprod; sudo systemctl status nginx;