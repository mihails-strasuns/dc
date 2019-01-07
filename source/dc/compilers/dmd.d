/**
    DMD-specific compiler implementation, check `dc.compiler.base` for some docs
 */
module dc.compilers.dmd;

import dc.compilers.base;

///
class DMD : Compiler
{
    import dc.config;
    import dc.utils.path;
    import dc.platform;

    private Path archive;
    private Path source;

    this (string ver)
    {
        super(ver);

        version (Windows)
            this.archive = config.paths.versions ~ ("dmd-" ~ ver ~ ".7z");
        else version (Posix)
            this.archive = config.paths.versions ~ ("dmd-" ~ ver ~ ".tar.xz");
        this.source = config.paths.versions ~ ("dmd-" ~ ver);
    }

    override string name ()
    {
        return "dmd";
    }

    override void fetch ()
    {
        import std.experimental.logger;
        import std.file : exists;
        import std.format;

        if (!exists(this.archive))
        {
            infof("Downloading new compiler distribution for %s", this.representation());

            version (Windows)
            {
                platform.download(
                    format("http://downloads.dlang.org/releases/2.x/%s/dmd.%s.windows.7z",
                        this.ver, this.ver),
                    this.archive
                );
            }
            else version (Posix)
            {
                platform.download(
                    format("http://downloads.dlang.org/releases/2.x/%s/dmd.%s.linux.tar.xz",
                        this.ver, this.ver),
                    this.archive
                );
            }
        }

        if (!exists(this.source))
        {
            platform.extract(this.archive, this.source);
        }
    }

    override void enable ()
    {
        import std.file : write;
        import std.experimental.logger;

        infof("Switching to %s", this.source);

        write(config.paths.root ~ "USED", "dmd-" ~ this.ver);

        version (Windows)
        {
            auto bin_source = this.source ~ "dmd2" ~ "windows" ~ "bin";
            platform.enable(bin_source ~ "dmd.exe", config.paths.bin ~ "dmd.exe");
            platform.enable(bin_source ~ "dub.exe", config.paths.bin ~ "dub.exe");

            auto lib_source = this.source ~ "dmd2" ~ "windows" ~ "lib64";
            platform.enable(
                lib_source ~ "phobos64.lib",
                config.paths.lib ~ "phobos64.lib"
            );
            platform.enable(
                lib_source ~ "curl.lib",
                config.paths.lib ~ "curl.lib"
            );
        }
        else version (Posix)
        {
            auto bin_source = this.source ~ "dmd2" ~ "linux" ~ "bin64";
            platform.enable(bin_source ~ "dmd", config.paths.bin ~ "dmd");
            platform.enable(bin_source ~ "dub", config.paths.bin ~ "dub");

            auto lib_source = this.source ~ "dmd2" ~ "linux" ~ "lib64";
            platform.enable(
                lib_source ~ "libphobos2.a",
                config.paths.lib ~ "libphobos2.a"
            );
        }

        auto import_source = this.source ~ "dmd2" ~ "src";
        platform.enable(
            import_source ~ "phobos/std",
            config.paths.imports ~ "std"
        );
        platform.enable(
            import_source ~ "druntime/import/core",
            config.paths.imports ~ "core"
        );
        platform.enable(
            import_source ~ "druntime/import/etc",
            config.paths.imports ~ "etc"
        );
        platform.enable(
            import_source ~ "druntime/import/object.d",
            config.paths.imports ~ "object.d"
        );

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
        import std.experimental.logger;
        infof("Disabling currently active compiler %s", this.representation());

        version (Windows)
        {
            platform.disable(config.paths.bin ~ "dmd.exe");
            platform.disable(config.paths.bin ~ "dub.exe");
            platform.disable(config.paths.lib ~ "phobos64.lib");
            platform.disable(config.paths.lib ~ "curl.lib");

            platform.disable(config.paths.bin ~ "sc.ini");
        }
        else version (Posix)
        {
            platform.disable(config.paths.bin ~ "dmd");
            platform.disable(config.paths.bin ~ "dub");
            platform.disable(config.paths.lib ~ "libphobos2.a");

            platform.disable(config.paths.bin ~ "dmd.conf");
        }

        platform.disable(config.paths.imports ~ "std");
        platform.disable(config.paths.imports ~ "core");
        platform.disable(config.paths.imports ~ "etc");
        platform.disable(config.paths.imports ~ "object.d");

        platform.disable(config.paths.root ~ "USED");
    }
 }