# KeyKeyUserDBKit

Swift: [![Swift](https://github.com/vChewing/KeyKeyUserDBKit/actions/workflows/ci.yml/badge.svg)](https://github.com/vChewing/KeyKeyUserDBKit/actions/workflows/ci.yml) [![Swift 6.1](https://img.shields.io/badge/Swift-6.1-orange.svg)](https://swift.org) [![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0)

Yahoo! 奇摩輸入法 (KeyKey) 使用者資料庫解密 Swift Package。

> **💻 C# 版**: `WinNT/` 目錄下含有 .NET 實作版本，詳見其自身的 [README.md](WinNT/README.md)。
>
> C#: [![.NET](https://github.com/vChewing/KeyKeyUserDBKit/actions/workflows/ci.yml/badge.svg)](https://github.com/vChewing/KeyKeyUserDBKit/actions/workflows/ci.yml) [![NuGet](https://img.shields.io/nuget/v/vChewing.Utils.KeyKeyUserDBKit)](https://www.nuget.org/packages/vChewing.Utils.KeyKeyUserDBKit) [![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0)

## 功能

- 🔓 解密 SQLite SEE AES-128 加密的使用者資料庫 (`SmartMandarinUserData.db`)
- 🔤 解碼注音符號 (Bopomofo) qstring 欄位
- 📖 讀取使用者詞彙資料（單字詞、雙字詞、候選字覆蓋）
- 🔄 支援 `Sequence` 與 `AsyncSequence` 迭代

## 專案結構

```
KeyKeyUserDBKit/
├── Package.swift                  # Swift Package 定義
├── CSQLite3/                      # SQLite3 C 模組
│   └── Sources/CSQLite3/
│       ├── sqlite3.c
│       └── include/
│           └── sqlite3.h
├── Sources/
│   ├── KeyKeyUserDBKit/           # 主要函式庫
│   │   ├── Gram.swift             # 語料結構體
│   │   ├── PhonaSet.swift         # 注音符號處理
│   │   ├── SEEDecryptor.swift     # SQLite SEE AES-128 解密器
│   │   └── UserDatabase.swift     # 使用者資料庫讀取器
│   └── KeyKeyDecryptCLI/          # 命令列工具 (keykey-decrypt)
│       └── main.swift
└── Tests/
    └── KeyKeyUserDBKitTests/      # 單元測試 (Swift Testing)
        ├── GramTests.swift
        ├── PhonaSetTests.swift
        ├── SEEDecryptorTests.swift
        └── UserDatabaseTests.swift
```

## 系統需求

- Swift 6.1 或更新版本
- macOS 10.13+ / Linux

## 安裝

### Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/vChewing/KeyKeyUserDBKit.git", from: "1.0.0")
]
```

```swift
// 在 target 中加入依賴
.target(
    name: "YourTarget",
    dependencies: ["KeyKeyUserDBKit"]
)
```

## 建置

```bash
swift build
```

## 測試

```bash
swift test
```

## 使用方式

### 作為函式庫

```swift
import KeyKeyUserDBKit

// 解密資料庫
let decryptor = KeyKeyUserDBKit.SEEDecryptor()
try decryptor.decryptFile(
    at: URL(fileURLWithPath: "SmartMandarinUserData.db"),
    to: URL(fileURLWithPath: "decrypted.db")
)

// 讀取資料
let db = try KeyKeyUserDBKit.UserDatabase(path: "decrypted.db")

// 取得所有語料資料
let allGrams = try db.fetchAllGrams()

for gram in allGrams {
    print("\(gram.current) → \(gram.keyArray.joined(separator: "-"))")
}

// 或分別讀取各類型資料
let unigrams = try db.fetchUnigrams()           // 單字詞
let bigrams = try db.fetchBigrams()             // 雙字詞
let bigrams5 = try db.fetchBigrams(limit: 5)    // 限制筆數
let overrides = try db.fetchCandidateOverrides() // 候選字覆蓋

// 使用 Sequence 迭代器逐筆讀取
for gram in db {
    print(gram.describe())
}

// 使用 AsyncSequence 非同步迭代
for await gram in db.async {
    print(gram.current)
}
```

### 注音解碼

```swift
// 解碼 qstring 為注音符號字串
let phonabet = KeyKeyUserDBKit.PhonaSet.decodeQueryString("0M")
// 結果: "ㄍㄨㄛˋ"

// 解碼為陣列
let keyArray = KeyKeyUserDBKit.PhonaSet.decodeQueryStringAsKeyArray("0M6C")
// 結果: ["ㄍㄨㄛˋ", "ㄖㄨㄥˊ"]

// 使用 PhonaSet 結構
let phona = KeyKeyUserDBKit.PhonaSet(
    consonant: .ㄍ,
    semivowel: .ㄨ,
    vowel: .ㄛ,
    intonation: .ˋ
)
print(phona.description) // "ㄍㄨㄛˋ"
```

### 命令列工具

```bash
# 編譯
swift build -c release

# 解密資料庫
.build/release/keykey-decrypt SmartMandarinUserData.db [output.db]

# 或使用 swift run
swift run keykey-decrypt SmartMandarinUserData.db decrypted.db
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

## 加密分析

此工具解密 Yahoo! 奇摩輸入法使用 SQLite SEE (SQLite Encryption Extension) 加密的資料庫：

- **加密演算法**: AES-128
- **模式**: 自訂 CTR-like (非標準 CCM)
- **頁面大小**: 1024 bytes
- **保留區域**: 32 bytes (16 bytes nonce + 16 bytes MAC)
- **密鑰**: `yahookeykeyuserd` (17 字元密碼的前 16 bytes)

### Keystream 產生

```
Counter Block = Nonce 的副本
Counter Block[4:8] = 4-byte little-endian counter
Keystream = AES-ECB(Key, Counter Block)
Counter 每 16 bytes 遞增 1
```

## 注音編碼

qstring 欄位使用 79 進位編碼：

```
order = (high_char - 48) * 79 + (low_char - 48)

syllable = consonant | (middle << 5) | (vowel << 7) | (tone << 11)
```

## 授權

本專案採用 [LGPL-3.0-or-later](LICENSES/preferred/LGPL-3.0-or-later) 授權。

```
(c) 2025 and onwards The vChewing Project (LGPL v3.0 License or later).
This code is released under the SPDX-License-Identifier: `LGPL-3.0-or-later`.
```
