#!/usr/bin/env bash

KOOLBOX_ROOT_DIR=$(dirname $(dirname $(readlink -f ${BASH_SOURCE[0]})))

mkdir -p $KOOLBOX_ROOT_DIR/test/output


for tool in helm kubectl mark gh krew; do
    echo running scripts for $tool
    koolbox-install -t $tool -v -F -d >$KOOLBOX_ROOT_DIR/test/output/$tool-dry-run-full
    koolbox-install -t $tool -v -f >$KOOLBOX_ROOT_DIR/test/output/$tool-install
done

echo comparing output to expected
diff -r $KOOLBOX_ROOT_DIR/test/output/ $KOOLBOX_ROOT_DIR/test/expected
