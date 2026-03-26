FROM postgres:18-alpine3.23

# Création du dossier et attribution des droits durant le build
RUN mkdir -p /var/log/postgresql && \
    chown -R postgres:postgres /var/log/postgresql && \
    chmod -R 700 /var/log/postgresql