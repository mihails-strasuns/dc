/**
    LDC-specific compiler implementation, check `dc.compiler.base` for some docs
 */
module dc.compilers.ldc;

import dc.compilers.api;

///
class LDC : Compiler
{
    import dc.config;
    import dc.utils.path;
    import dc.compilers.common;

    CompilerDistribution distribution;
    alias distribution this;

    this (string ver)
    {
        super("ldc", ver);

        version (Windows)
            auto archive = config.paths.versions ~ ("ldc-" ~ ver ~ ".7z");
        else version (Posix)
            auto archive = config.paths.versions ~ ("ldc-" ~ ver ~ ".tar.xz");

        auto source = config.paths.versions ~ ("ldc-" ~ ver);

        PathPair[] files;

        version (Windows)
            auto dir = source ~ ("ldc2-" ~ this.ver ~ "-windows-x64");
        else version (Posix)
            auto dir = source ~ ("ldc2-" ~ this.ver ~ "-linux-x86_64");
        auto bin_source = dir ~ "bin";
        auto lib_source = dir ~ "lib";
        auto import_source = dir ~ "import";

        version (Windows)
        {
            files ~= [
                PathPair(bin_source ~ "ldc2.exe", config.paths.bin ~ "ldc2.exe"),
                PathPair(bin_source ~ "ldmd2.exe", config.paths.bin ~ "ldmd2.exe"),
                PathPair(bin_source ~ "rdmd.exe", config.paths.bin ~ "rdmd.exe"),
                PathPair(bin_source ~ "dub.exe", config.paths.bin ~ "dub.exe"),

                PathPair(lib_source ~ "druntime-ldc.lib", config.paths.lib ~ "druntime-ldc.lib"),
                PathPair(lib_source ~ "druntime-ldc-debug.lib", config.paths.lib ~ "druntime-ldc-debug.lib"),
                PathPair(lib_source ~ "druntime-ldc-lto.lib", config.paths.lib ~ "druntime-ldc-lto.lib"),
                PathPair(lib_source ~ "phobos2-ldc.lib", config.paths.lib ~ "phobos2-ldc.lib"),
                PathPair(lib_source ~ "phobos2-ldc-debug.lib", config.paths.lib ~ "phobos2-ldc-debug.lib"),
                PathPair(lib_source ~ "phobos2-ldc-lto.lib", config.paths.lib ~ "phobos2-ldc-lto.lib"),
                PathPair(lib_source ~ "ldc-jit-rt.lib", config.paths.lib ~ "ldc-jit-rt.lib"),
                PathPair(lib_source ~ "ldc-jit.lib", config.paths.lib ~ "ldc-jit.lib"),
                PathPair(lib_source ~ "ldc_rt.asan.lib", config.paths.lib ~ "ldc_rt.asan.lib"),
                PathPair(lib_source ~ "ldc_rt.builtins.lib", config.paths.lib ~ "ldc_rt.builtins.lib"),
                PathPair(lib_source ~ "ldc_rt.profile.lib", config.paths.lib ~ "ldc_rt.profile.lib"),
                PathPair(lib_source ~ "curl.lib", config.paths.lib ~ "curl.lib"),
                PathPair(lib_source ~ "mingw", config.paths.lib ~ "mingw"),
            ];
        }
        else version (Posix)
        {
            files ~= [
                 PathPair(bin_source ~ "ldc2", config.paths.bin ~ "ldc2"),
                 PathPair(bin_source ~ "ldmd2", config.paths.bin ~ "ldmd2"),
                 PathPair(bin_source ~ "rdmd", config.paths.bin ~ "rdmd"),
                 PathPair(bin_source ~ "dub", config.paths.bin ~ "dub"),

                 PathPair(lib_source ~ "libdruntime-ldc.a", config.paths.lib ~
                         "libdruntime-ldc.a"),
                 PathPair(lib_source ~ "libdruntime-ldc-debug.a",
                         config.paths.lib ~ "libdruntime-ldc-debug.a"),
                 PathPair(lib_source ~ "libdruntime-ldc-lto.a", config.paths.lib
                         ~ "libdruntime-ldc-lto.a"),
                 PathPair(lib_source ~ "libphobos2-ldc.a", config.paths.lib ~
                         "libphobos2-ldc.a"),
                 PathPair(lib_source ~ "libphobos2-ldc-debug.a",
                         config.paths.lib ~ "libphobos2-ldc-debug.a"),
                 PathPair(lib_source ~ "libphobos2-ldc-lto.a", config.paths.lib
                         ~ "libphobos2-ldc-lto.a"),
                 PathPair(lib_source ~ "libldc-jit-rt.a", config.paths.lib ~
                         "libldc-jit-rt.a"),
                 PathPair(lib_source ~ "libldc-jit.a", config.paths.lib ~
                         "libldc-jit.a"),
                 PathPair(lib_source ~ "libldc_rt.asan.a", config.paths.lib ~
                         "libldc_rt.asan.a"),
                 PathPair(lib_source ~ "libldc_rt.builtins.a", config.paths.lib
                         ~ "libldc_rt.builtins.a"),
                 PathPair(lib_source ~ "libldc_rt.profile.a", config.paths.lib ~
                         "libldc_rt.profile.a"),
            ];

        }

        files ~= [
            PathPair(import_source ~ "core", config.paths.imports ~ "core"),
            PathPair(import_source ~ "std", config.paths.imports ~ "std"),
            PathPair(import_source ~ "etc", config.paths.imports ~ "etc"),
            PathPair(import_source ~ "ldc", config.paths.imports ~ "ldc"),
            PathPair(import_source ~ "object.d", config.paths.imports ~ "object.d"),
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
                format("https://github.com/ldc-developers/ldc/releases/download/v%s/ldc2-%s-windows-x64.7z",
                    this.ver, this.ver)
            );
        }
        else version (Posix)
        {
            this.distribution.fetch(
                format("https://github.com/ldc-developers/ldc/releases/download/v%s/ldc2-%s-linux-x86_64.tar.xz",
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

        auto config = new File(config.paths.bin ~ "ldc2.conf", "w");
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
        this.distribution.disable();
    }
 }
