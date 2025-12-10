#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

repo=${GITHUB_README_STATS_REPO:-"https://github.com/anuraghazra/github-readme-stats.git"}
ref=${GITHUB_README_STATS_REF:-"master"}
fix_audit=${FIX_AUDIT:-"true"}

if [ -z "${PAT_1:-}" ]; then
  echo "Error: PAT_1 environment variable is not set. Define at least one GH Personal Access Token for this app to work."
  exit 1
fi

echo "Cloning repository $repo (ref: $ref)..."

mkdir -p /repo
cd /repo
git init --initial-branch=main
git config advice.detachedHead false
git remote add origin "$repo"
git fetch --depth 1 origin "$ref"
git checkout FETCH_HEAD

echo "Moving express dependency from devDependencies to dependencies in package.json..."

# Use jq to move express from devDependencies to dependencies
jq '.dependencies.express = .devDependencies.express | del(.devDependencies.express)' package.json > package.tmp.json
mv package.tmp.json package.json

if [ "$fix_audit" = "true" ]; then
  echo "Fixing audit issues in package-lock.json..."
  npm audit fix
fi

echo "Installing production dependencies..."
npm install

echo "Starting the server..."

cleanup() {
    echo "Container stopping, shutting down Node.js..."
    kill -TERM "$pid" 2>/dev/null
    wait "$pid" || true
    exit 0
}

trap cleanup SIGTERM SIGINT

node express.js &
pid=$!

wait "$pid"
