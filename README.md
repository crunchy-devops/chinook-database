# Chinook Database – PostgreSQL package + Monitoring

This repository provides a ready‑to‑use PostgreSQL instance for the Chinook sample database, **installed from AlmaLinux packages (PostgreSQL 18)**. It also includes SQL scripts in `massive_data` to load a large dataset into the database, and a `docker-compose.yml` stack for **Grafana/Prometheus/Loki monitoring only** (no PostgreSQL container).

This README focuses on:

- **Installing Docker on AlmaLinux** using the steps from `ALMA.md` (for the monitoring stack).
- **Installing and configuring PostgreSQL 18 from packages** on AlmaLinux (port `32420`, logs with rotation).
- **Starting the monitoring stack** (Grafana/Prometheus/Alertmanager/Loki/Promtail, etc.) with `docker-compose.yml`.
- **Loading massive data** into the `chinook` database using the SQL scripts in `massive_data`.

---

## 1. Prerequisites

- **Git** to clone this repository.
- **Docker Engine** and **Docker Compose plugin**.

On Windows or macOS you can use **Docker Desktop**.
On AlmaLinux, follow the steps below.

---

## 2. Install Docker on AlmaLinux

The following commands are based on `ALMA.md` and should be run as a user with `sudo` privileges.

```bash
# Update the system
sudo dnf -y --refresh update
sudo dnf upgrade

# (Optional) Disable SELinux permanently – requires reboot after editing
getenforce
sudo vi /etc/selinux/config   # set SELINUX=disabled

# Install common tools and Docker repository
sudo dnf -y install yum-utils git wget curl epel-release
sudo dnf install -y htop iotop iftop
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker Engine and docker compose plugin
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Enable and start Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

# Verify Docker installation
docker --version

# Allow your user to run docker without sudo (log out and back in afterwards)
sudo usermod -aG docker $USER
id
docker ps
```

> **Note**: After adding your user to the `docker` group, you must log out and log back in (or reboot) for the change to take effect.

### Optional: Portainer (Docker UI)

`ALMA.md` also documents how to run Portainer for managing Docker via a web UI:

```bash
docker volume create portainer_data
docker run -d -p 32125:8000 -p 32126:9443 --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce:2.20.2-alpine
```

---

## 3. Install and Configure PostgreSQL 18 from Packages

PostgreSQL is now installed **directly on AlmaLinux via packages**, not via Docker.

Follow the steps from `ALMA.md` (section *Start PostgreSQL from package*):

```bash
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

Then configure PostgreSQL (port and access) as described in `ALMA.md`:

```bash
sudo vi /var/lib/pgsql/18/data/postgresql.conf
## change listen_addresses and port
listen_addresses = '*'
port = 32420

sudo vi /var/lib/pgsql/18/data/pg_hba.conf
## Example: allow password auth from your network
host all all 0.0.0.0/0  scram-sha-256

## restart postgresql
sudo systemctl restart postgresql-18
sudo netstat -plnt | grep postgres
```

> **Logs & rotation**: PostgreSQL writes its logs according to your `postgresql.conf` configuration. On AlmaLinux, you can combine this with system log rotation (e.g. `logrotate`) to ensure that PostgreSQL logs are **rotated** and do not grow indefinitely.

### 3.1. Connect to PostgreSQL

From the AlmaLinux host or another machine with network access:

```bash
psql -h <hostname-or-ip> -p 32420 -U chinook -d chinook
```

Adapt the `chinook` user, database name and password to your actual configuration.

---

## 4. Load Massive Data into Chinook

The directory `massive_data` contains SQL scripts to insert a large dataset into the `chinook` database. The scripts are designed to be run **in order**.

`massive_data/` contains (among others):

- `00_master_massive_data_generation.sql`
- `00_setup_base_data.sql`
- `01_massive_artists_albums.sql`
- `02_massive_tracks.sql`
- `03_massive_customers_employees.sql`
- `04_massive_invoices.sql`
- `05_massive_playlists.sql`

Before running these scripts, ensure:

- The PostgreSQL service `postgresql-18` is **running** on port `32420`.
- The `chinook` database **schema already exists** (created using the standard Chinook schema scripts).

### 4.1. Run the master script (recommended)

The simplest approach is to run the master script, which orchestrates the other scripts:

```bash
psql -h localhost -p 32420 -U chinook -d chinook -f massive_data/00_master_massive_data_generation.sql
```

You will be prompted for the `chinook` user password.

### 4.2. Run scripts individually (alternative)

If you prefer to run the scripts one by one, execute them in the following order:

```bash
psql -h localhost -p 32420 -U chinook -d chinook -f massive_data/00_setup_base_data.sql
psql -h localhost -p 32420 -U chinook -d chinook -f massive_data/01_massive_artists_albums.sql
psql -h localhost -p 32420 -U chinook -d chinook -f massive_data/02_massive_tracks.sql
psql -h localhost -p 32420 -U chinook -d chinook -f massive_data/03_massive_customers_employees.sql
psql -h localhost -p 32420 -U chinook -d chinook -f massive_data/04_massive_invoices.sql
psql -h localhost -p 32420 -U chinook -d chinook -f massive_data/05_massive_playlists.sql
```

After running these scripts, the `chinook` database will be populated with a large dataset suitable for performance and load testing.

---

## 5. Stopping and Cleaning Up

### 5.1. Stop containers

From the repository root:

```bash
docker compose down
```

This stops and removes the **monitoring containers** (Grafana, Prometheus, Alertmanager, Loki, Promtail, Mailpit, etc.) but **keeps their data volumes**.

### 5.2. Remove data volume (optional)

If you want to remove all persisted data and start fresh:

```bash
docker compose down -v
```

This will delete the monitoring stack volumes and all data stored in them (Grafana dashboards, Prometheus TSDB, Loki logs index, etc.).

---

## 6. Summary

- **Install Docker** (see section 2 for AlmaLinux steps).
- **Install and configure PostgreSQL 18 from packages** on AlmaLinux (port `32420`, logs with rotation).
- **Start the monitoring stack** with `docker compose up -d` using `docker-compose.yml` (Grafana, Prometheus, Loki, etc.).
- **Connect to the database** on `localhost:32420` (or the configured host/port) and **load data** using the SQL scripts in `massive_data`, preferably via `00_master_massive_data_generation.sql`.

You now have a PostgreSQL 18 Chinook database installed from packages, with massive sample data and a Docker-based monitoring stack ready for experiments and testing.
