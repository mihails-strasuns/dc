/**
    DMD-specific compiler implementation, check `dc.compiler.api` for some docs
 */
module dc.compilers.dmd;

import dc.compilers.common;
import dc.compilers.api;

///
class DMD : Compiler
{
    import dc.config;
    import dc.utils.path;
    import dc.compilers.common;

    CompilerDistribution distribution;
    alias distribution this;

    this (string ver)
    {
        super("dmd", ver);

        version (Windows)
            auto archive = config.paths.versions ~ ("dmd-" ~ ver ~ ".7z");
        else version (Posix)
            auto archive = config.paths.versions ~ ("dmd-" ~ ver ~ ".tar.xz");

        auto source = config.paths.versions ~ ("dmd-" ~ ver);

        PathPair[] files;

        version (Windows)
        {
            auto bin_source = source ~ "dmd2" ~ "windows" ~ "bin";
            auto lib_source = source ~ "dmd2" ~ "windows" ~ "lib64";

            files ~= [
                PathPair(bin_source ~ "dmd.exe", config.paths.bin ~ "dmd.exe"),
                PathPair(bin_source ~ "dub.exe", config.paths.bin ~ "dub.exe"),
                PathPair(lib_source ~ "phobos64.lib", config.paths.lib ~ "phobos64.lib"),
                PathPair(lib_source ~ "curl.lib", config.paths.lib ~ "curl.lib")
            ];
        }
        else version (Posix)
        {
            auto bin_source = source ~ "dmd2" ~ "linux" ~ "bin64";
            auto lib_source = source ~ "dmd2" ~ "linux" ~ "lib64";

            files ~= [
                PathPair(bin_source ~ "dmd", config.paths.bin ~ "dmd"),
                PathPair(bin_source ~ "dub", config.paths.bin ~ "dub"),
                PathPair(lib_source ~ "libphobos2.a", config.paths.lib ~ "libphobos2.a")
            ];
        }

        auto import_source = source ~ "dmd2" ~ "src";

        files ~= [
            PathPair(import_source ~ "phobos/std", config.paths.imports ~ "std"),
            PathPair(import_source ~ "druntime/import/core", config.paths.imports ~ "core"),
            PathPair(import_source ~ "druntime/import/etc", config.paths.imports ~ "etc"),
            PathPair(import_source ~ "druntime/import/object.d", config.paths.imports ~ "object.d"),
        ];

        this.distribution = CompilerDistribution(
            this.representation(),
            archive,
            source,
            files
        );
    }

    override void fetch ()
    {
        import std.format;

        version (Windows)
        {
            this.distribution.fetch(
                format("http://downloads.dlang.org/releases/2.x/%s/dmd.%s.windows.7z",
                    this.ver, this.ver)
            );
        }
        else version (Posix)
        {
            this.distribution.fetch(
                format("http://downloads.dlang.org/releases/2.x/%s/dmd.%s.linux.tar.xz",
                    this.ver, this.ver)
            );
        }
    }

    override void enable ()
    {
        this.distribution.enable();
        generateConfig();
    }

    void generateConfig ()
    {
        import std.stdio : File;

        version (Windows)
        {
            auto config = new File(config.paths.bin ~ "sc.ini", "w");
            config.writeln("[Environment]");
            config.writeln(`DFLAGS="-I%@P%\..\imports" -m64`);
            config.writeln(`LIB="%@P%\..\lib"`);
            config.close();
        }
        else version (Posix)
        {
            auto config = new File(config.paths.bin ~ "dmd.conf", "w");
            config.writeln("[Environment]");
            config.writeln("DFLAGS=-I%@P%/../imports -L-L%@P%/../lib -L--export-dynamic -fPIC");
            config.close();
        }
    }

    override void disable ()
    {
        this.distribution.disable();
    }
 }