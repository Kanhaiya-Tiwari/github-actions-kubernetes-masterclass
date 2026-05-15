# Using MySQL 8.0 as the base image
FROM mysql:8.0

# Copy the initialization script to the official entrypoint directory
# This script will be executed when the container starts for the first time
COPY init.sql /docker-entrypoint-initdb.d/

# Environment variables (usually passed via docker-compose or k8s)
# But we can set defaults here if needed
ENV MYSQL_DATABASE=skillpulse
ENV MYSQL_ROOT_PASSWORD=rootpassword

EXPOSE 3306
