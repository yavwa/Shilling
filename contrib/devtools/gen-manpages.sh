#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

SHILLINGCOIND=${SHILLINGCOIND:-$SRCDIR/shillingcoind}
SHILLINGCOINCLI=${SHILLINGCOINCLI:-$SRCDIR/shillingcoin-cli}
SHILLINGCOINTX=${SHILLINGCOINTX:-$SRCDIR/shillingcoin-tx}
SHILLINGCOINQT=${SHILLINGCOINQT:-$SRCDIR/qt/shillingcoin-qt}

[ ! -x $SHILLINGCOIND ] && echo "$SHILLINGCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
SHVER=($($SHILLINGCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$SHILLINGCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $SHILLINGCOIND $SHILLINGCOINCLI $SHILLINGCOINTX $SHILLINGCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${SHVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${SHVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
