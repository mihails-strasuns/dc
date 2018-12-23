module dc.compilers.dmd;

import dc.compilers.base;

///
class DMD : Compiler
{
    import dc.utils.reporting;
    import dc.config;
    import dc.utils.path;

    private Path archive;
    private Path source;

    this (Config config, string ver)
    {
        super(config, ver);

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
            import dc.utils.platform : download;

            version (Windows)
            {
                download(
                    format("http://downloads.dlang.org/releases/2.x/%s/dmd.%s.windows.7z",
                        this.ver, this.ver),
                    this.archive
                );
            }
            else version (Posix)
            {
                download(
                    format("http://downloads.dlang.org/releases/2.x/%s/dmd.%s.linux.tar.xz",
                        this.ver, this.ver),
                    this.archive
                );
            }
        }

        if (!exists(this.source))
        {
            import dc.utils.platform : extract;
            extract(this.archive, this.source);
        }
    }

    override void enable ()
    {
        import std.file : write;
        import dc.utils.platform : link;

        auto source = this.source;
        mixin(report!("Switching to %s", source));

        write(this.config.paths.root ~ "USED", "dmd-" ~ this.ver);

        version (Windows)
        {
            auto bin_source = this.source ~ "dmd2" ~ "windows" ~ "bin";
            link(bin_source ~ "dmd.exe", this.config.paths.bin ~ "dmd.exe");
            link(bin_source ~ "dub.exe", this.config.paths.bin ~ "dub.exe");            

            auto lib_source = this.source ~ "dmd2" ~ "windows" ~ "lib64";
            link(
                lib_source ~ "phobos64.lib",
                this.config.paths.lib ~ "phobos64.lib"
            );
            link(
                lib_source ~ "curl.lib",
                this.config.paths.lib ~ "curl.lib"
            );
        }
        else version (Posix)
        {
            auto bin_source = this.source ~ "dmd2" ~ "linux" ~ "bin64";
            link(bin_source ~ "dmd", this.config.paths.bin ~ "dmd");
            link(bin_source ~ "dub", this.config.paths.bin ~ "dub");
            
            auto lib_source = this.source ~ "dmd2" ~ "linux" ~ "lib64";
            link(
                lib_source ~ "libphobos2.a",
                this.config.paths.lib ~ "libphobos2.a"
            );
        }

        auto import_source = this.source ~ "dmd2" ~ "src";
        link(
            import_source ~ "phobos/std",
            this.config.paths.imports ~ "std"
        );
        link(
            import_source ~ "druntime/import/core",
            this.config.paths.imports ~ "core"
        );
        link(
            import_source ~ "druntime/import/etc",
            this.config.paths.imports ~ "etc"
        );
        link(
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
        import dc.utils.platform : unlink;
        import std.file : remove;

        version (Windows)
        {
            unlink(this.config.paths.bin ~ "dmd.exe");
            unlink(this.config.paths.bin ~ "dub.exe");            
            unlink(this.config.paths.lib ~ "phobos64.lib");
            unlink(this.config.paths.lib ~ "curl.lib");

            remove(this.config.paths.bin ~ "sc.ini");
        }
        else version (Posix)
        {
            unlink(this.config.paths.bin ~ "dmd");
            unlink(this.config.paths.bin ~ "dub");            
            unlink(this.config.paths.lib ~ "libphobos2.a");
            
            remove(this.config.paths.bin ~ "dmd.conf");
        }

        unlink(this.config.paths.imports ~ "std");
        unlink(this.config.paths.imports ~ "core");
        unlink(this.config.paths.imports ~ "etc");
        unlink(this.config.paths.imports ~ "object.d");

        remove(this.config.paths.root ~ "USED");
    }
 }