FROM debian:stretch-slim

LABEL maintainer="OBiBa <dev@obiba.org>"

# grab gosu for easy step-down from root
# see https://github.com/tianon/gosu/blob/master/INSTALL.md
ENV GOSU_VERSION 1.10
ENV GOSU_KEY B42F6819007F00F88E364FD4036A9C25BF357DD4

RUN set -ex; \
	\
	fetchDeps=' \
		ca-certificates \
    gnupg2 \
    dirmngr \
		wget \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
  # verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
  gpg --keyserver pgp.mit.edu --recv-keys "$GOSU_KEY" || \
  gpg --keyserver keyserver.pgp.com --recv-keys "$GOSU_KEY" || \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GOSU_KEY"; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
  # verify that the binary works
	gosu nobody true; \
	\
	apt-get purge -y --auto-remove $fetchDeps