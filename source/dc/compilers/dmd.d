module dc.compilers.dmd;

import dc.compilers.base;
import dc.utils.path;
import dc.paths;

///
class DMD : Compiler
{
    import dc.utils.reporting;

    private Path archive;
    private Path source;

    this (Paths paths, string ver)
    {
        super(paths, ver);

        this.archive = this.paths.versions ~ ("dmd-" ~ ver ~ ".tar.xz");
        this.source = this.paths.versions ~ ("dmd-" ~ ver);
    }

    override void fetch ()
    {
        import std.file : exists;
        import std.format;

        if (!exists(this.archive))
        {
            import dc.utils.platform : download;

            download(
                format("http://downloads.dlang.org/releases/2.x/%s/dmd.%s.linux.tar.xz",
                    this.ver, this.ver),
                this.archive
            );
        }

        if (!exists(this.source))
        {
            import dc.utils.platform : extract;

            extract(this.archive, this.paths.versions);
        }
    }

    override void enable ()
    {
        import std.file : write;
        import dc.utils.platform : link;

        auto source = this.source;
        mixin(report!("Switching to %s", source));

        write(this.paths.root ~ "USED", "dmd-" ~ this.ver);

        auto bin_source = this.source ~ "dmd2" ~ "linux" ~ "bin64";
        link(bin_source ~ "dmd", this.paths.bin ~ "dmd");
        link(bin_source ~ "dub", this.paths.bin ~ "dub");

        auto import_source = this.source ~ "dmd2" ~ "src";
        link(
            import_source ~ "phobos/std",
            this.paths.imports ~ "std"
        );
        link(
            import_source ~ "druntime/import/core",
            this.paths.imports ~ "core"
        );
        link(
            import_source ~ "druntime/import/etc",
            this.paths.imports ~ "etc"
        );
        link(
            import_source ~ "druntime/import/object.d",
            this.paths.imports ~ "object.d"
        );

        auto lib_source = this.source ~ "dmd2" ~ "linux" ~ "lib64";
        link(
            lib_source ~ "libphobos2.a",
            this.paths.lib ~ "libphobos2.a"
        );

        generateConfig();
    }

    void generateConfig ()
    {
        import std.stdio : File;

        auto config = new File(this.paths.bin ~ "dmd.conf", "w");
        config.writeln("[Environment]");
        config.writeln("DFLAGS=-I%@P%/../imports -L-L%@P%/../lib -L--export-dynamic -fPIC");
        config.close();
    }

    override void disable ()
    {
        import std.file : remove;

        remove(this.paths.bin ~ "dmd");
        remove(this.paths.bin ~ "dub");
        remove(this.paths.bin ~ "dmd.conf");

        remove(this.paths.imports ~ "std");
        remove(this.paths.imports ~ "core");
        remove(this.paths.imports ~ "etc");
        remove(this.paths.imports ~ "object.d");

        remove(this.paths.lib ~ "libphobos2.a");

        remove(this.paths.root ~ "USED");
    }
 }