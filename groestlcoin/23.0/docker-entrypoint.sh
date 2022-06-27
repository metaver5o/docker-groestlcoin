#!/bin/bash
set -e

if [[ "$1" == "groestlcoin-cli" || "$1" == "groestlcoin-tx" || "$1" == "groestlcoind" || "$1" == "test_groestlcoin" ]]; then
	mkdir -p "$GROESTLCOIN_DATA"

	CONFIG_PREFIX=""
	if [[ "${GROESTLCOIN_NETWORK}" == "regtest" ]]; then
		CONFIG_PREFIX=$'regtest=1\n[regtest]'
	elif [[ "${GROESTLCOIN_NETWORK}" == "testnet" ]]; then
		CONFIG_PREFIX=$'testnet=1\n[test]'
	elif [[ "${GROESTLCOIN_NETWORK}" == "mainnet" ]]; then
		CONFIG_PREFIX=$'mainnet=1\n[main]'
	else
		GROESTLCOIN_NETWORK=""
	fi

	if [[ "$GROESTLCOIN_WALLETDIR" ]] && [[ "$GROESTLCOIN_NETWORK" ]]; then
		NL=$'\n'
		WALLETDIR="$GROESTLCOIN_WALLETDIR/${GROESTLCOIN_NETWORK}"
		WALLETFILE="${WALLETDIR}/wallet.dat"
		mkdir -p "$WALLETDIR"
		chown -R groestlcoin:groestlcoin "$WALLETDIR"
		CONFIG_PREFIX="${CONFIG_PREFIX}${NL}walletdir=${WALLETDIR}${NL}"
		if ! [[ -f "${WALLETFILE}" ]]; then
		  echo "The wallet does not exists, creating it at ${WALLETDIR}..."
		  gosu groestlcoin groestlcoin-wallet "-datadir=${WALLETDIR}" "-wallet=" create
		fi
	fi

	cat <<-EOF > "$GROESTLCOIN_DATA/groestlcoin.conf"
	${CONFIG_PREFIX}
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
