#!/usr/bin/env zsh
TDS=2pjCPLD8wpo1USrvCxmppiH6hbJo3yNypiQpDWayjrUg
keypair='usb://ledger?key=0'
vali=6hZL2FZim27WkQccMfygvvXH2eow5u3wR6XUJHbMoeWP

function merge {
  solana merge-stake "$1" "$2" -k "$keypair"
}

function psol { # Format lamports into a SOL string.
  printf "%'6d.%09d SOL" $((${1}/1000000000)) $((${1}%1000000000))
}

declare -A epacc # Associative array mapping activationEpoch to stake account index
STK=`solana stakes --withdraw-authority $TDS --output json`
num=`jq ". | length" <<<"""$STK"""`
echo "Found ${num} stake accounts."
last=$((${num}-1))
stdone=0
stnew=0
for i in {0..${last}}; do
  acc=`jq ".[${i}]" <<<"""$STK"""`
  stkacc=`jq -r ".stakePubkey" <<<"""$acc"""`
  if jq -e ".delegatedVoteAccountAddress" <<<"""$acc""" >/dev/null; then
    dstk=`jq ".delegatedStake" <<<"""$acc"""`
    epoch=`jq ".activationEpoch" <<<"""$acc"""`
    echo "Found $(psol ${dstk}) in delegated stake account ${stkacc}, actEpoch ${epoch}."
    stdone=$((${stdone}+${dstk}))
    if [[ -v "epacc[$epoch]" ]]; then
      echo "Merging with previous account."
      merge "${stkacc}" "$epacc[$epoch]"
    fi
    epacc[$epoch]=${stkacc}
  else
    bal=`jq ".accountBalance" <<<"""$acc"""`
    echo "Found $(psol ${bal}) in non-delegated stake account ${stkacc}."
    stnew=$((${stnew}+${bal}))
    if [[ -v "epacc[none]" ]]; then
      echo "Merging with previous account."
      merge "${stkacc}" "$epacc[none]"
    fi
    epacc[none]=${stkacc}
  fi
done
echo "  Already delegated: $(psol ${stdone})"
echo "  Not yet delegated: $(psol ${stnew})"
echo "------------------------------------------"
echo "Total stake balance: $(psol $((${stdone}+${stnew})))"
