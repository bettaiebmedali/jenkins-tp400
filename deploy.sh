#!/bin/sh
# Usage : sh deploy.sh <environnement> <port-hote> <image>
set -eu

ENVIRONNEMENT="$1"
PORT="$2"
IMAGE="$3"
NAME="demo-app-${ENVIRONNEMENT}"

echo "==> Déploiement de ${IMAGE} sur ${ENVIRONNEMENT} (port ${PORT})"

ACTUELLE=$(docker inspect --format '{{.Config.Image}}' "${NAME}" 2>/dev/null || true)
echo "==> Version actuellement déployée : ${ACTUELLE:-aucune}"

docker pull "${IMAGE}"
docker rm -f "${NAME}" > /dev/null 2>&1 || true

docker run -d \
  --name "${NAME}" \
  --network cicd \
  --restart unless-stopped \
  -p "${PORT}:8000" \
  -e APP_ENV="${ENVIRONNEMENT}" \
  "${IMAGE}"

echo "==> Conteneur ${NAME} démarré"