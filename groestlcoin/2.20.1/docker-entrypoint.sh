#!/bin/bash
set -e

if [[ "$1" == "groestlcoin-cli" || "$1" == "groestlcoin-tx" || "$1" == "groestlcoind" || "$1" == "test_groestlcoin" ]]; then
	mkdir -p "$GROESTLCOIN_DATA"

	cat <<-EOF > "$GROESTLCOIN_DATA/groestlcoin.conf"
	printtoconsole=1
	rpcallowip=::/0
	rpcbind=0.0.0.0:1441
	${GROESTLCOIN_EXTRA_ARGS}
	EOF
	chown groestlcoin:groestlcoin "$GROESTLCOIN_DATA/groestlcoin.conf"

	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R groestlcoin "$GROESTLCOIN_DATA"
	ln -sfn "$GROESTLCOIN_DATA" /home/groestlcoin/.groestlcoin
	chown -h groestlcoin:groestlcoin /home/groestlcoin/.groestlcoin

	exec gosu groestlcoin "$@"
else
	exec "$@"
fi
