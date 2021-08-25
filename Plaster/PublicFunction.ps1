<%
@"
function New-PublicFunctionTemplate {
    <#
    .SYNOPSIS
        Simple description of the function.
    .DESCRIPTION
        More detailed description of the function with some details about what it actually does, and how it does it. It
        should outline the way the parameters are accepted and what it outputs.
    .PARAMETER ParameterName
        [Optional | Required], [type]. [Set to default if applicable.] What the parameter is, what it does, and how it's
        used in the function.
    .EXAMPLE
        Use-Function

        Describe what you get when you run it in its basic form.
    .Example
        Use-Function -ParameterName Value

        Describe what you get back when you run it with a parameter. There should be examples for most, if not all of
        your parameteres.
    .NOTES
        Requires:
        Version:        <ModuleVersion>
        Author:         $PLASTER_PARAM_Author
        Written:        <Date>
        Version Notes:  Initial Module
        To Do:          <toDo>
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [TypeName]
        `$ParameterName
    )

    begin {}

    process {}

    end {}
"@
%>