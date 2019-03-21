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

    CompilerDistribution distribution;
    alias distribution this;

    this (string ver, Path root)
    {
        super(root, "ldc", ver);

        auto dirs = SubDirectories(root);

        version (Windows)
            auto archive = dirs.versions ~ ("ldc-" ~ ver ~ ".7z");
        else version (Posix)
            auto archive = dirs.versions ~ ("ldc-" ~ ver ~ ".tar.xz");

        auto source = dirs.versions ~ ("ldc-" ~ ver);

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
                PathPair(bin_source ~ "ldc2.exe", dirs.bin ~ "ldc2.exe"),
                PathPair(bin_source ~ "ldmd2.exe", dirs.bin ~ "ldmd2.exe"),
                PathPair(bin_source ~ "rdmd.exe", dirs.bin ~ "rdmd.exe"),
                PathPair(bin_source ~ "dub.exe", dirs.bin ~ "dub.exe"),

                PathPair(lib_source ~ "druntime-ldc.lib", dirs.lib ~ "druntime-ldc.lib"),
                PathPair(lib_source ~ "druntime-ldc-debug.lib", dirs.lib ~ "druntime-ldc-debug.lib"),
                PathPair(lib_source ~ "druntime-ldc-lto.lib", dirs.lib ~ "druntime-ldc-lto.lib"),
                PathPair(lib_source ~ "phobos2-ldc.lib", dirs.lib ~ "phobos2-ldc.lib"),
                PathPair(lib_source ~ "phobos2-ldc-debug.lib", dirs.lib ~ "phobos2-ldc-debug.lib"),
                PathPair(lib_source ~ "phobos2-ldc-lto.lib", dirs.lib ~ "phobos2-ldc-lto.lib"),
                PathPair(lib_source ~ "ldc-jit-rt.lib", dirs.lib ~ "ldc-jit-rt.lib"),
                PathPair(lib_source ~ "ldc-jit.lib", dirs.lib ~ "ldc-jit.lib"),
                PathPair(lib_source ~ "ldc_rt.asan.lib", dirs.lib ~ "ldc_rt.asan.lib"),
                PathPair(lib_source ~ "ldc_rt.builtins.lib", dirs.lib ~ "ldc_rt.builtins.lib"),
                PathPair(lib_source ~ "ldc_rt.profile.lib", dirs.lib ~ "ldc_rt.profile.lib"),
                PathPair(lib_source ~ "curl.lib", dirs.lib ~ "curl.lib"),
                PathPair(lib_source ~ "mingw", dirs.lib ~ "mingw"),
            ];
        }
        else version (Posix)
        {
            files ~= [
                 PathPair(bin_source ~ "ldc2", dirs.bin ~ "ldc2"),
                 PathPair(bin_source ~ "ldmd2", dirs.bin ~ "ldmd2"),
                 PathPair(bin_source ~ "rdmd", dirs.bin ~ "rdmd"),
                 PathPair(bin_source ~ "dub", dirs.bin ~ "dub"),

                 PathPair(lib_source ~ "libdruntime-ldc.a", dirs.lib ~
                         "libdruntime-ldc.a"),
                 PathPair(lib_source ~ "libdruntime-ldc-debug.a",
                         dirs.lib ~ "libdruntime-ldc-debug.a"),
                 PathPair(lib_source ~ "libdruntime-ldc-lto.a", dirs.lib
                         ~ "libdruntime-ldc-lto.a"),
                 PathPair(lib_source ~ "libphobos2-ldc.a", dirs.lib ~
                         "libphobos2-ldc.a"),
                 PathPair(lib_source ~ "libphobos2-ldc-debug.a",
                         dirs.lib ~ "libphobos2-ldc-debug.a"),
                 PathPair(lib_source ~ "libphobos2-ldc-lto.a", dirs.lib
                         ~ "libphobos2-ldc-lto.a"),
                 PathPair(lib_source ~ "libldc-jit-rt.a", dirs.lib ~
                         "libldc-jit-rt.a"),
                 PathPair(lib_source ~ "libldc-jit.a", dirs.lib ~
                         "libldc-jit.a"),
                 PathPair(lib_source ~ "libldc_rt.asan.a", dirs.lib ~
                         "libldc_rt.asan.a"),
                 PathPair(lib_source ~ "libldc_rt.builtins.a", dirs.lib
                         ~ "libldc_rt.builtins.a"),
                 PathPair(lib_source ~ "libldc_rt.profile.a", dirs.lib ~
                         "libldc_rt.profile.a"),
            ];

        }

        files ~= [
            PathPair(import_source ~ "core", dirs.imports ~ "core"),
            PathPair(import_source ~ "std", dirs.imports ~ "std"),
            PathPair(import_source ~ "etc", dirs.imports ~ "etc"),
            PathPair(import_source ~ "ldc", dirs.imports ~ "ldc"),
            PathPair(import_source ~ "object.d", dirs.imports ~ "object.d"),
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
        this.distribution.enable(this.root);
        generateConfig();
    }

    void generateConfig ()
    {
        import std.stdio : File;

        auto config = new File(this.root ~ "bin" ~ "ldc2.conf", "w");
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
        this.distribution.disable(this.root);
    }
 }
