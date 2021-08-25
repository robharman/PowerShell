<%
$ModuleGUID = [guid]::NewGuid()
@"
@{
    # Script module or binary module file associated with this manifest.
    RootModule = '$PLASTER_PARAM_ModuleName.psm1'

    # Version number of this module.
    ModuleVersion = '<ModuleVersion>'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # Supported PS Versions
    PowerShellVersion = '5.0'

    # ID used to uniquely identify this module
    GUID = '$ModuleGUID'

    # Author of this module
    Author = '$PLASTER_PARAM_Author'

    # Company or vendor of this module
    CompanyName = '$PLASTER_PARAM_CompanyName'

    # Copyright statement for this module
    Copyright = '(c) Rob Harman. All rights reserved.'

    # Description of the functionality provided by this module
    Description = '$PLASTER_PARAM_ModuleDescription'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @('<FunctionsToExport>')

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

    }
"@
%>