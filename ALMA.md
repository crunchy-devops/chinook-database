# AlmaLinux


## 1. Install Docker on AlmaLinux
```shell
sudo dnf -y --refresh update
sudo dnf upgrade
getenforce
sudo vi /etc/selinux/config  # set SELINUX=disabled
#sudo timedatectl set-timezone Etc/UTC
sudo dnf -y install yum-utils git wget curl epel-release
sudo dnf install -y htop iotop iftop
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
docker --version
sudo usermod -aG docker $USER
# restart pycharm
id
docker ps
```
## docker compose
```shell
sudo curl -L "https://github.com/docker/compose/releases/download/v5.0.1/docker-compose-linux-x86_64"  -o  /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

## Portainer
```shell
docker volume create portainer_data
docker run -d -p 32125:8000 -p 32126:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock \
-v portainer_data:/data portainer/portainer-ce:2.20.2-alpine
```

## 2. Start PostgreSQL from package
```shell
cat /etc/os-release && psql --version
sudo dnf update
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql
sudo dnf install -y postgresql18-server postgresql18
sudo /usr/pgsql-18/bin/postgresql-18-setup initdb
sudo systemctl start postgresql-18
sudo systemctl enable postgresql-18
sudo systemctl status postgresql-18
```
 ## Configuration PostgreSQL
```shell
sudo vi /var/lib/pgsql/18/data/postgresql.conf
## change listen_addresse and port
listen_addresses = '*'
port = 32420
sudo vi /var/lib/pgsql/18/data/pg_hba.conf
## change host all all all md5
host all all 0.0.0.0/0  scram-sha-256
## restart postgresql
sudo systemctl restart postgresql-18
sudo netstat -plnt | grep postgres
```