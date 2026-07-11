#!/bin/sh
# Automated smoke test for the apache2-ssl-secure container.
# Builds the image, runs it (the entrypoint auto-generates a self-signed cert),
# waits for apache to listen on 80 and asserts that the apache config is valid,
# that HTTP serves a response and that PHP actually executes.
set -e

IMG=apache2-ssl-secure-test
CN=apache2-ssl-secure-test-run

cleanup() { docker rm -f "$CN" >/dev/null 2>&1 || true; }
trap cleanup EXIT

fail() { echo "FAIL: $1"; exit 1; }

# HTTP GET over bash /dev/tcp (the image ships neither wget nor curl, but bash
# is present as the entrypoint interpreter). $1 = path, prints the raw response.
http_get() {
  docker exec "$CN" bash -c '
    exec 3<>/dev/tcp/127.0.0.1/80 || exit 1
    printf "GET %s HTTP/1.0\r\nHost: localhost\r\n\r\n" "'"$1"'" >&3
    cat <&3
  '
}

echo ">> building image"
docker build -t "$IMG" .

echo ">> starting container"
docker rm -f "$CN" >/dev/null 2>&1 || true
docker run -d --name "$CN" "$IMG" >/dev/null

echo ">> waiting for apache to listen on 80 (up to 120s)"
up=0
for _ in $(seq 1 60); do
  if docker exec "$CN" bash -c 'exec 3<>/dev/tcp/127.0.0.1/80' 2>/dev/null; then up=1; break; fi
  sleep 2
done
[ "$up" = 1 ] || fail "apache did not start listening on 80 in time"

echo ">> assert: container is running"
[ "$(docker inspect -f '{{.State.Running}}' "$CN")" = true ] || fail "container not running"
echo "ok - container running"

echo ">> assert: apache2ctl -t reports Syntax OK"
syntax=$(docker exec "$CN" apache2ctl -t 2>&1 || true)
echo "$syntax" | grep -q 'Syntax OK' || fail "apache config not valid (got: $syntax)"
echo "ok - apache2ctl -t: Syntax OK"

echo ">> assert: HTTP request on port 80 returns a response"
resp=$(http_get /) || fail "no HTTP response on port 80"
echo "$resp" | grep -q '^HTTP/' || fail "no HTTP status line (got: $(echo "$resp" | head -1))"
echo "ok - HTTP responded: $(echo "$resp" | head -1 | tr -d '\r')"

echo ">> assert: PHP executes"
docker exec "$CN" bash -c "printf '%s' \"<?php echo 'PHPOK:'.PHP_VERSION;\" > /var/www/html/phptest.php"
body=$(http_get /phptest.php)
echo "$body" | grep -q 'PHPOK:8\.' || fail "PHP did not execute as expected (got: $body)"
echo "ok - PHP executed: $(echo "$body" | grep -o 'PHPOK:8\.[0-9.]*')"

echo ""
echo "ALL TESTS PASSED"
