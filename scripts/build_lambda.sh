#!/usr/bin/env bash
set -e

BUILD_DIR="build/lambda"
ZIP_PATH="infra/terraform/lambda.zip"

rm -rf "$BUILD_DIR"
rm -f "$ZIP_PATH"

mkdir -p "$BUILD_DIR"

python3 -m pip install requests --target "$BUILD_DIR"

cp -r src/tmdb_pipeline "$BUILD_DIR"

(
  cd "$BUILD_DIR"
  zip -r "../../$ZIP_PATH" .
)