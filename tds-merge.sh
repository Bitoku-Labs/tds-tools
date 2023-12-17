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

function expiry { # Format unixTimestamp as human-readable
  date -Idate -r "${1}"
}

declare -A expacc # Associative array mapping unixTimestamp (of lockup expiry)  to stake account index
STK=`solana stakes --withdraw-authority $TDS --output json`
num=`jq ". | length" <<<"""$STK"""`
echo "Found ${num} stake accounts."
last=${num}
stdone=0
stnew=0
for i in {1..${last}}; do
  a[$i]=`jq ".[$((i-1))]" <<<"""$STK"""`
  sacc=`jq ".[$((i-1))]" <<<"""$STK"""`
  e[$i]=`jq ".unixTimestamp" <<<"""$sacc"""`" $i"
done
se=(${(n)e})
for i in {1..${last}}; do
  idx=$se[$i]
  elems=(${(@s/ /)idx})
  accidx=$elems[2]
  acc=$a[$accidx]
  stkacc=`jq -r ".stakePubkey" <<<"""$acc"""`
  exp=`jq ".unixTimestamp" <<<"""$acc"""`
  if jq -e ".delegatedVoteAccountAddress" <<<"""$acc""" >/dev/null; then
    dstk=`jq ".delegatedStake" <<<"""$acc"""`
    epoch=`jq ".activationEpoch" <<<"""$acc"""`
    echo "$(psol ${dstk}) in ${stkacc}, actEpoch ${epoch}, lockExp $(expiry ${exp})."
    stdone=$((${stdone}+${dstk}))
  else
    bal=`jq ".accountBalance" <<<"""$acc"""`
    echo "(psol ${bal}) non-deleg in ${stkacc}, lockExp $(expiry ${exp})."
    stnew=$((${stnew}+${bal}))
  fi
  if [[ -v "expacc[$exp]" ]]; then
    echo "Merging with previous account."
    merge "${stkacc}" "$expacc[$exp]"
  fi
  expacc[$exp]=${stkacc}
done
echo "  Already delegated: $(psol ${stdone})"
echo "  Not yet delegated: $(psol ${stnew})"
echo "------------------------------------------"
echo "Total stake balance: $(psol $((${stdone}+${stnew})))"
