#!/bin/bash

set -e  # Exit on error

echo "Building .NET solution..."
dotnet build --configuration Release

echo "Building Angular application..."
cd src/Web/ClientApp
npm ci
npm run build -- --configuration production
cd ../../..

echo "Publishing .NET application..."
dotnet publish src/Web/Web.csproj \
  --configuration Release \
  --output ./publish \
  --no-build

echo "Copying Angular dist to wwwroot..."
mkdir -p ./publish/wwwroot
cp -r src/Web/ClientApp/dist/* ./publish/wwwroot/

echo "Build and publish completed successfully!"
