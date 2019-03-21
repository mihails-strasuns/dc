/**
    Majority of higher level application logic.
 */
module dc.dc;

import dc.utils.path;
import dc.compilers.api;
import dc.platform.api;


/**
    Bitflag defining actions to take during this run.
 */
public enum Action
{
    /// Download new compiler distribution
    Fetch   = 1,
    /// Disable the currently present compiler (if present)
    Disable = 1 << 1,
    /// Switch to the specified compiler
    Enable  = 1 << 2,
}

/**
    Packs together action to take and necessary context
 */
public struct ActionContext
{
    Action action;
    string new_compiler;
}

/**
    Thrown when something is wrong with CLI arguments
*/
public class HelpMsgException : Exception
{
    this (string file = __FILE__, size_t line = __LINE__)
    {
        super("", file, line);
    }
}

/**
    Initializes action context from command-line arguments, creating
    necessary intermediate objects.
 */
ActionContext parseAction (string[] args)
{
    if (args.length != 2)
        throw new HelpMsgException;

    auto action = () {
        switch (args[0])
        {
            case "use":   return (Action.Fetch | Action.Disable | Action.Enable);
            case "fetch": return Action.Fetch;

            default: assert(false);
        }
    } ();

    import dc.compilers;
    return ActionContext(action, args[1]);
}

/**
    Implements main toolchain management logic. Lower level implementation
    is provided via `dc.compilers` and `dc.platfrom` packages.
 */
void handle (ActionContext context, Path root)
{
    import dc.compilers;

    Compiler current_compiler = () {
        import std.file : readText, exists;

        if (exists(root ~ "USED"))
            return compiler(readText(root ~ "USED"), root);
        else
            return null;
    } ();

    Compiler new_compiler = compiler(context.new_compiler, root);

    if (context.action & Action.Disable)
    {
        if (current_compiler !is null && current_compiler != new_compiler)
            current_compiler.disable();
    }

    if (context.action & Action.Fetch)
    {
        assert(new_compiler !is null);
        new_compiler.fetch();
    }

    if (context.action & Action.Enable)
    {
        assert(new_compiler !is null);
        if (new_compiler != current_compiler)
            new_compiler.enable();
    }
}
