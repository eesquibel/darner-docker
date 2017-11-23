FROM debian:stretch as build

RUN	apt-get update && \
	apt-get install --no-install-recommends --yes \
		wget \
		ca-certificates \
		build-essential \
		cmake \
		libboost-thread-dev \
		libboost-system-dev \
		libboost-program-options-dev \
		libboost-filesystem-dev \
		libboost-test-dev \
		libsnappy-dev \
		libleveldb-dev

WORKDIR /tmp
RUN	wget --no-verbose --output-document=- https://github.com/eesquibel/darner/archive/master.tar.gz | tar xzv

WORKDIR darner-master
RUN	cmake . && make && make install

RUN ./test

FROM debian:stretch

RUN	apt-get update && \
	apt-get install -y \
		libboost-thread1.62.0 \
		libboost-system1.62.0 \
		libboost-program-options1.62.0 \
		libboost-filesystem1.62.0 \
		libsnappy1v5 \
		libleveldb1v5

COPY --from=build /usr/local/bin/darner /usr/local/bin/darner

RUN mkdir --parents /var/spool/darner

VOLUME ["/var/spool/darner"]
EXPOSE 22133

ENTRYPOINT ["/usr/local/bin/darner"]
CMD ["-d", "/var/spool/darner/"]