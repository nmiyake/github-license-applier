#!/bin/bash
# Downloads the Apache license and verifies that the content is correct.
# Supports Apache license provided by default for GitHub.com repositories
# and the license provided directly by the Apache foundation (they differ
# slightly in whitespace and license application tokens). Applies the GitHub.com
# version by default -- to apply the Apache Foundation version instead, comment
# out the GitHub.com code and comment in the Apache Foundation code.
set -euo pipefail

function compute_sha256 {
    local file=$1
    if command -v openssl >/dev/null 2>&1; then
        # print SHA-256 hash using openssl
        openssl dgst -sha256 "$file" | sed -E 's/SHA256\(.*\)= //'
    elif command -v shasum >/dev/null 2>&1; then
        # Darwin systems ship with "shasum" utility
        shasum -a 256 "$file" | sed -E 's/[[:space:]]+.+//'
    elif command -v sha256sum >/dev/null 2>&1; then
        # Most Linux systems ship with sha256sum utility
        sha256sum "$file" | sed -E 's/[[:space:]]+.+//'
    else
        echo "Could not find program to calculate SHA-256 checksum for file"
        exit 1
    fi
}

COMMIT=false
while getopts "c" opt; do
case $opt in
    c)
        COMMIT=true
        ;;
    \?)
        exit 1
        ;;
  esac
done

shift $((OPTIND-1))

if [ $# -eq 0 ]; then
    echo "License type was not supplied"
    exit 1
fi

KEY=$1
NAME=
KNOWN_SHA256=

case $KEY in
agpl-3.0|agpl)
    KEY=agpl-3.0
    NAME="AGPL 3.0"
    KNOWN_SHA256=76a97c878c9c7a8321bb395c2b44d3fe2f8d81314d219b20138ed0e2dddd5182
    ;;
apache-2.0|apache)
    KEY=apache-2.0
    NAME="Apache 2.0"
    KNOWN_SHA256=b40930bbcf80744c86c46a12bc9da056641d722716c378f5659b9e555ef833e1
    ;;
bsd-2-clause|bsd-2)
    KEY=bsd-2-clause
    NAME="BSD 2-Clause"
    KNOWN_SHA256=bc6da8e95c49652738b398592f5a89aaf1f168b478184d40b8177fdb49593ff5
    ;;
bsd-3-clause|bsd-3)
    KEY=bsd-3-clause
    NAME="BSD 3-Clause"
    KNOWN_SHA256=c6bce241128aaf54728d86e9034e410385fda959073c467f377c4f4fa4253f69
    ;;
gpl-3.0|gpl)
    KEY=gpl-3.0
    NAME="GPL 3.0"
    KNOWN_SHA256=589ed823e9a84c56feb95ac58e7cf384626b9cbf4fda2a907bc36e103de1bad2
    ;;
lgpl-3.0|lgpl)
    KEY=lgpl-3.0
    NAME="LGPL 3.0"
    KNOWN_SHA256=38e0b9de817f645c4bec37c0d4a3e58baecccb040f5718dc069a72c7385a0bed
    ;;
mit)
    NAME="MIT"
    KNOWN_SHA256=002c2696d92b5c8cf956c11072baa58eaf9f6ade995c031ea635c6a1ee342ad1
    ;;
mpl-2.0|mpl)
    NAME="MPL 2.0"
    KNOWN_SHA256=1f256ecad192880510e84ad60474eab7589218784b9a50bc7ceee34c2b91f1d5
    ;;
unlicense)
    NAME="The Unlicense"
    KNOWN_SHA256=88d9b4eb60579c191ec391ca04c16130572d7eedc4a86daa58bf28c6e14c9bcd
    ;;
*)
    # unknown option
    echo "Unknown license type: $KEY"
    exit 1
    ;;
esac

# LICENSE file provided by GitHub.com for new repositories
URL=https://api.github.com/licenses/$KEY
echo "$(curl "$URL" -H "Accept: application/vnd.github.drax-preview+json" | jq -r '.body')" > LICENSE

FILE_SHA256=$(compute_sha256 LICENSE)
if [ "$KNOWN_SHA256" != "$FILE_SHA256" ]; then
    echo "SHA-256 sum of LICENSE does not match expected value for file at $URL"
    echo "Expected: $KNOWN_SHA256"
    echo "Was:      $FILE_SHA256"
    exit 1
fi

if [ "$COMMIT" == true ] && [[ ! -z $(git status --porcelain) ]]; then
    git add LICENSE
    git commit -m "Update LICENSE" -m "Use default $NAME LICENSE file provided by GitHub.com"
fi
