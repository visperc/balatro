using System.Security.Cryptography;
using System.Text.Json;

namespace BalatroGodot.HotUpdate;

public sealed record HotUpdateManifest(
    string Version,
    string[] CompatibleBaseVersions,
    IReadOnlyList<HotUpdateFile> Files,
    string EntryConfig);

public sealed record HotUpdateFile(string Path, string Sha256, long Size);

public sealed class HotUpdateValidator
{
    private readonly JsonSerializerOptions _jsonOptions = new(JsonSerializerDefaults.Web)
    {
        PropertyNameCaseInsensitive = true
    };

    public HotUpdateManifest LoadManifest(string manifestPath)
    {
        return JsonSerializer.Deserialize<HotUpdateManifest>(File.ReadAllText(manifestPath), _jsonOptions)
            ?? throw new InvalidOperationException($"Invalid manifest: {manifestPath}");
    }

    public bool IsCompatible(HotUpdateManifest manifest, string baseVersion)
    {
        return manifest.CompatibleBaseVersions.Contains(baseVersion, StringComparer.OrdinalIgnoreCase);
    }

    public void ValidateFiles(string rootPath, HotUpdateManifest manifest)
    {
        foreach (var file in manifest.Files)
        {
            var fullPath = Path.Combine(rootPath, file.Path.Replace('/', Path.DirectorySeparatorChar));
            if (!File.Exists(fullPath))
            {
                throw new FileNotFoundException("Hot update file is missing.", fullPath);
            }

            using var stream = File.OpenRead(fullPath);
            using var sha256 = SHA256.Create();
            var hash = Convert.ToHexString(sha256.ComputeHash(stream)).ToLowerInvariant();
            if (!string.Equals(hash, file.Sha256, StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException($"Hash mismatch for hot update file: {file.Path}");
            }
        }
    }
}
