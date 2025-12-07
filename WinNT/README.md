# WinNT - KeyKeyUserDBKit for .NET

[![.NET](https://github.com/vChewing/KeyKeyUserDBKit/actions/workflows/ci.yml/badge.svg)](https://github.com/vChewing/KeyKeyUserDBKit/actions/workflows/ci.yml)
[![NuGet](https://img.shields.io/nuget/v/vChewing.Utils.KeyKeyUserDBKit)](https://www.nuget.org/packages/vChewing.Utils.KeyKeyUserDBKit)
[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0)

這是 KeyKeyUserDBKit Swift Package 的 .NET 10 移植版本。

## 功能

- 🔓 解密 SQLite SEE AES-128 加密的使用者資料庫 (`SmartMandarinUserData.db`)
- 🔤 解碼注音符號 (Bopomofo) qstring 欄位
- 📖 讀取使用者詞彙資料（單字詞、雙字詞、候選字覆蓋）
- 🔄 支援 `IEnumerable<Gram>` 與 `IAsyncEnumerable<Gram>` 迭代

## 專案結構

```
WinNT/
├── KeyKeyUserDBKit.sln          # Visual Studio 解決方案檔
├── KeyKeyUserDBKit/             # 主要函式庫 (NuGet: vChewing.Utils.KeyKeyUserDBKit)
│   ├── Gram.cs                  # 語料結構體
│   ├── PhonaSet.cs              # 注音符號處理
│   ├── SEEDecryptor.cs          # SQLite SEE AES-128 解密器
│   └── UserDatabase.cs          # 使用者資料庫讀取器
├── KeyKeyUserDBKit.Tests/       # 單元測試 (xUnit)
│   ├── GramTests.cs
│   ├── PhonaSetTests.cs
│   ├── SEEDecryptorTests.cs
│   └── UserDatabaseTests.cs
└── KeyKeyDecryptCLI/            # 命令列工具 (kkdecrypt)
    └── Program.cs
```

## 系統需求

- .NET 10.0 SDK 或更新版本
- Windows / Linux / macOS

## 安裝

### NuGet

```bash
dotnet add package vChewing.Utils.KeyKeyUserDBKit
```

### 專案參考

```xml
<PackageReference Include="vChewing.Utils.KeyKeyUserDBKit" Version="1.0.0" />
```

## 建置

```bash
cd WinNT
dotnet build
```

## 測試

```bash
dotnet test
```

## 使用方式

### 作為函式庫

```csharp
using KeyKeyUserDBKit;

// 解密資料庫
using var decryptor = new SEEDecryptor();
await decryptor.DecryptFileAsync("SmartMandarinUserData.db", "decrypted.db");

// 讀取資料
using var db = new UserDatabase("decrypted.db");

// 取得所有語料資料
var allGrams = db.FetchAllGrams();

foreach (var gram in allGrams)
{
    Console.WriteLine($"{gram.Current} → {string.Join("-", gram.KeyArray)}");
}

// 或分別讀取各類型資料
var unigrams = db.FetchUnigrams();           // 單字詞
var bigrams = db.FetchBigrams();             // 雙字詞
var bigrams5 = db.FetchBigrams(5);           // 限制筆數
var overrides = db.FetchCandidateOverrides(); // 候選字覆蓋

// 使用 IEnumerable 迭代器逐筆讀取
foreach (var gram in db)
{
    Console.WriteLine(gram.Describe("-"));
}

// 使用 IAsyncEnumerable 非同步迭代器
await foreach (var gram in db)
{
    Console.WriteLine(gram.Current);
}
```

### 注音解碼

```csharp
// 解碼 qstring 為注音符號字串
var phonabet = PhonaSet.DecodeQueryString("0M");
// 結果: "ㄍㄨㄛˋ"

// 解碼為陣列
var keyArray = PhonaSet.DecodeQueryStringAsKeyArray("0M6C");
// 結果: ["ㄍㄨㄛˋ", "ㄖㄨㄥˊ"]

// 使用 PhonaSet 結構
var phona = new PhonaSet(
    consonant: PhonaSet.Consonant.ㄍ,
    semivowel: PhonaSet.Semivowel.ㄨ,
    vowel: PhonaSet.Vowel.ㄛ,
    intonation: PhonaSet.Intonation.Tone4
);
Console.WriteLine(phona.ToString()); // "ㄍㄨㄛˋ"
```

### 命令列工具

```bash
# 解密資料庫
kkdecrypt decrypt SmartMandarinUserData.db decrypted.db

# 傾印所有資料
kkdecrypt dump decrypted.db

# 或使用 dotnet run
dotnet run --project KeyKeyDecryptCLI -- decrypt SmartMandarinUserData.db decrypted.db
dotnet run --project KeyKeyDecryptCLI -- dump decrypted.db
```

## API 對照

| Swift                               | C#                                |
|-------------------------------------|-----------------------------------|
| `KeyKeyUserDBKit.Gram`              | `Gram`                            |
| `KeyKeyUserDBKit.PhonaSet`          | `PhonaSet`                        |
| `KeyKeyUserDBKit.SEEDecryptor`      | `SEEDecryptor`                    |
| `KeyKeyUserDBKit.UserDatabase`      | `UserDatabase`                    |
| `fetchUnigrams()`                   | `FetchUnigrams()`                 |
| `fetchBigrams(limit:)`              | `FetchBigrams(int? limit)`        |
| `fetchCandidateOverrides()`         | `FetchCandidateOverrides()`       |
| `fetchAllGrams()`                   | `FetchAllGrams()`                 |
| `makeIterator()`                    | `GetEnumerator()`                 |
| `for gram in db { }`                | `foreach (var gram in db) { }`   |
| `for await gram in db.async { }`    | `await foreach (var gram in db)` |

## 授權

本專案採用 [LGPL-3.0-or-later](../LICENSES/preferred/LGPL-3.0-or-later) 授權。

```
(c) 2025 and onwards The vChewing Project (LGPL v3.0 License or later).
This code is released under the SPDX-License-Identifier: `LGPL-3.0-or-later`.
```
