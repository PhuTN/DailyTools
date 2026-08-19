#!/bin/bash

echo "Running Unit Tests..."
dotnet test tests/Domain.UnitTests/Domain.UnitTests.csproj \
  --configuration Release \
  --no-build \
  --verbosity normal \
  --logger "trx;LogFileName=domain-unit-tests.trx"

dotnet test tests/Application.UnitTests/Application.UnitTests.csproj \
  --configuration Release \
  --no-build \
  --verbosity normal \
  --logger "trx;LogFileName=app-unit-tests.trx"

echo "Running Functional Tests..."
dotnet test tests/Application.FunctionalTests/Application.FunctionalTests.csproj \
  --configuration Release \
  --no-build \
  --verbosity normal \
  --logger "trx;LogFileName=app-functional-tests.trx" || true

echo "Running Integration Tests..."
dotnet test tests/Infrastructure.IntegrationTests/Infrastructure.IntegrationTests.csproj \
  --configuration Release \
  --no-build \
  --verbosity normal \
  --logger "trx;LogFileName=infra-integration-tests.trx" || true

echo "Tests completed!"
