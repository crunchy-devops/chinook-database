# Chinook Database – Docker Quickstart

This repository provides a ready‑to‑use PostgreSQL instance for the Chinook sample database, using Docker and `docker-compose`. It also includes SQL scripts in `massive_data` to load a large dataset into the database.

This README focuses on:

- **Installing Docker on AlmaLinux** using the steps from `ALMA.md`.
- **Starting the PostgreSQL container** with `docker-compose.yml`.
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

## 3. Start PostgreSQL with docker-compose
### 3.1 Pre-requisites



The file `docker-compose.yml` defines a PostgreSQL container with the `chinook` database preconfigured.

Key settings from `docker-compose.yml`:

- **Image**: `postgres:18.3-alpine3.23`
- **Container name**: `postgres-18`
- **Port mapping**: `32200:5432` (host:container)
- **Database name**: `chinook`
- **User**: `chinook`
- **Password**: `password_772`

### 3.1. Start the container

From the root of this repository:

```bash
docker compose up -d
```

This will:

- Create a named volume `postgres-chinook-data`.
- Start the `postgres-18` container in the background.

### 3.2. Verify the container

```bash
docker ps
```

```bash
docker cp massive_data/00_master_massive_data_generation.sql postgres-18:/tmp
docker cp massive_data postgres-18:/tmp
# inside the container
su postgres
cd /tmp
psql -U chinook -d chinook -f /tmp/00_master_massive_data_generation.sql

```


You should see a running container named `postgres-18` with port `32200` exposed.

### 3.3. Connect to PostgreSQL

Using `psql` from your host:

```bash
psql -h localhost -p 32200 -U chinook -d chinook
```

When prompted for a password, use:

- **Password**: `password_772`

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

- The `postgres-18` container is **running**.
- The `chinook` database **schema already exists** (created using the standard Chinook schema scripts).

### 4.1. Run the master script (recommended)

The simplest approach is to run the master script, which orchestrates the other scripts:

```bash
psql -h localhost -p 32200 -U chinook -d chinook -f massive_data/00_master_massive_data_generation.sql
```

You will be prompted for the `chinook` user password:

- **Password**: `password_772`

### 4.2. Run scripts individually (alternative)

If you prefer to run the scripts one by one, execute them in the following order:

```bash
psql -h localhost -p 32200 -U chinook -d chinook -f massive_data/00_setup_base_data.sql
psql -h localhost -p 32200 -U chinook -d chinook -f massive_data/01_massive_artists_albums.sql
psql -h localhost -p 32200 -U chinook -d chinook -f massive_data/02_massive_tracks.sql
psql -h localhost -p 32200 -U chinook -d chinook -f massive_data/03_massive_customers_employees.sql
psql -h localhost -p 32200 -U chinook -d chinook -f massive_data/04_massive_invoices.sql
psql -h localhost -p 32200 -U chinook -d chinook -f massive_data/05_massive_playlists.sql
```

After running these scripts, the `chinook` database will be populated with a large dataset suitable for performance and load testing.

---

## 5. Stopping and Cleaning Up

### 5.1. Stop containers

From the repository root:

```bash
docker compose down
```

This stops and removes the containers but **keeps the data volume** `postgres-chinook-data`.

### 5.2. Remove data volume (optional)

If you want to remove all persisted data and start fresh:

```bash
docker compose down -v
```

This will delete the `postgres-chinook-data` volume and all data stored in it.

---

## 6. Summary

- **Install Docker** (see section 2 for AlmaLinux steps).
- **Start PostgreSQL** with `docker compose up -d` using `docker-compose.yml`.
- **Connect to the database** on `localhost:32200` using `chinook/password_772`.
- **Load data** using the SQL scripts in `massive_data`, preferably via `00_master_massive_data_generation.sql`.

You now have a Dockerized Chinook PostgreSQL database with massive sample data ready for experiments and testing.
