// (c) 2025 and onwards The vChewing Project (LGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `LGPL-3.0-or-later`.

import Foundation
import KeyKeyUserDBKit

// MARK: - CLI Implementation

func printUsage() {
  let programName = CommandLine.arguments[0].split(separator: "/").last ?? "keykey-decrypt"
  print(
    """
    Yahoo! 奇摩輸入法 (KeyKey) 使用者資料庫解密工具

    用法: \(programName) <encrypted_db> [output_db]

    參數:
      encrypted_db  加密的資料庫檔案路徑
      output_db     輸出解密後的資料庫路徑 (選填，預設為 <原檔名>.decrypted.db)

    範例:
      \(programName) SmartMandarinUserData.db
      \(programName) SmartMandarinUserData.db decrypted.db
    """
  )
}

func showDecodedData(dbPath: String) {
  do {
    let db = try KeyKeyUserDBKit.UserDatabase(path: dbPath)

    print("\n=== 使用者單字詞 (user_unigrams) ===")
    let unigrams = try db.fetchUnigrams()
    for gram in unigrams {
      let reading = gram.keyArray.joined(separator: ",")
      print("  \(gram.current)\t\(reading)\t(\(gram.probability))")
    }

    print("\n=== 使用者雙字詞快取 (user_bigram_cache) ===")
    let bigrams = try db.fetchBigrams(limit: 10)
    for gram in bigrams {
      let reading = gram.keyArray.joined(separator: ",")
      print("  \(gram.previous ?? "")→\(gram.current)\t\(reading)")
    }

    print("\n=== 候選字覆蓋快取 (user_candidate_override_cache) ===")
    let overrides = try db.fetchCandidateOverrides()
    if overrides.isEmpty {
      print("  (空)")
    } else {
      for gram in overrides {
        let reading = gram.keyArray.joined(separator: ",")
        print("  \(gram.current)\t\(reading)")
      }
    }
  } catch {
    print("無法讀取資料: \(error.localizedDescription)")
  }
}

func main() {
  let args = CommandLine.arguments

  guard args.count >= 2 else {
    printUsage()
    exit(1)
  }

  let inputPath = args[1]
  let inputURL = URL(fileURLWithPath: inputPath)

  guard FileManager.default.fileExists(atPath: inputPath) else {
    print("錯誤：找不到檔案 \(inputPath)")
    exit(1)
  }

  let outputPath: String
  if args.count >= 3 {
    outputPath = args[2]
  } else {
    let baseName = inputURL.deletingPathExtension().lastPathComponent
    let directory = inputURL.deletingLastPathComponent()
    outputPath = directory.appendingPathComponent("\(baseName).decrypted.db").path
  }

  let outputURL = URL(fileURLWithPath: outputPath)

  do {
    print("解密 \(inputPath)")

    let encryptedData = try Data(contentsOf: inputURL)
    print("  檔案大小: \(encryptedData.count) bytes")
    print("  頁面數量: \(encryptedData.count / KeyKeyUserDBKit.SEEDecryptor.pageSize)")

    let decryptor = KeyKeyUserDBKit.SEEDecryptor()
    try decryptor.decryptFile(at: inputURL, to: outputURL)

    print("  輸出: \(outputPath)")
    print("  完成！")

    showDecodedData(dbPath: outputPath)

  } catch {
    print("解密失敗: \(error.localizedDescription)")
    exit(1)
  }
}

main()
