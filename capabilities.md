# LunaLock — 配置文档

生成时间：2026-06-08

---

## 一、⚠️ 手动配置（需你操作才能生效）

### 🔴 Capabilities 配置

#### HealthKit — 写入经期数据到健康 App

**影响功能**：不配置则 Settings 中的 "HealthKit Integration" 开关无法使用，经期数据不会写入 Apple 健康 App

**已自动配置部分**：
- ✅ SettingsView 中已有 HealthKit 开关和请求权限代码
- ✅ PaywallView 中已列出 HealthKit 为 Pro 功能

**仍需手动配置**：
1. 打开 Xcode → 选择 LunaLock target → **Signing & Capabilities**
2. 点击 **"+ Capability"** → 搜索 **HealthKit** → 双击添加
3. Xcode 会自动创建 `.entitlements` 文件并添加 `com.apple.developer.healthkit` 权限
4. 在 **Info** 标签页 → **Custom iOS Target Properties** 中添加：
   - `NSHealthShareUsageDescription` = `LunaLock does not read your health data`
   - `NSHealthUpdateUsageDescription` = `LunaLock writes your period data to Health app for centralized tracking`
5. 在 HealthKit capability 设置中，取消勾选 **Read** 权限（App 只写入，不读取）
6. ⚠️ 配置完成后需要重新 Build 验证

---

### 🔵 IAP StoreKit 配置

**影响功能**：不创建 IAP 产品则用户无法购买 Pro 升级

**已自动配置部分**：
- ✅ PurchaseManager.swift 已使用 StoreKit 2，Product ID = `com.zzoutuo.LunaLock.pro`
- ✅ PaywallView 已展示功能列表和购买按钮
- ✅ SettingsView 已有 "Restore Purchases" 按钮

**仍需手动配置**：
1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入你的 App → **Features** → **In-App Purchases**
3. 点击 **"+"** 创建非消耗型产品：

| 字段 | 值 |
|------|------|
| Type | Non-Consumable |
| Reference Name | LunaLock Pro |
| Product ID | `com.zzoutuo.LunaLock.pro` |
| Price | $3.99 |

4. 填写 Display Name: `LunaLock Pro`
5. 填写 Description: `Unlock all premium features forever — trend charts, data export, widgets, themes, HealthKit, and more.`
6. ⚠️ 创建后需要等待 Apple 审核（通常1-2小时）
7. 在 Xcode 中创建 **StoreKit Configuration File**（File → New → File → StoreKit Configuration File）用于本地测试，添加 Product ID `com.zzoutuo.LunaLock.pro`，类型 Non-Consumable，价格 $3.99
8. 在 SettingsView 中点击 **"Restore Purchases"** 验证流程

---

### 🟢 App Store Connect 审核信息配置

**影响功能**：不配置则 Apple 审核员可能因 Guideline 2.1 无法测试 IAP 功能，导致拒绝

**配置步骤**：
1. 在 App Store Connect → 你的 App → **App Review Information**
2. 在 **Notes** 字段中说明：
   - 本 App 为隐私优先经期追踪器，所有数据本地存储
   - Pro 功能通过一次性购买解锁（Non-Consumable IAP, Product ID: com.zzoutuo.LunaLock.pro）
   - HealthKit 为可选功能，仅写入经期数据
3. 确保 **Privacy Policy URL** 填写：`https://asunnyboy861.github.io/LunaLock/privacy.html`
4. 如有 Terms of Use，确保填写：`https://asunnyboy861.github.io/LunaLock/terms.html`

---

## 二、✅ 自动配置记录（已由系统完成，无需操作）

### Capabilities 自动配置

| Capability | 说明 | 状态 |
|------------|------|------|
| FaceID / Local Authentication | NSFaceIDUsageDescription 已在 Build Settings 配置 | ✅ 已配置 |
| Push Notifications (Local) | 使用 UNUserNotificationCenter，无需 entitlement | ✅ 已配置 |
| In-App Purchase | StoreKit 2 代码已生成，Product ID 已硬编码 | ✅ 代码就绪 |
| WidgetKit | Widget extension 无需特殊 entitlement | ✅ 已配置 |

### 代码生成

| 模块 | 说明 | 状态 |
|------|------|------|
| 核心功能 | MVVM架构，Dashboard/Calendar/Symptoms/Trends/Settings/Lock/Paywall/Onboarding | ✅ 已完成 |
| PurchaseManager | StoreKit 2 非消耗型购买，Product ID: com.zzoutuo.LunaLock.pro | ✅ 已完成 |
| DataStore | 100% 本地存储，Codable JSON 序列化 | ✅ 已完成 |
| SecurityView | FaceID/PIN 锁 + 紧急摇动锁定 | ✅ 已完成 |
| QA迭代 | 5个编译问题已修复 | ✅ 已完成 |

### 部署

| 项目 | 说明 | 状态 |
|------|------|------|
| GitHub仓库 | https://github.com/asunnyboy861/LunaLock | ✅ 已完成 |
| GitHub Pages | 政策页面已部署 | ✅ 已完成 |
| Landing Page | https://asunnyboy861.github.io/LunaLock/ | ✅ 已完成 |
| Support Page | https://asunnyboy861.github.io/LunaLock/support.html | ✅ 已完成 |
| Privacy Policy | https://asunnyboy861.github.io/LunaLock/privacy.html | ✅ 已完成 |
| Terms of Use | https://asunnyboy861.github.io/LunaLock/terms.html | ✅ 已完成 |
| App Store元数据 | keytext.md 已生成验证 | ✅ 已完成 |
| 定价配置 | price.md 已生成 | ✅ 已完成 |

---

## 三、能力检测详情

> 以下为 PHASE 2 原始检测数据。

### Analysis
Based on operation guide analysis, the following capabilities are required:

- "通知" / "提醒" / "notification" / "alert" found in guide -> Push Notifications (local only)
- "健康" / "health" / "HealthKit" found in guide -> HealthKit (write-only, optional)
- "购买" / "premium" / "Pro" found in guide -> In-App Purchase (non-consumable)
- "FaceID" / "PIN" / "锁定" / "lock" found in guide -> Local Authentication
- "Widget" / "小组件" found in guide -> WidgetKit (no special entitlement needed)
- "导出" / "export" / "PDF" / "JSON" found in guide -> No special capability needed

### No Configuration Needed
- iCloud: Not required (100% local storage)
- Location Services: Not required
- Camera/Photo Library: Not required
- Siri: Not required
- Apple Watch: Not required for MVP
- Background Modes: Not required (no background fetch needed)
- Sign in with Apple: Not required (no accounts)

### Verification
- Build succeeded after configuration: YES
- iPhone 16 simulator: Build & Run passed
- iPad Pro 13-inch (M4) simulator: Build & Run passed
