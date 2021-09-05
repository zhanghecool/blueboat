#!/bin/bash

set -euo pipefail

CONFIG="$1"
SUFFIX="$2"

if [ ! -f "$CONFIG" ]; then
    echo "[-] config file does not exist"
    exit 1
fi

if [ -z "$SUFFIX" ]; then
    echo "[-] suffix required"
    exit 1
fi

. "$CONFIG"

# Allow empty suffix
#if [ -z "$IMAGE_SUFFIX" ]; then
#    echo "[-] IMAGE_SUFFIX not defined"
#    exit 1
#fi

rm -r "./k8s.$SUFFIX" || true
cp -r "`dirname $0`/k8s" "./k8s.$SUFFIX"

find "./k8s.$SUFFIX" -name "*.yaml" -exec sed -i "s#__EXTERNAL_IPS__#$EXTERNAL_IPS#g" '{}' ';'
find "./k8s.$SUFFIX" -name "*.yaml" -exec sed -i "s#__IMAGE_PREFIX__#$IMAGE_PREFIX#g" '{}' ';'
find "./k8s.$SUFFIX" -name "*.yaml" -exec sed -i "s#__IMAGE_SUFFIX__#$IMAGE_SUFFIX#g" '{}' ';'
find "./k8s.$SUFFIX" -name "*.yaml" -exec sed -i "s#__NAMESPACE__#$NAMESPACE#g" '{}' ';'
find "./k8s.$SUFFIX" -name "*.yaml" -exec sed -i "s#__DB_URL__#$DB_URL#g" '{}' ';'
find "./k8s.$SUFFIX" -name "*.yaml" -exec sed -i "s#__NUM_PROXIES__#$NUM_PROXIES#g" '{}' ';'
find "./k8s.$SUFFIX" -name "*.yaml" -exec sed -i "s#__NUM_RUNTIMES__#$NUM_RUNTIMES#g" '{}' ';'
find "./k8s.$SUFFIX" -name "*.yaml" -exec sed -i "s#__NUM_FETCHD__#$NUM_FETCHD#g" '{}' ';'
find "./k8s.$SUFFIX" -name "*.yaml" -exec sed -i "s#__CPU_REQUEST_PER_RUNTIME__#$CPU_REQUEST_PER_RUNTIME#g" '{}' ';'

set +u
if [ -z "$IMAGE_PULL_SECRET" ]; then
    find "./k8s.$SUFFIX" -name "*.yaml" -exec sed -i "s#__MAYBE_PULL_SECRETS__##g" '{}' ';'
else
    find "./k8s.$SUFFIX" -name "*.yaml" -exec sed -i "s#__MAYBE_PULL_SECRETS__#imagePullSecrets:\n      - name: \"$IMAGE_PULL_SECRET\"#g" '{}' ';'
fi
set -u

cd "./k8s.$SUFFIX"
echo "#!/bin/sh" > apply.sh
echo "cd \"\`dirname \$0\`\"" >> apply.sh
find . -name "*.yaml" -exec 'echo' 'kubectl apply -f' '{}' ';' >> apply.sh
chmod +x apply.sh

echo "Done."
