#!/bin/sh -le

GITHASH_STR="<b>Commits used to build this release:</b><br>"

append_githash_info () {
    GITHASH=$(git rev-parse HEAD)
    GITHASH_SHORT=$(echo "$GITHASH" | cut -c 1-7)
    GITNAME=$(basename "$(git rev-parse --show-toplevel)")
    [ -z "$1" ] || GITNAME=$1
    GITURL=$(git config --get remote.origin.url)
    GITHASH_STR="$GITHASH_STR $GITNAME: [$GITHASH_SHORT]($GITURL/commit/$GITHASH)<br>"
}

git config --global --add safe.directory '*'
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git fetch --unshallow


cd miryoku_qmk || exit 1
git config --global --add safe.directory '*'
make git-submodule

append_githash_info

qmk setup -y

# Compile upstream boards first
for t in keebio/iris/rev7 ferris/sweep;
    do echo "Building QMK for $t";
    qmk compile -j 2 -kb $t -km manna-harbour_miryoku -e MIRYOKU_ALPHAS=COLEMAKDH
done

echo "commits=$GITHASH_STR" >> "$GITHUB_OUTPUT" || true

# If we made it this far without any hex or uf2 files, there's a problem
ls *.hex
