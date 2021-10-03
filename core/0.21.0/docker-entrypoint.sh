#!/bin/bash
set -e

if [[ "$1" == "bitcoin-cli" || "$1" == "bitcoin-tx" || "$1" == "bitcoind" || "$1" == "test_bitcoin" ]]; then
	mkdir -p "$BITCOIN_DATA"

	CONFIG_PREFIX=""
	if [[ "${BITCOIN_NETWORK}" == "regtest" ]]; then
		CONFIG_PREFIX=$'regtest=1\n[regtest]'
	elif [[ "${BITCOIN_NETWORK}" == "testnet" ]]; then
		CONFIG_PREFIX=$'testnet=1\n[test]'
	elif [[ "${BITCOIN_NETWORK}" == "mainnet" ]]; then
		CONFIG_PREFIX=$'mainnet=1\n[main]'
	else 
		BITCOIN_NETWORK=""
	fi

	if [[ "$BITCOIN_WALLETDIR" ]] && [[ "$BITCOIN_NETWORK" ]]; then
		NL=$'\n'
		WALLETDIR="$BITCOIN_WALLETDIR/${BITCOIN_NETWORK}"
		mkdir -p "$WALLETDIR"	
		chown -R bitcoin:bitcoin "$WALLETDIR"
		CONFIG_PREFIX="${CONFIG_PREFIX}${NL}walletdir=${WALLETDIR}${NL}"
	fi
	
	cat <<-EOF > "$BITCOIN_DATA/bitcoin.conf"
	${CONFIG_PREFIX}
	printtoconsole=1
	rpcallowip=::/0
	rpcbind=0.0.0.0:8332
	${BITCOIN_EXTRA_ARGS}
	EOF
	chown bitcoin:bitcoin "$BITCOIN_DATA/bitcoin.conf"

	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R bitcoin "$BITCOIN_DATA"
	ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin
	chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin

	exec gosu bitcoin "$@"
else
	exec "$@"
fi
