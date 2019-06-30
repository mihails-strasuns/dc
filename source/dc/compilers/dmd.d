/**
    DMD-specific compiler implementation, check `dc.compiler.api` for some docs
 */
module dc.compilers.dmd;

import dc.compilers.common;
import dc.compilers.api;

///
class DMD : Compiler
{
    import dc.utils.path;

    this (string ver, Path root)
    {
        auto dirs = SubDirectories(root);

        version (Windows)
            auto archive = dirs.versions ~ ("dmd-" ~ ver ~ ".7z");
        else version (Posix)
            auto archive = dirs.versions ~ ("dmd-" ~ ver ~ ".tar.xz");

        auto source = dirs.versions ~ ("dmd-" ~ ver);

        super(Compiler.Config(root, source, archive, "dmd", ver));
    }

    override void fetch ()
    {
        import std.format;

        version (Windows)
        {
            this.distribution.fetch(
                format("http://downloads.dlang.org/releases/2.x/%s/dmd.%s.windows.7z",
                    this.config.ver, this.config.ver),
                this.config.archive,
                this.config.source
            );
        }
        else version (Posix)
        {
            this.distribution.fetch(
                format("http://downloads.dlang.org/releases/2.x/%s/dmd.%s.linux.tar.xz",
                    this.config.ver, this.config.ver),
                this.config.archive,
                this.config.source
            );
        }
    }

    override void enable ()
    {
        auto dirs = SubDirectories(this.config.root);

        PathPair[] files;

        version (Windows)
        {
            auto bin_source = this.config.source ~ "dmd2" ~ "windows" ~ "bin";
            auto lib_source = this.config.source ~ "dmd2" ~ "windows" ~ "lib64";
        }
        else version (Posix)
        {
            auto bin_source = this.config.source ~ "dmd2" ~ "linux" ~ "bin64";
            auto lib_source = this.config.source ~ "dmd2" ~ "linux" ~ "lib64";
        }

        addAll(bin_source, dirs.bin, files);

        version(Windows)
            enum lib_pattern = "*.lib";
        else
            enum lib_pattern = "*.a";
        addAll(lib_source, dirs.lib, files, lib_pattern);

        auto phobos_source = this.config.source ~ "dmd2" ~ "src" ~ "phobos" ~ "std";
        auto druntime_source = this.config.source ~ "dmd2" ~ "src" ~ "druntime" ~ "import";

        files ~= PathPair(phobos_source, dirs.imports ~ "std");
        addShallow(druntime_source, dirs.imports, files);

        this.distribution.enable(files, this.config.root);
        generateConfig();
    }

    void generateConfig ()
    {
        import std.stdio : File;

        version (Windows)
        {
            auto config = new File(this.config.root ~ "bin" ~ "sc.ini", "w");
            config.writeln("[Environment]");
            config.writeln(`DFLAGS="-I%@P%\..\imports" -m64`);
            config.writeln(`LIB="%@P%\..\lib"`);
            config.close();
        }
        else version (Posix)
        {
            auto config = new File(this.config.root ~ "bin" ~ "dmd.conf", "w");
            config.writeln("[Environment]");
            config.writeln("DFLAGS=-I%@P%/../imports -L-L%@P%/../lib -L--export-dynamic -fPIC");
            config.close();
        }
    }

    override void disable ()
    {
        this.distribution.disable(this.config.root);
    }

    override Path distributionBinPath ()
    {
        version (Windows)
            return this.config.source ~ "dmd2" ~ "windows" ~ "bin";
        else
            return this.config.source ~ "dmd2" ~ "linux" ~ "bin64";
    }
 }
