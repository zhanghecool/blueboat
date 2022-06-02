#!/bin/bash

set -e

export AWS_ACCESS_KEY_ID="minioadmin"
export AWS_SECRET_ACCESS_KEY="minioadmin"
export RUST_LOG=info

./target/release/blueboat_server \
  -l "0.0.0.0:3000" \
  --mds r1=/etc/foundationdb/fdb.cluster:blueboat-r1 \
  --s3-bucket "apps" --s3-region "us-east-1" \
  --s3-endpoint "http://127.0.0.1:1932"