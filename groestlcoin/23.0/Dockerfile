FROM debian:stretch-slim

RUN groupadd -r groestlcoin && useradd -r -m -g groestlcoin groestlcoin

COPY sources.list /etc/apt/
RUN set -ex \
	&& apt update \
	&& apt install -y -qq --no-install-recommends ca-certificates dirmngr gosu wget \
	&& rm -rf /var/lib/apt/lists/*

ENV GROESTLCOIN_VERSION 23.0
ENV GROESTLCOIN_TARBALL groestlcoin-${GROESTLCOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV GROESTLCOIN_URL https://github.com/Groestlcoin/groestlcoin/releases/download/v$GROESTLCOIN_VERSION/$GROESTLCOIN_TARBALL
ENV GROESTLCOIN_SHA256 46ab078422d0d2aaf5b89ac9603cb61a6ebf6c26a73b9440365a4df5f9bce7de
ENV GROESTLCOIN_ASC_URL https://github.com/Groestlcoin/groestlcoin/releases/download/v$GROESTLCOIN_VERSION/SHA256SUMS.asc
ENV GROESTLCOIN_SHASUM_URL https://github.com/Groestlcoin/groestlcoin/releases/download/v$GROESTLCOIN_VERSION/SHA256SUMS

# install groestlcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO $GROESTLCOIN_TARBALL "$GROESTLCOIN_URL" \
	&& echo "$GROESTLCOIN_SHA256 $GROESTLCOIN_TARBALL" | sha256sum -c - \
	&& wget -qO SHA256SUMS.asc "$GROESTLCOIN_ASC_URL" \
	&& wget -qO SHA256SUMS "$GROESTLCOIN_SHASUM_URL" \
	&& sha256sum --ignore-missing --check SHA256SUMS \
	&& tar -xzvf $GROESTLCOIN_TARBALL -C /usr/local/ --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

# create data directory
ENV GROESTLCOIN_DATA /data
RUN mkdir "$GROESTLCOIN_DATA" \
	&& chown -R groestlcoin:groestlcoin "$GROESTLCOIN_DATA" \
	&& ln -sfn "$GROESTLCOIN_DATA" /home/groestlcoin/.groestlcoin \
	&& chown -h groestlcoin:groestlcoin /home/groestlcoin/.groestlcoin
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 1331 1441 17777 17766 18888 18443
CMD ["groestlcoind"]