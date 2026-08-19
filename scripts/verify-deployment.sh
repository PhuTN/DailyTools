#!/bin/bash

# Deployment Verification Script for DailyTools

set -e

# Configuration
APP_NAME=${1:-"dailytools-app"}
RESOURCE_GROUP=${2:-"DailyTools-RG"}
TIMEOUT=300  # 5 minutes timeout

echo "========================================"
echo "DailyTools Deployment Verification"
echo "========================================"
echo "App Name: $APP_NAME"
echo "Resource Group: $RESOURCE_GROUP"
echo ""

# 1. Check if App Service exists
echo "1. Checking if App Service exists..."
APP_EXISTS=$(az webapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query "id" -o tsv 2>/dev/null || echo "NOT_FOUND")

if [ "$APP_EXISTS" = "NOT_FOUND" ]; then
  echo "❌ App Service not found. Please run provision-azure-resources script first."
  exit 1
fi

echo "✅ App Service found"

# 2. Get App Service URL
echo "2. Getting App Service URL..."
APP_URL=$(az webapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query "defaultHostName" -o tsv)

echo "✅ App URL: https://$APP_URL"

# 3. Check App Service state
echo "3. Checking App Service state..."
APP_STATE=$(az webapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query "state" -o tsv)

echo "   State: $APP_STATE"

# 4. Test connectivity
echo "4. Testing connectivity to app..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://$APP_URL" || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ App is responding (HTTP 200)"
elif [ "$HTTP_CODE" = "503" ]; then
  echo "⚠️  App is starting up (HTTP 503). Wait a moment and try again."
elif [ "$HTTP_CODE" = "000" ]; then
  echo "❌ Cannot connect to app. Check if app is deployed."
  exit 1
else
  echo "⚠️  App responded with HTTP $HTTP_CODE"
fi

# 5. Check Application Insights
echo "5. Checking Application Insights..."
APP_INSIGHTS=$(az monitor app-insights component list \
  --resource-group $RESOURCE_GROUP \
  --query "[0].name" -o tsv 2>/dev/null || echo "NOT_FOUND")

if [ "$APP_INSIGHTS" != "NOT_FOUND" ]; then
  echo "✅ Application Insights: $APP_INSIGHTS"
else
  echo "⚠️  Application Insights not found"
fi

# 6. Check recent logs
echo "6. Fetching recent logs from App Service..."
echo ""
echo "--- Recent Logs ---"
az webapp log tail \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --lines 20 2>/dev/null || echo "No logs available yet (app might still be starting)"

# 7. Show deployment slot info
echo ""
echo "7. Deployment Info..."
DEPLOYMENT_SLOT=$(az webapp deployment slot list \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query "[0].name" -o tsv 2>/dev/null || echo "production")

echo "   Deployment slot: $DEPLOYMENT_SLOT"

# 8. Summary
echo ""
echo "========================================"
echo "Verification Summary"
echo "========================================"
echo "✅ App Service exists and is configured"
echo "✅ App URL: https://$APP_URL"
echo "📊 State: $APP_STATE"
echo "📡 HTTP Status: $HTTP_CODE"
echo ""
echo "Next steps:"
echo "1. Visit: https://$APP_URL in browser"
echo "2. Check Application Insights for errors"
echo "3. If issues: az webapp log tail ... (for live logs)"
echo ""
