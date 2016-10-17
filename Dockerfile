# Dockerfile for square/keywhiz
#
# Note: keep this in the root of the project next to
# the pom.xml to work correctly.
#
# Building (for H2 database):
#   docker build \
#       --rm --force-rm \
#       --build-arg PROFILE=h2 \
#       -t square/keywhiz .
#
# Building (for MySQL database):
#   docker build \
#       --rm --force-rm \
#       --build-arg PROFILE=mysql \
#       -t square/keywhiz .
#
# Basic usage:
#   docker run -e KEYWHIZ_CONFIG=/path/to/config [IMAGE] [COMMAND]
#
# If the KEYWHIZ_CONFIG environment variable is omitted, keywhiz
# will run with the default development config. If COMMAND is
# omitted, keywhiz will print a help message.
#
# *** Development ***
#   Create a persistent data volume:
#     docker volume create --name keywhiz-db-devel
#
#   Initialize the database, apply migrations, and add administrative user:
#     docker run square/keywhiz migrate
#     docker run -it square/keywhiz add-user
#
#   Finally, run the server with the default development config:
#     docker run -it -p 4444:4444 square/keywhiz server
#
#   Please note, the development config stores data (via H2) in
#   /tmp/h2_data by default and does not provide persistence.
#
#   For a production deployment, you'll probably want to setup your
#   own config to make sure you're not using development secrets.
#
# *** Production setup wizard ***
#   For production deployments, we have setup wizard that will initialize
#   a Keywhiz container for you and create a config based on a template.
#   The template can be found at docker/keywhiz-config.tpl in the source
#   repository if you want to do it yourself.
#
#   The wizard can be run using the "wizard" command, like so:
#       docker run -it \
#           -v keywhiz-data:/data \
#           -v keywhiz-secrets:/secrets \
#           square/keywhiz wizard
#
#   The /data and /secrets volumes will be used to store data. The 
#   default database will be H2. If you'd like to use MySQL, please
#   provide your own configuration. During the wizard setup, be
#   ready to provide a server certificate/private key for keywhiz.
#
# After keywhiz starts up, you can access the admin console by going
# to https://[DOCKER-MACHINE-IP]/ui in your browser. The default user
# in development is keywhizAdmin and the default password is adminPass.
#
# In production, the "add-user" command can be used to create an initial
# administrative user in an otherwise empty database.
#
FROM maven:3.3-jdk-8

ARG PROFILE=h2

WORKDIR /usr/src/app
ADD . /usr/src/app

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install gettext vim-common && \
    # Build with given profile
    mvn install -q -DskipTests=true -P $PROFILE && \
    # Add keywhiz user
    useradd -ms /bin/false keywhiz && \
    # Create dirs for volumes and dev database
    mkdir /data && \
    chown keywhiz:keywhiz /data && \
    mkdir /secrets && \
    chown keywhiz:keywhiz /secrets && \
    mkdir -p /tmp/h2_data && \
    chown keywhiz:keywhiz /tmp/h2_data && \
    # Delete maven dependencies to reduce build size
    rm -rf /root/m2

USER keywhiz

# Expose API port by default. Note that the admin console port
# is NOT exposed by default, can be exposed manually if desired.
EXPOSE 4444

VOLUME ["/data", "/secrets"]

ENTRYPOINT ["/usr/src/app/docker/entry.sh"]
