# Azure Resource Provisioning Script for DailyTools CI/CD (PowerShell)

# Configuration
$resourceGroup = "DailyTools-RG"
$location = "eastasia"  # Thay bằng vùng của bạn
$appServicePlan = "DailyTools-AppPlan"
$appServiceName = "dailytools-app"
$appInsightsName = "dailytools-insights"
$environment = "Production"

Write-Host "========================================"
Write-Host "DailyTools Azure Resource Provisioning"
Write-Host "========================================"

# 1. Create Resource Group
Write-Host "1. Creating Resource Group: $resourceGroup..."
az group create `
  --name $resourceGroup `
  --location $location

# 2. Create App Service Plan
Write-Host "2. Creating App Service Plan: $appServicePlan..."
az appservice plan create `
  --name $appServicePlan `
  --resource-group $resourceGroup `
  --sku B2 `
  --is-linux

# 3. Create App Service
Write-Host "3. Creating App Service: $appServiceName..."
az webapp create `
  --resource-group $resourceGroup `
  --plan $appServicePlan `
  --name $appServiceName `
  --runtime "DOTNET|10.0"

# 4. Create Application Insights
Write-Host "4. Creating Application Insights: $appInsightsName..."
az monitor app-insights component create `
  --app $appInsightsName `
  --resource-group $resourceGroup `
  --location $location `
  --application-type web

# 5. Get Application Insights Connection String
Write-Host "5. Retrieving Application Insights connection string..."
$appInsightsConnString = az monitor app-insights component show `
  --app $appInsightsName `
  --resource-group $resourceGroup `
  --query connectionString -o tsv

# 6. Configure App Settings
Write-Host "6. Configuring App Settings..."
az webapp config appsettings set `
  --resource-group $resourceGroup `
  --name $appServiceName `
  --settings `
    "ASPNETCORE_ENVIRONMENT=$environment" `
    "ApplicationInsightsAgent_EXTENSION_VERSION=~3" `
    "XDT_MicrosoftApplicationInsights_Mode=recommended" `
    "APPINSIGHTS_CONNECTIONSTRING=$appInsightsConnString"

# 7. Enable logging
Write-Host "7. Enabling App Service logging..."
az webapp log config `
  --resource-group $resourceGroup `
  --name $appServiceName `
  --application-logging filesystem `
  --level information `
  --detailed-error-messages true

Write-Host ""
Write-Host "========================================"
Write-Host "Resource Provisioning Complete!"
Write-Host "========================================"
Write-Host ""
Write-Host "App Service Name: $appServiceName"
Write-Host "Resource Group: $resourceGroup"
Write-Host "App Service Plan: $appServicePlan"
Write-Host "Application Insights: $appInsightsName"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Add your SQL_CONNECTION_STRING to GitHub Secrets"
Write-Host "2. Run Service Principal creation:"
Write-Host "   az ad sp create-for-rbac --name 'github-actions-dailytools' --role Contributor"
Write-Host "3. Add the credentials to GitHub Secrets:"
Write-Host "   - AZURE_CLIENT_ID"
Write-Host "   - AZURE_CLIENT_SECRET"
Write-Host "   - AZURE_SUBSCRIPTION_ID"
Write-Host "   - AZURE_TENANT_ID"
Write-Host "4. Push code to main branch to trigger CI/CD"
Write-Host ""
