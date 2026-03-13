# AlmaLinux

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

```shell
docker volume create portainer_data
docker run -d -p 32125:8000 -p 32126:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock \
-v portainer_data:/data portainer/portainer-ce:2.20.2-alpine
```