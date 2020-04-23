#!/bin/sh

# PROVIDE: joinmarket
# REQUIRE: bitcoind tor
# KEYWORD: shutdown

. /etc/rc.subr

name="joinmarket"
rcvar="joinmarket_enable"

: ${joinmarket_enable:="no"}
: ${joinmarket_wallet:="wallet.jmdat"}
: ${joinmarket_bin_dir:="/usr/local/bin/${name}"}
: ${joinmarket_etc_dir:="/usr/local/etc/${name}"}

command="$joinmarket_bin_dir/jmvenv/bin/python"

procname="$command"
pidfile="/var/run/${name}.pid"
password="$(cat $joinmarket_etc_dir/.secrets)"

required_files="$joinmarket_etc_dir/wallets/$joinmarket_wallet $joinmarket_etc_dir/.secrets"

start_cmd="${name}_start"
stop_cmd="${name}_stop"

extra_commands="history wallet generate"
history_cmd="${name}_history"
wallet_cmd="${name}_wallet"
generate_cmd="${name}_generate"

joinmarket_wallet()
{
    echo -n $password | $command $joinmarket_bin_dir/scripts/wallet-tool.py --wallet-password-stdin --datadir=$joinmarket_etc_dir $joinmarket_wallet
}

joinmarket_history()
{
    echo -n $password | $command $joinmarket_bin_dir/scripts/wallet-tool.py --wallet-password-stdin --datadir=$joinmarket_etc_dir $joinmarket_wallet history
}

joinmarket_generate()
{
    $command $joinmarket_bin_dir/scripts/wallet-tool.py --datadir=$joinmarket_etc_dir --datadir=$joinmarket_etc_dir generate
}

joinmarket_start()
{
    echo -n $password | /usr/sbin/daemon -o $joinmarket_etc_dir/daemon.log -p $pidfile $command $joinmarket_bin_dir/scripts/yg-privacyenhanced.py --wallet-password-stdin --datadir=$joinmarket_etc_dir wallet.jmdat
}

joinmarket_stop()
{
    echo "Stopping joinmarket:"
    pid=$(check_pidfile "${pidfile}" "${procname}")
    if [ -z "${pid}" ]
    then
        echo "joinmarket is not running"
        return 1
    else
        kill ${pid}
    fi
}

load_rc_config ${name}
run_rc_command "$1"
