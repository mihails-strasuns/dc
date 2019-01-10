/**
    Common implementations bits reused between different compilers.
 */
module dc.compilers.common;

import dc.config;
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
    string representation;
    Path archive;
    Path source;
    PathPair[] files;

    void fetch (string url)
    {
        import std.experimental.logger;
        import std.file : exists;
        import std.format;

        if (!exists(archive))
        {
            infof("Downloading new compiler distribution for %s", this.representation);
            platform.download(url, this.archive);
        }

        if (!exists(source))
            platform.extract(archive, this.source);
    }

    void enable ()
    {
        infof("Setting %s as currently active compiler", this.representation);

        foreach (file; this.files)
            platform.enable(file.from, file.to);

        import std.file : write;
        write(config.paths.root ~ "USED", "dmd-" ~ this.representation);
    }

    void disable ()
    {
        import std.experimental.logger;
        infof("Disabling currently active compiler %s", this.representation);

        foreach (file; this.files)
            platform.disable(file.to);

        platform.disable(config.paths.root ~ "USED");
    }
}