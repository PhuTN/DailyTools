#!/bin/bash

# Azure Resource Provisioning Script for DailyTools CI/CD

set -e

# Configuration
RESOURCE_GROUP="DailyTools-RG"
LOCATION="eastasia"  # Thay bằng vùng của bạn (ví dụ: eastasia, southeastasia, etc.)
APP_SERVICE_PLAN="DailyTools-AppPlan"
APP_SERVICE_NAME="dailytools-app"
APP_INSIGHTS_NAME="dailytools-insights"
ENVIRONMENT="Production"

echo "========================================"
echo "DailyTools Azure Resource Provisioning"
echo "========================================"

# 1. Create Resource Group
echo "1. Creating Resource Group: $RESOURCE_GROUP..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# 2. Create App Service Plan
echo "2. Creating App Service Plan: $APP_SERVICE_PLAN..."
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --sku B2 \
  --is-linux

# 3. Create App Service
echo "3. Creating App Service: $APP_SERVICE_NAME..."
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $APP_SERVICE_NAME \
  --runtime "DOTNET|10.0"

# 4. Create Application Insights
echo "4. Creating Application Insights: $APP_INSIGHTS_NAME..."
az monitor app-insights component create \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --application-type web

# 5. Get Application Insights Connection String
echo "5. Retrieving Application Insights connection string..."
APP_INSIGHTS_CONN_STRING=$(az monitor app-insights component show \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query connectionString -o tsv)

# 6. Configure App Settings
echo "6. Configuring App Settings..."
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --settings \
    "ASPNETCORE_ENVIRONMENT=$ENVIRONMENT" \
    "ApplicationInsightsAgent_EXTENSION_VERSION=~3" \
    "XDT_MicrosoftApplicationInsights_Mode=recommended" \
    "APPINSIGHTS_CONNECTIONSTRING=$APP_INSIGHTS_CONN_STRING"

# 7. Enable logging
echo "7. Enabling App Service logging..."
az webapp log config \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --application-logging filesystem \
  --level information \
  --detailed-error-messages true

echo ""
echo "========================================"
echo "Resource Provisioning Complete!"
echo "========================================"
echo ""
echo "App Service Name: $APP_SERVICE_NAME"
echo "Resource Group: $RESOURCE_GROUP"
echo "App Service Plan: $APP_SERVICE_PLAN"
echo "Application Insights: $APP_INSIGHTS_NAME"
echo ""
echo "Next steps:"
echo "1. Add your SQL_CONNECTION_STRING to GitHub Secrets"
echo "2. Run: az ad sp create-for-rbac --name 'github-actions-dailytools' --role Contributor"
echo "3. Add the Service Principal credentials to GitHub Secrets:"
echo "   - AZURE_CLIENT_ID"
echo "   - AZURE_CLIENT_SECRET"
echo "   - AZURE_SUBSCRIPTION_ID"
echo "   - AZURE_TENANT_ID"
echo "4. Push your code to main branch to trigger the CI/CD pipeline"
echo ""
