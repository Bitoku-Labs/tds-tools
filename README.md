# TDS Tools

With Solana's TDS (Tour de Sun '22), you will get sent locked SOL in stake accounts each month.
Sadly, most wallets don't support working with locked SOL (yet), so it's best to use the CLI
to manage and stake the received rewards.

The script requires `zsh` being installed.

Adapt the script to your needs by adapting the first three lines in the tds.sh script,
to set your validator's vote account address (to stake your locked SOL to),
the keypair for your vote account, and your TDS account address.

```
# The wallet address you use for TDS
TDS=2pjCPLD8wpo1USrvCxmppiH6hbJo3yNypiQpDWayjrUg

# The keypair for your TDS acount. Can be the filename of a json file, or something like 'usb://ledger?key=0'
keypair='usb://ledger?key=0'

# The vote account address of the validator to delegate to
vali=6hZL2FZim27WkQccMfygvvXH2eow5u3wR6XUJHbMoeWP
```

## tds.sh

Lists all your stake accounts, whith amounts and lockup expiry, sorted by lockup expiry.

### -d option

Will delegate any undelegated stake accounts to your validator.

### - m option

Will merge stake accoumnts with equal lockup expiry, to give you a neater overview of things.

## Thank you

If you like our tool, please consider staking your SOL to the Bitoku Validator.
