#!/bin/sh
# Usage : sh smoke_test.sh <url> <version-attendue>
set -eu

URL="$1"
VERSION_ATTENDUE="$2"

echo "==> Smoke test sur ${URL} (version attendue : ${VERSION_ATTENDUE})"

for i in 1 2 3 4 5 6 7 8 9 10; do
    if curl -fsS "${URL}/health" > /dev/null 2>&1; then
        echo "Health check OK (tentative ${i})"
        break
    fi
    if [ "${i}" -eq 10 ]; then
        echo "ECHEC : l'application ne répond pas correctement"
        exit 1
    fi
    echo "En attente de l'application (${i}/10)..."
    sleep 2
done

REPONSE=$(curl -fsS "${URL}/")
echo "Réponse : ${REPONSE}"

echo "${REPONSE}" | grep -q "\"version\": \"${VERSION_ATTENDUE}\"" || {
    echo "ECHEC : la version déployée n'est pas celle attendue"
    exit 1
}

echo "Smoke test réussi"