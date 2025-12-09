#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

repo=${GITHUB_README_STATS_REPO:-"https://github.com/anuraghazra/github-readme-stats.git"}
ref=${GITHUB_README_STATS_REF:-"master"}

if [ -z "${PAT_1:-}" ]; then
  echo "Error: PAT_1 environment variable is not set. Define at least one GH Personal Access Token for this app to work."
  exit 1
fi

echo "Cloning repository $repo (ref: $ref)..."
git clone --depth 1 --branch "$ref" "$repo" /repo

cd /repo

echo "Moving express dependency from devDependencies to dependencies in package.json..."

# Use jq to move express from devDependencies to dependencies
jq '.dependencies.express = .devDependencies.express | del(.devDependencies.express)' package.json > package.tmp.json
mv package.tmp.json package.json

echo "Installing production dependencies..."
npm install

echo "Starting the server..."
node express.js
