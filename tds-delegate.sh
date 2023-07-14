#!/usr/bin/env zsh
TDS=2pjCPLD8wpo1USrvCxmppiH6hbJo3yNypiQpDWayjrUg
vali=6hZL2FZim27WkQccMfygvvXH2eow5u3wR6XUJHbMoeWP
keypair='usb://ledger?key=0'

function psol { # Format lamports into a SOL string.
  printf "%'6d.%09d SOL" $((${1}/1000000000)) $((${1}%1000000000))
}

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
  else
    bal=`jq ".accountBalance" <<<"""$acc"""`
    echo "Found $(psol ${bal}) in non-delegated stake account ${stkacc}, delegating."
    solana delegate-stake "${stkacc}" "${vali}" --stake-authority "${keypair}"
    stnew=$((${stnew}+${bal}))
  fi
done
echo "Previously delegated: $(psol ${stdone})"
echo "     Newly delegated: $(psol ${stnew})"
echo "------------------------------------------"
echo "     Total delegated: $(psol $((${stdone}+${stnew})))"
