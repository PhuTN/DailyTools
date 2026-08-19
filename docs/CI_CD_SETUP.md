# CI/CD Setup Guide - DailyTools

Hướng dẫn thiết lập CI/CD với GitHub Actions + Azure App Service cho dự án DailyTools (.NET 10 + Angular).

## 📋 Yêu cầu

- Azure Subscription đang hoạt động
- Git repository đã được push lên GitHub
- Azure CLI installed: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
- PowerShell hoặc Bash shell

## 🚀 Bước 1: Tạo Azure Resources

### Option A: Sử dụng Script (Khuyến khích)

**Trên Windows (PowerShell):**
```powershell
.\scripts\provision-azure-resources.ps1
```

**Trên Linux/Mac (Bash):**
```bash
bash scripts/provision-azure-resources.sh
```

### Option B: Tạo Manual

Nếu muốn tạo thủ công, truy cập [Azure Portal](https://portal.azure.com) và tạo:
1. **Resource Group**: `DailyTools-RG`
2. **App Service Plan**: Linux, SKU B2 hoặc cao hơn
3. **App Service**: Runtime: `.NET 8.0` (hoặc 10.0 nếu có)
4. **Application Insights**: Cho monitoring

## 🔐 Bước 2: Tạo Service Principal cho GitHub Actions

```powershell
# Đăng nhập vào Azure
az login

# Tạo Service Principal
az ad sp create-for-rbac `
  --name "github-actions-dailytools" `
  --role Contributor `
  --scopes /subscriptions/{subscription-id}
```

Lưu lại output:
```json
{
  "clientId": "...",
  "clientSecret": "...",
  "subscriptionId": "...",
  "tenantId": "..."
}
```

## 🔑 Bước 3: Thêm GitHub Secrets

Vào: **GitHub Repository** → **Settings** → **Secrets and variables** → **Actions**

Thêm những secrets sau:

| Secret Name | Giá trị |
|---|---|
| `AZURE_CLIENT_ID` | Từ Service Principal |
| `AZURE_CLIENT_SECRET` | Từ Service Principal |
| `AZURE_SUBSCRIPTION_ID` | Từ Service Principal |
| `AZURE_TENANT_ID` | Từ Service Principal |
| `AZURE_APP_NAME` | Tên App Service (ví dụ: `dailytools-app`) |
| `AZURE_RESOURCE_GROUP` | Tên Resource Group (ví dụ: `DailyTools-RG`) |
| `SQL_CONNECTION_STRING` | Connection string SQL Server của bạn |

**SQL Connection String Example:**
```
Server=your-server-ip-or-hostname;Database=DailyTools;User Id=sa;Password=your-password;TrustServerCertificate=True;MultipleActiveResultSets=true
```

## 📦 Bước 4: Kiểm tra Workflow

Workflow file đã tạo tại: `.github/workflows/ci-cd.yml`

**Các job chính:**
1. **build-and-test**
   - Restore NuGet packages
   - Build .NET solution
   - Run unit tests, functional tests, integration tests
   - Build Angular app
   - Publish artifacts

2. **deploy-to-azure**
   - Download artifacts
   - Deploy to Azure App Service
   - Configure connection strings
   - Set environment variables

## 🚀 Bước 5: Trigger Deployment

Cách trigger CI/CD:

### Option 1: Push to Main Branch
```bash
git add .
git commit -m "Setup CI/CD"
git push origin main
```

### Option 2: Manual Trigger (nếu workflow có on: workflow_dispatch)
- Vào GitHub Actions tab → Chọn workflow → Click "Run workflow"

## 📊 Monitoring

### View Build Logs
1. Vào **GitHub Repository** → **Actions**
2. Click vào workflow run muốn xem
3. Xem logs từ mỗi step

### View Azure Deployment
1. Vào [Azure Portal](https://portal.azure.com)
2. Tìm App Service
3. Xem logs: **Monitoring** → **Log Stream**
4. Xem health: **Health Check** hoặc **Application Insights**

## 🐛 Troubleshooting

### Build Failed: "Cannot find module"
- Kiểm tra Node.js version (cần 18.x+)
- Run: `npm ci` thay vì `npm install`

### Build Failed: "DotNet command not found"
- Cập nhật `.NET version` trong workflow file
- Kiểm tra runner OS (ubuntu-latest)

### Deploy Failed: "Auth failed"
- Kiểm tra Service Principal credentials trong Secrets
- Kiểm tra subscription ID
- Verify quyền Contributor role

### App Service Cannot Connect to Database
- Kiểm tra SQL Connection String trong Secrets
- Kiểm tra firewall rules cho SQL Server (cho phép IP của App Service)
- Kiểm tra database credentials

### Angular Build Failed
- Kiểm tra `angular.json` outputPath
- Run locally: `npm ci && npm run build -- --configuration production`
- Verify Node modules: `npm ci` (clean install)

## 📝 File Structure

```
.github/workflows/
├── ci-cd.yml              # Main CI/CD workflow
src/Web/
├── appsettings.json       # Development settings
├── appsettings.Production.json  # Production settings
├── ClientApp/
│   ├── angular.json       # Angular build config
│   └── dist/              # Built Angular app (generated)
scripts/
├── provision-azure-resources.ps1  # Azure resource creation (PowerShell)
├── provision-azure-resources.sh   # Azure resource creation (Bash)
├── build-and-publish.sh           # Local build script
└── run-tests.sh                   # Local test script
```

## ✅ Checklist

- [ ] Azure subscription tạo xong
- [ ] Service Principal được tạo
- [ ] Tất cả GitHub Secrets được thêm
- [ ] Workflow file `.github/workflows/ci-cd.yml` tồn tại
- [ ] Push code to main branch
- [ ] GitHub Actions workflow chạy thành công
- [ ] App Service deploy thành công
- [ ] App có thể access qua browser
- [ ] Database connection thành công
- [ ] Angular app load thành công

## 🔄 CI/CD Flow

```
Push to main
    ↓
GitHub Actions triggered
    ↓
build-and-test job
  - Setup .NET + Node.js
  - Restore packages
  - Build .NET
  - Run tests
  - Build Angular
  - Publish artifacts
    ↓
deploy-to-azure job (if main branch)
  - Download artifacts
  - Azure login
  - Deploy to App Service
  - Configure settings
  - Done!
```

## 📚 Tài liệu tham khảo

- [Azure App Service Deployment](https://docs.microsoft.com/en-us/azure/app-service/deploy-github-actions)
- [GitHub Actions for Azure](https://github.com/Azure/actions)
- [ASP.NET Core with App Service](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/azure-apps)
- [Angular Deployment](https://angular.io/guide/deployment)

## 🆘 Cần Giúp Đỡ?

Nếu gặp vấn đề:
1. Kiểm tra GitHub Actions logs
2. Kiểm tra Azure Portal logs
3. Run local scripts để test build
4. Kiểm tra Secrets có đúng không

---

**Last Updated**: 2024
**For**: DailyTools CI/CD Setup
