/**
    LDC-specific compiler implementation, check `dc.compiler.base` for some docs
 */
module dc.compilers.ldc;

import dc.compilers.api;

///
class LDC : Compiler
{
    import dc.utils.path;
    import dc.compilers.common;

    this (string ver, Path root)
    {
        auto dirs = SubDirectories(root);

        version (Windows)
            auto archive = dirs.versions ~ ("ldc-" ~ ver ~ ".7z");
        else version (Posix)
            auto archive = dirs.versions ~ ("ldc-" ~ ver ~ ".tar.xz");

        auto source = dirs.versions ~ ("ldc-" ~ ver);

        super(Compiler.Config(root, source, archive, "ldc", ver));
    }

    override void fetch ()
    {
        import std.format;

        version (Windows)
        {
            this.distribution.fetch(
                format("https://github.com/ldc-developers/ldc/releases/download/v%s/ldc2-%s-windows-x64.7z",
                    this.config.ver, this.config.ver),
                this.config.archive,
                this.config.source
            );
        }
        else version (Posix)
        {
            this.distribution.fetch(
                format("https://github.com/ldc-developers/ldc/releases/download/v%s/ldc2-%s-linux-x86_64.tar.xz",
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
            auto dir = this.config.source ~ ("ldc2-" ~ this.config.ver ~ "-windows-x64");
        else version (Posix)
            auto dir = this.config.source ~ ("ldc2-" ~ this.config.ver ~ "-linux-x86_64");

        auto bin_source = dir ~ "bin";
        auto lib_source = dir ~ "lib";
        auto import_source = dir ~ "import";

        addAll(bin_source, dirs.bin, files);
        version(Windows)
            enum lib_pattern = "*.lib";
        else
            enum lib_pattern = "*.a";
        addAll(lib_source, dirs.lib, files, lib_pattern);
        addShallow(import_source, dirs.imports, files);

        this.distribution.enable(files, this.config.root);
        generateConfig();
    }

    void generateConfig ()
    {
        import std.stdio : File;

        auto config = new File(this.config.root ~ "bin" ~ "ldc2.conf", "w");
        config.write(
            q{
                default:
                {
                    switches = [
                        "-defaultlib=phobos2-ldc,druntime-ldc",
                        "-link-defaultlib-shared=false",
                    ];
                    post-switches = [
                        "-I%%ldcbinarypath%%/../imports",
                    ];
                    lib-dirs = [
                        "%%ldcbinarypath%%/../lib",
                    ];
                    rpath = "";
                };
            }
        );
        config.close();
    }

    override void disable ()
    {
        this.distribution.disable(this.config.root);
    }

    override Path distributionBinPath ()
    {
        version (Windows)
        {
            return this.config.source ~ ("ldc2-" ~ this.config.ver ~
                "-windows-x64") ~ "bin";
        }
        else version (Posix)
        {
            return this.config.source ~ ("ldc2-" ~ this.config.ver ~
                "-linux-x86_64") ~ "bin";
        }
    }
 }
