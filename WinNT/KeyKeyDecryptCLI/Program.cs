// (c) 2025 and onwards The vChewing Project (LGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `LGPL-3.0-or-later`.

using KeyKeyUserDBKit;

if (args.Length < 1) {
  PrintUsage();
  return 1;
}

try {
  switch (args[0].ToLowerInvariant()) {
    case "decrypt":
      return await HandleDecrypt(args);
    case "dump":
      return await HandleDump(args);
    case "--help":
    case "-h":
      PrintUsage();
      return 0;
    default:
      Console.Error.WriteLine($"Unknown command: {args[0]}");
      PrintUsage();
      return 1;
  }
} catch (Exception ex) {
  Console.Error.WriteLine($"Error: {ex.Message}");
  return 1;
}

static void PrintUsage() {
  Console.WriteLine("""
        KeyKey User Database Tool
        Usage: kkdecrypt <command> [options]

        Commands:
          decrypt <input> <output>    Decrypt a KeyKey user database
          dump <dbpath>               Dump all grams from a decrypted database

        Options:
          -h, --help                  Show this help message

        Examples:
          kkdecrypt decrypt SmartMandarinUserData.db decrypted.db
          kkdecrypt dump decrypted.db
        """);
}

static async Task<int> HandleDecrypt(string[] args) {
  if (args.Length < 3) {
    Console.Error.WriteLine("Usage: kkdecrypt decrypt <input> <output>");
    return 1;
  }

  var inputPath = args[1];
  var outputPath = args[2];

  if (!File.Exists(inputPath)) {
    Console.Error.WriteLine($"Input file not found: {inputPath}");
    return 1;
  }

  Console.WriteLine($"Decrypting {inputPath} -> {outputPath}");

  using var decryptor = new SEEDecryptor();
  await decryptor.DecryptFileAsync(inputPath, outputPath);

  Console.WriteLine("Decryption complete.");
  return 0;
}

static async Task<int> HandleDump(string[] args) {
  if (args.Length < 2) {
    Console.Error.WriteLine("Usage: kkdecrypt dump <dbpath>");
    return 1;
  }

  var dbPath = args[1];

  if (!File.Exists(dbPath)) {
    Console.Error.WriteLine($"Database file not found: {dbPath}");
    return 1;
  }

  using var db = new UserDatabase(dbPath);

  var unigramCount = 0;
  var bigramCount = 0;
  var overrideCount = 0;

  Console.WriteLine("=== Unigrams ===");
  foreach (var gram in db.FetchUnigrams()) {
    Console.WriteLine(gram);
    unigramCount++;
  }

  Console.WriteLine("\n=== Bigrams ===");
  foreach (var gram in db.FetchBigrams()) {
    Console.WriteLine(gram);
    bigramCount++;
  }

  Console.WriteLine("\n=== Candidate Overrides ===");
  foreach (var gram in db.FetchCandidateOverrides()) {
    Console.WriteLine(gram);
    overrideCount++;
  }

  Console.WriteLine($"\n=== Summary ===");
  Console.WriteLine($"Unigrams: {unigramCount}");
  Console.WriteLine($"Bigrams: {bigramCount}");
  Console.WriteLine($"Candidate Overrides: {overrideCount}");
  Console.WriteLine($"Total: {unigramCount + bigramCount + overrideCount}");

  await Task.CompletedTask;
  return 0;
}
