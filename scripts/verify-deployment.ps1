# Deployment Verification Script for DailyTools (PowerShell)

param(
    [string]$AppName = "dailytools-app",
    [string]$ResourceGroup = "DailyTools-RG"
)

Write-Host "========================================"
Write-Host "DailyTools Deployment Verification"
Write-Host "========================================"
Write-Host "App Name: $AppName"
Write-Host "Resource Group: $ResourceGroup"
Write-Host ""

# 1. Check if App Service exists
Write-Host "1. Checking if App Service exists..."
try {
    $app = az webapp show `
        --resource-group $ResourceGroup `
        --name $AppName `
        --query "id" -o tsv 2>$null

    if ([string]::IsNullOrEmpty($app)) {
        Write-Host "❌ App Service not found."
        exit 1
    }
} catch {
    Write-Host "❌ Error checking App Service"
    exit 1
}

Write-Host "✅ App Service found"

# 2. Get App Service URL
Write-Host "2. Getting App Service URL..."
$appUrl = az webapp show `
    --resource-group $ResourceGroup `
    --name $AppName `
    --query "defaultHostName" -o tsv

Write-Host "✅ App URL: https://$appUrl"

# 3. Check App Service state
Write-Host "3. Checking App Service state..."
$appState = az webapp show `
    --resource-group $ResourceGroup `
    --name $AppName `
    --query "state" -o tsv

Write-Host "   State: $appState"

# 4. Test connectivity
Write-Host "4. Testing connectivity to app..."
try {
    $response = Invoke-WebRequest -Uri "https://$appUrl" -UseBasicParsing -TimeoutSec 10
    $httpCode = $response.StatusCode
} catch {
    $httpCode = $_.Exception.Response.StatusCode.Value
}

if ($httpCode -eq 200) {
    Write-Host "✅ App is responding (HTTP 200)"
} elseif ($httpCode -eq 503) {
    Write-Host "⚠️  App is starting up (HTTP 503). Wait a moment and try again."
} else {
    Write-Host "⚠️  App responded with HTTP $httpCode"
}

# 5. Check Application Insights
Write-Host "5. Checking Application Insights..."
try {
    $appInsights = az monitor app-insights component list `
        --resource-group $ResourceGroup `
        --query "[0].name" -o tsv 2>$null

    if (-not [string]::IsNullOrEmpty($appInsights)) {
        Write-Host "✅ Application Insights: $appInsights"
    } else {
        Write-Host "⚠️  Application Insights not found"
    }
} catch {
    Write-Host "⚠️  Application Insights not found"
}

# 6. Show recent logs
Write-Host "6. Fetching recent logs from App Service..."
Write-Host ""
Write-Host "--- Recent Logs ---"
try {
    az webapp log tail `
        --resource-group $ResourceGroup `
        --name $AppName `
        --lines 20 2>$null
} catch {
    Write-Host "No logs available yet (app might still be starting)"
}

# 7. Show deployment slot info
Write-Host ""
Write-Host "7. Deployment Info..."
try {
    $deploymentSlot = az webapp deployment slot list `
        --resource-group $ResourceGroup `
        --name $AppName `
        --query "[0].name" -o tsv 2>$null

    if (-not [string]::IsNullOrEmpty($deploymentSlot)) {
        Write-Host "   Deployment slot: $deploymentSlot"
    }
} catch {
    Write-Host "   Deployment slot: production (default)"
}

# 8. Summary
Write-Host ""
Write-Host "========================================"
Write-Host "Verification Summary"
Write-Host "========================================"
Write-Host "✅ App Service exists and is configured"
Write-Host "✅ App URL: https://$appUrl"
Write-Host "📊 State: $appState"
Write-Host "📡 HTTP Status: $httpCode"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Visit: https://$appUrl in browser"
Write-Host "2. Check Application Insights for errors"
Write-Host "3. If issues: az webapp log tail -g $ResourceGroup -n $AppName (for live logs)"
Write-Host ""
