#!/bin/sh

set -e

# All directory variables relative to project root
MIXDIR=./dist/hpc
TIX=./test/testsuite.tix
HTMLDIR=./test/hpc

SUITE=./dist/build/testsuite/testsuite

cd test

if [ -z "$DEBUG" ]; then
    export DEBUG=snap-testsuite
fi

rm -f ../$TIX
rm -rf ../$HTMLDIR

mkdir -p ../$OUTDIR

if [ ! -f ../$SUITE ]; then
    cat <<EOF
Testsuite executable not found, please run:
    cabal configure
then
    cabal build
then
    cabal install --enable-tests
EOF
    exit;
fi

../$SUITE $*

EXCLUDES='Main
Snap
Blackbox.App
Blackbox.BarSnaplet
Blackbox.Common
Blackbox.EmbeddedSnaplet
Blackbox.FooSnaplet
Blackbox.Tests
Blackbox.Types
Paths_snap
Snap.Snaplet.Auth.Handlers.Tests
Snap.Snaplet.Auth.Tests
Snap.Snaplet.Test.Common.App
Snap.Snaplet.Test.Common.BarSnaplet
Snap.Snaplet.Test.Common.EmbeddedSnaplet
Snap.Snaplet.Test.Common.FooSnaplet
Snap.Snaplet.Test.Common.Handlers
Snap.Snaplet.Test.Common.Types
Snap.Snaplet.Heist.Tests
Snap.Snaplet.Internal.Lensed.Tests
Snap.Snaplet.Internal.LensT.Tests
Snap.Snaplet.Internal.RST.Tests
Snap.Snaplet.Internal.Tests
Snap.TestCommon
Snap.Snaplet.Test.App
Snap.Snaplet.Test.Tests
Snap.Snaplet.Auth.SpliceTests
Snap.Snaplet.Auth.Types.Tests
Snap.Snaplet.Config.App
Snap.Snaplet.Config.Tests
'

EXCL=""

for m in $EXCLUDES; do
    EXCL="$EXCL --exclude=$m"
done

rm -f snaplets/heist/templates/bad.tpl
rm -f snaplets/heist/templates/good.tpl
rm -fr non-cabal-appdir/snaplets/foosnaplet # TODO

cd .. 

# TODO - actually send results to /dev/null when hpc kinks are fully removed
hpc markup $EXCL --hpcdir=$MIXDIR --destdir=$HTMLDIR test/testsuite # >/dev/null 2>&1

cat <<EOF

Test coverage report written to $HTMLDIR.
EOF
