module dc.app;

import dc.sandbox;
import dc.config;
import dc.utils.path;
import dc.utils.platform : checkRequirements;

void main ()
{
    Config config;
    config.paths.root = Path("sandbox");
    config.paths.bin = config.paths.root ~ "bin";
    config.paths.lib = config.paths.root ~ "lib";
    config.paths.versions = config.paths.root ~ "versions";
    config.paths.imports = config.paths.root ~ "imports";

    version (Windows)
    {
        config.path7z = `C:\Program Files\7-Zip`;
        // Add 7z.exe location to PATH for the current process so that it can be called
        // from shell scripts without having to access app config.
        import std.process;
        environment["path"] = environment["path"] ~ ";" ~ config.path7z ~ ";";
    }

    checkRequirements();
    initSandbox(config.paths);
    auto compiler_str = "dmd-2.081.2";

    import std.file : readText, exists;

    if (exists(config.paths.root ~ "USED"))
    {
        auto current_compiler_str = readText(config.paths.root ~ "USED");

        if (compiler_str == current_compiler_str)
            return;
        else
        {
            auto current = compiler(config, current_compiler_str);
            current.disable();
        }
    }

    auto c = compiler(config, compiler_str);
    c.fetch();
    c.enable();
}
