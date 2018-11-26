module dc.app;

import dc.sandbox;
import dc.utils.platform : checkRequirements;

void main ()
{
    checkRequirements();
    
	auto paths = initRoot("./sandbox");
    auto compiler_str = "dmd-2.082.1";

    import std.file : readText, exists;

    if (exists(paths.root ~ "USED"))
    {
        auto current_compiler_str = readText(paths.root ~ "USED");

        if (compiler_str == current_compiler_str)
            return;
        else
        {
            auto current = compiler(paths, current_compiler_str);
            current.disable();
        }
    }

    auto c = compiler(paths, compiler_str);
    c.fetch();
    c.enable();
}