FROM postgres:18-alpine3.23 AS builder

# Install dependencies needed to build TimescaleDB against PostgreSQL 18
RUN apk add postgresql-dev \
    git \
    make \
    cmake \
    gcc \
    autoconf

# Fetch TimescaleDB from GitHub
WORKDIR /timescaledb
RUN git clone https://github.com/timescale/timescaledb .

# Optionally pin to a specific tag / version
RUN git checkout 2.26.2

# Configure and build TimescaleDB
RUN ./bootstrap -DREGRESS_CHECKS=OFF
RUN cd build && make -j"$(nproc)" && make install


FROM postgres:18-alpine3.23

# Copy compiled TimescaleDB shared libraries and extension files into the Postgres 18 image
COPY --from=builder /usr/local/lib/postgresql/*.so /usr/local/lib/postgresql/
COPY --from=builder /usr/local/share/postgresql/extension/*timescaledb* /usr/local/share/postgresql/extension/

# Création du dossier et attribution des droits durant le build
RUN mkdir -p /var/log/postgresql && \
    chown -R postgres:postgres /var/log/postgresql && \
    chmod -R 700 /var/log/postgresql