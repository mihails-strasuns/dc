module dc.compilers.dmd;

import dc.compilers.base;

///
class DMD : Compiler
{
    import dc.utils.reporting;
    import dc.config;
    import dc.utils.path;
    import dc.platform.api;

    private Path archive;
    private Path source;

    this (Config config, Platform platform, string ver)
    {
        super(config, platform, ver);

        version (Windows)
            this.archive = this.config.paths.versions ~ ("dmd-" ~ ver ~ ".7z");
        else version (Posix)
            this.archive = this.config.paths.versions ~ ("dmd-" ~ ver ~ ".tar.xz");
        this.source = this.config.paths.versions ~ ("dmd-" ~ ver);
    }

    override void fetch ()
    {
        import std.file : exists;
        import std.format;

        if (!exists(this.archive))
        {            
            version (Windows)
            {
                this.platform.download(
                    format("http://downloads.dlang.org/releases/2.x/%s/dmd.%s.windows.7z",
                        this.ver, this.ver),
                    this.archive
                );
            }
            else version (Posix)
            {
                this.platform.download(
                    format("http://downloads.dlang.org/releases/2.x/%s/dmd.%s.linux.tar.xz",
                        this.ver, this.ver),
                    this.archive
                );
            }
        }

        if (!exists(this.source))
        {            
            this.platform.extract(this.archive, this.source);
        }
    }

    override void enable ()
    {
        import std.file : write;

        auto source = this.source;
        mixin(report!("Switching to %s", source));

        write(this.config.paths.root ~ "USED", "dmd-" ~ this.ver);

        version (Windows)
        {
            auto bin_source = this.source ~ "dmd2" ~ "windows" ~ "bin";
            this.platform.enable(bin_source ~ "dmd.exe", this.config.paths.bin ~ "dmd.exe");
            this.platform.enable(bin_source ~ "dub.exe", this.config.paths.bin ~ "dub.exe");            

            auto lib_source = this.source ~ "dmd2" ~ "windows" ~ "lib64";
            this.platform.enable(
                lib_source ~ "phobos64.lib",
                this.config.paths.lib ~ "phobos64.lib"
            );
            this.platform.enable(
                lib_source ~ "curl.lib",
                this.config.paths.lib ~ "curl.lib"
            );
        }
        else version (Posix)
        {
            auto bin_source = this.source ~ "dmd2" ~ "linux" ~ "bin64";
            this.platform.enable(bin_source ~ "dmd", this.config.paths.bin ~ "dmd");
            this.platform.enable(bin_source ~ "dub", this.config.paths.bin ~ "dub");
            
            auto lib_source = this.source ~ "dmd2" ~ "linux" ~ "lib64";
            this.platform.enable(
                lib_source ~ "libphobos2.a",
                this.config.paths.lib ~ "libphobos2.a"
            );
        }

        auto import_source = this.source ~ "dmd2" ~ "src";
        this.platform.enable(
            import_source ~ "phobos/std",
            this.config.paths.imports ~ "std"
        );
        this.platform.enable(
            import_source ~ "druntime/import/core",
            this.config.paths.imports ~ "core"
        );
        this.platform.enable(
            import_source ~ "druntime/import/etc",
            this.config.paths.imports ~ "etc"
        );
        this.platform.enable(
            import_source ~ "druntime/import/object.d",
            this.config.paths.imports ~ "object.d"
        );

        generateConfig();
    }

    void generateConfig ()
    {
        import std.stdio : File;

        version (Windows)
        {
            auto config = new File(this.config.paths.bin ~ "sc.ini", "w");
            config.writeln("[Environment]");
            config.writeln(`DFLAGS="-I%@P%\..\imports" -m64`);
            config.writeln(`LIB="%@P%\..\lib"`);
            config.close();
        }
        else version (Posix)
        {
            auto config = new File(this.config.paths.bin ~ "dmd.conf", "w");
            config.writeln("[Environment]");
            config.writeln("DFLAGS=-I%@P%/../imports -L-L%@P%/../lib -L--export-dynamic -fPIC");
            config.close();
        }
    }

    override void disable ()
    {
        version (Windows)
        {
            this.platform.disable(this.config.paths.bin ~ "dmd.exe");
            this.platform.disable(this.config.paths.bin ~ "dub.exe");            
            this.platform.disable(this.config.paths.lib ~ "phobos64.lib");
            this.platform.disable(this.config.paths.lib ~ "curl.lib");

            this.platform.disable(this.config.paths.bin ~ "sc.ini");
        }
        else version (Posix)
        {
            this.platform.disable(this.config.paths.bin ~ "dmd");
            this.platform.disable(this.config.paths.bin ~ "dub");            
            this.platform.disable(this.config.paths.lib ~ "libphobos2.a");
            
            this.platform.disable(this.config.paths.bin ~ "dmd.conf");
        }

        this.platform.disable(this.config.paths.imports ~ "std");
        this.platform.disable(this.config.paths.imports ~ "core");
        this.platform.disable(this.config.paths.imports ~ "etc");
        this.platform.disable(this.config.paths.imports ~ "object.d");

        this.platform.disable(this.config.paths.root ~ "USED");
    }
 }