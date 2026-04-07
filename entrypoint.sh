#!/bin/sh
set -e

echo "=== LimeSurvey Quadlet EntryPoint ==="

LIMESURVEY_VERSION="${LIMESURVEY_VERSION}"
DOWNLOAD_URL="https://download.limesurvey.org/latest-master/limesurvey${LIMESURVEY_VERSION}.zip"
ZIP_FILE="/tmp/limesurvey.zip"
BASE_DIR="/var/www/html"
INSTANCES="abierta distancia"

# 1. Check if ANY instance needs installation
NEEDS_INSTALL=false
for INSTANCE in $INSTANCES; do
  DIR="${BASE_DIR}/${INSTANCE}"
  if [ ! -f "${DIR}/index.php" ]; then
    NEEDS_INSTALL=true
    echo "→ LimeSurvey not detected in ${INSTANCE}"
    break
  fi
done

# 2. Download only once if needed
if [ "$NEEDS_INSTALL" = true ]; then
  echo "Downloading LimeSurvey ${LIMESURVEY_VERSION}..."
  wget -q -O "$ZIP_FILE" "$DOWNLOAD_URL"
  echo "Download finished."
fi

# 3. Extract to the instances that need it
for INSTANCE in $INSTANCES; do
  DIR="${BASE_DIR}/${INSTANCE}"
  if [ ! -f "${DIR}/index.php" ]; then
    echo "Extracting LimeSurvey → ${DIR} ..."
    unzip -q "$ZIP_FILE" -d "${DIR}"

    # The official zip contains a top-level "limesurvey/" folder → flatten it
    if [ -d "${DIR}/limesurvey" ]; then
      mv "${DIR}/limesurvey/"* "${DIR}/" 2>/dev/null || true
      mv "${DIR}/limesurvey/."* "${DIR}/" 2>/dev/null || true
      rmdir "${DIR}/limesurvey"
    fi

    echo "✅ LimeSurvey installed in ${INSTANCE}"
  else
    echo "✓ LimeSurvey already present in ${INSTANCE} (skipped)"
  fi
done

echo "=== Initialization done ==="
exec "$@"