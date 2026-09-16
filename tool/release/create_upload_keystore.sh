#!/usr/bin/env bash
#
# Creates the Play upload keystore and the android/key.properties that points
# at it.
#
# Run it yourself. keytool prompts for the passwords on your terminal, so the
# secrets never pass through a script argument, your shell history, a build
# log, or anyone you asked for help.
#
#   bash tool/release/create_upload_keystore.sh
#
# BACK UP THE KEYSTORE. If you lose it you cannot ship an update to the same
# Play listing unless Google can reset the upload key for you. Keep a copy off
# this machine, and keep the passwords in a password manager.

set -euo pipefail

ALIAS="livemate-upload"
KEYSTORE="${1:-$HOME/livemate-upload.jks}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROPS="$REPO_ROOT/android/key.properties"

# Gradle is a JVM process and cannot resolve an MSYS/Cygwin path like
# /c/Users/you/... — it would treat it as relative to android/app and fail with
# "Keystore file ... not found". Write the native path into key.properties.
if command -v cygpath >/dev/null 2>&1; then
  KEYSTORE_PROP="$(cygpath -m "$KEYSTORE")"
else
  KEYSTORE_PROP="$KEYSTORE"
fi

if [ -e "$KEYSTORE" ]; then
  echo "Refusing to overwrite an existing keystore: $KEYSTORE" >&2
  echo "Pass a different path, or delete it only if you are certain it was" >&2
  echo "never used to publish." >&2
  exit 1
fi

if [ -e "$PROPS" ]; then
  echo "android/key.properties already exists. Move it aside first." >&2
  exit 1
fi

echo "Creating $KEYSTORE"
echo "You will be asked for a keystore password, then your details."
echo

keytool -genkeypair -v \
  -keystore "$KEYSTORE" \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias "$ALIAS"

echo
read -r -s -p "Re-enter the keystore password so key.properties can be written: " STORE_PASS
echo

# keytool -genkeypair with no -keypass gives the key the store password.
umask 077
cat > "$PROPS" <<EOF
storePassword=$STORE_PASS
keyPassword=$STORE_PASS
keyAlias=$ALIAS
storeFile=$KEYSTORE_PROP
EOF

echo
echo "Wrote $PROPS (gitignored, permissions 600)."
echo
echo "Next:"
echo "  flutter build appbundle --release"
echo "  # upload build/app/outputs/bundle/release/app-release.aab to Play"
echo
echo "Verify the signature at any time with:"
echo "  keytool -list -v -keystore \"$KEYSTORE\" -alias $ALIAS"
