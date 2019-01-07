/**
    Common exception base for failures expected in the app - distinguishes
    between actual error message and more verbose details.
 */
module dc.exception;

/// ditto
class DcException : Exception
{
    /// Extra details to be printed only in verbose mode
    string details;

    this (string msg, string details, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
        this.details = details;
    }
}