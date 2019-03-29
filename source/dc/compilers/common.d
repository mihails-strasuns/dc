/**
    Common implementations bits reused between different compilers.
 */
module dc.compilers.common;

import dc.utils.path;
import dc.platform;
import std.experimental.logger;

struct PathPair
{
    Path from;
    Path to;
}

struct CompilerDistribution
{
    private Path[] active;

    string representation;

    this (string repr)
    {
        this.representation = repr;
    }

    void registerExistingFiles (Path[] files)
    {
        this.active ~= files;
    }

    void fetch (string url, Path archive, Path source)
    {
        import std.file : exists;
        import std.format;

        if (!exists(archive))
        {
            infof("Downloading new compiler distribution for %s", this.representation);
            platform.download(url, archive);
        }

        if (!exists(source))
            platform.extract(archive, source);
    }

    void enable (PathPair[] files, Path root)
    {
        infof("Setting %s as currently active compiler", this.representation);

        foreach (file; files)
        {
            platform.enable(file.from, file.to);
            this.active ~= file.to;
        }

        import std.stdio : File;

        auto used = File(root ~ "USED", "w");
        used.writeln(this.representation);
        foreach (file; this.active)
            used.writeln(file.toString());
        used.close();
    }

    void disable (Path root)
    {
        infof("Disabling currently active compiler %s", this.representation);

        foreach (file; this.active)
            platform.disable(file);

        platform.disable(root ~ "USED");
    }
}

void addAll (Path from, Path to, ref PathPair[] files, string pattern = "")
{
    import std.file : dirEntries, SpanMode;
    import std.path : relativePath;

    if (pattern.length)
    {
        foreach (entry; dirEntries(from, pattern, SpanMode.depth))
            files ~= PathPair(Path(entry.name), to ~ relativePath(entry.name, from));
    }
    else
    {
        foreach (entry; dirEntries(from, SpanMode.depth))
            files ~= PathPair(Path(entry.name), to ~ relativePath(entry.name, from));
    }
}
