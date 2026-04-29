using BalatroGodot.Data;

namespace BalatroGodot.HotUpdate;

public sealed class ContentVersionSelector
{
    public string SelectContentRoot(string builtinRoot, string userHotfixRoot, string baseVersion)
    {
        if (!Directory.Exists(userHotfixRoot))
        {
            return builtinRoot;
        }

        var validator = new HotUpdateValidator();
        var candidates = Directory.GetDirectories(userHotfixRoot)
            .OrderByDescending(Path.GetFileName, StringComparer.OrdinalIgnoreCase);

        foreach (var candidate in candidates)
        {
            var manifestPath = Path.Combine(candidate, "manifest.json");
            if (!File.Exists(manifestPath)) continue;

            try
            {
                var manifest = validator.LoadManifest(manifestPath);
                if (!validator.IsCompatible(manifest, baseVersion)) continue;
                validator.ValidateFiles(candidate, manifest);
                return candidate;
            }
            catch
            {
                // Broken updates are ignored so the built-in catalog can still boot.
            }
        }

        return builtinRoot;
    }
}
