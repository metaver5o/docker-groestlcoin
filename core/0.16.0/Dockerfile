FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 0.16.0
ENV BITCOIN_TARBALL bitcoin-$BITCOIN_VERSION-x86_64-linux-gnu.tar.gz
ENV BITCOIN_URL https://bitcoincore.org/bin/bitcoin-core-$BITCOIN_VERSION/$BITCOIN_TARBALL
ENV BITCOIN_SHA256 e6322c69bcc974a29e6a715e0ecb8799d2d21691d683eeb8fef65fc5f6a66477
ENV BITCOIN_ASC_URL https://bitcoincore.org/bin/bitcoin-core-$BITCOIN_VERSION/SHA256SUMS.asc
# Added for transparency where the signing key comes from:
#  - 01EA5486DE18A882D4C2684590C8019E36C2E964 is Wladimir J. van der Laan's signing key
#  - it was mentioned already 2015 on bitcoin-dev Mailinglist in a (signed) message from
#    Wladimir J. van der Laan:
#    https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-June/009045.html
#  - it is mentioned on the bitcoincore download page: https://bitcoincore.org/en/download/
ENV BITCOIN_PGP_KEY 01EA5486DE18A882D4C2684590C8019E36C2E964

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO "$BITCOIN_TARBALL" "$BITCOIN_URL" \
	&& echo "$BITCOIN_SHA256 $BITCOIN_TARBALL" | sha256sum -c - \
	&& for server in $(shuf -e ha.pool.sks-keyservers.net \
                             hkp://p80.pool.sks-keyservers.net:80 \
                             keyserver.ubuntu.com \
                             hkp://keyserver.ubuntu.com:80 \
                             pgp.mit.edu) ; do \
         gpg --batch --keyserver "$server" --recv-keys "$BITCOIN_PGP_KEY" && break || : ; \
     done \
	&& wget -qO bitcoin.asc "$BITCOIN_ASC_URL" \
	&& sha256sum --ignore-missing --check bitcoin.asc \
	&& gpg --verify bitcoin.asc \
	&& tar -xzvf "$BITCOIN_TARBALL" -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /data
RUN mkdir "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333 18443 18444
CMD ["bitcoind"]
