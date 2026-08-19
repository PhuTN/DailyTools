# 🚀 DailyTools CI/CD - Quick Start Guide

## ⚡ 5 Bước Setup Nhanh

### 1️⃣ Tạo Azure Resources (5 phút)

**Windows (PowerShell):**
```powershell
.\scripts\provision-azure-resources.ps1
```

**Linux/Mac:**
```bash
bash scripts/provision-azure-resources.sh
```

> Lưu lại tên App Service từ output (default: `dailytools-app`)

---

### 2️⃣ Tạo Service Principal (3 phút)

Chạy lệnh này và lưu output:

```powershell
az login

az ad sp create-for-rbac `
  --name "github-actions-dailytools" `
  --role Contributor
```

**Output sẽ trông như thế này:**
```json
{
  "appId": "AZURE_CLIENT_ID",
  "displayName": "github-actions-dailytools",
  "password": "AZURE_CLIENT_SECRET",
  "tenant": "AZURE_TENANT_ID"
}
```

---

### 3️⃣ Thêm 6 GitHub Secrets (2 phút)

**Vào:** https://github.com/PhuTN/DailyTools/settings/secrets/actions

**Thêm 6 secrets:**

```
AZURE_CLIENT_ID = appId từ Step 2
AZURE_CLIENT_SECRET = password từ Step 2
AZURE_TENANT_ID = tenant từ Step 2
AZURE_SUBSCRIPTION_ID = subscription ID của bạn
AZURE_APP_NAME = dailytools-app
AZURE_RESOURCE_GROUP = DailyTools-RG
SQL_CONNECTION_STRING = Server=YOUR_SERVER;Database=DailyTools;User Id=sa;Password=YOUR_PASSWORD;TrustServerCertificate=True;
```

---

### 4️⃣ Push Code to Main (1 phút)

```powershell
git add .
git commit -m "Setup CI/CD pipeline"
git push origin main
```

---

### 5️⃣ Xem Kết Quả (2 phút)

**Vào:** https://github.com/PhuTN/DailyTools/actions

- Chọn **CI/CD - Build & Deploy** workflow
- Xem logs từ mỗi step
- Chờ tới khi status là ✅ **Success**

---

## ✅ Verify Deployment

Sau khi workflow chạy xong:

**Windows:**
```powershell
.\scripts\verify-deployment.ps1 -AppName dailytools-app -ResourceGroup DailyTools-RG
```

**Linux/Mac:**
```bash
bash scripts/verify-deployment.sh dailytools-app DailyTools-RG
```

Hoặc truy cập trực tiếp: `https://dailytools-app.azurewebsites.net`

---

## 📊 Monitoring & Logs

### GitHub Actions Logs
- https://github.com/PhuTN/DailyTools/actions

### Azure App Service Logs
```powershell
az webapp log tail `
  --resource-group DailyTools-RG `
  --name dailytools-app
```

### Application Insights
- https://portal.azure.com → Search "DailyTools" → Chọn Application Insights

---

## 🔄 Workflow Trigger Options

### Option 1: Auto Trigger (Mặc định)
```bash
git push origin main  # Workflow tự chạy
```

### Option 2: Manual Trigger
- GitHub → Actions → CI/CD workflow → **Run workflow**

---

## 🛠️ Files Tạo Ra

```
.github/workflows/
├── ci-cd.yml                    ✅ Workflow chính

src/Web/
├── appsettings.Production.json  ✅ Cấu hình Production

scripts/
├── provision-azure-resources.ps1    ✅ Tạo Azure resources
├── provision-azure-resources.sh     ✅ (Linux version)
├── build-and-publish.sh             ✅ Local build
├── run-tests.sh                     ✅ Local test
├── verify-deployment.ps1            ✅ Verify deployment
└── verify-deployment.sh             ✅ (Linux version)

docs/
└── CI_CD_SETUP.md               ✅ Chi tiết full doc
```

---

## ⚠️ Troubleshooting

| Vấn đề | Giải Pháp |
|--------|---------|
| Build fail "Cannot find module" | Kiểm tra Node.js version 18.x |
| Deploy fail "Auth failed" | Kiểm tra Azure credentials trong Secrets |
| App không kết nối DB | Kiểm tra SQL connection string + firewall |
| App return 503 | Chờ 2-3 phút, app đang start up |

---

## 📚 Tài Liệu Chi Tiết

Xem **docs/CI_CD_SETUP.md** để:
- Setup từng bước chi tiết
- Troubleshooting chi tiết
- Architecture explanation
- Best practices

---

## 🎯 Workflow Logic

```
┌─────────────────┐
│  Push to main   │
└────────┬────────┘
         │
    ┌────▼──────┐
    │ Checkout  │
    └────┬──────┘
         │
    ┌────▼──────────────────────────────────┐
    │ build-and-test job                    │
    │ • Setup .NET 10 & Node.js 18          │
    │ • Restore NuGet + npm                 │
    │ • Build .NET + Angular                │
    │ • Run tests (units + functional)      │
    │ • Publish to artifact                 │
    └────┬──────────────────────────────────┘
         │
    ┌────▼──────────────────────────────────┐
    │ deploy-to-azure job (if main branch)  │
    │ • Download artifact                   │
    │ • Azure login                         │
    │ • Deploy to App Service               │
    │ • Set connection strings              │
    │ • Done ✅                             │
    └─────────────────────────────────────┘
```

---

**🎉 Selamat! CI/CD Anda sudah siap!**

Setiap kali push ke `main`, aplikasi akan otomatis:
1. ✅ Build & test
2. ✅ Deploy ke Azure
3. ✅ Update website

---

**Need Help?** Check docs/CI_CD_SETUP.md atau GitHub Issues
