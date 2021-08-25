function Find-HomeGroup(){
    <#
    .SYNOPSIS
        Searches AD Groups (Security and Distribution) for a particular group name
    .DESCRIPTION
        Finds AD Groups which match the search string. Returns the object if there's 3 or less, or a list of all matching groups if not.
    .PARAMETER Group
        Required, string. The search string, or group name.
    .PARAMETER ReportOnly
        OOptional, switch. Returns a table of the groups.
    .EXAMPLE
        Find-HomeGroup schema

        Returns Schema Admin's information.
    .Example
        Find-HomeGroup admins

        Returns all groups which have the word "admins" in their name in a nicely formatted table.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelinebyPropertyName = $True)]
        $Group
    )

    begin {
        # Format for the query
        $GroupName = "*$Group*"
    }

    process {
        # Find the Groups
        $Groups = Get-ADGroup -f {Name -like $GroupName}

        # Catch empty list
        if ($Null -eq $Groups){
            Write-Error "No Groups found."
        }

        if ($ReportOnly) {
            Write-Output $Groups | Format-Table Name,SAMAccountName,GroupCategory

        }else {
            return $Groups
        }
    }
}