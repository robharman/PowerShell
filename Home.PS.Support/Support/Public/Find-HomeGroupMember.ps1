function Find-HomeGroupMember(){
    <#
    .SYNOPSIS
        Takes an AD Group and returns the members of it.
    .DESCRIPTION
        Takes an AD Group and returns a list of the members in it.
    .PARAMETER Group
        Required, string. The search string
    .Parameter Recurse
        Optional, switch. Translates nested groups to their members.
    .Parameter ReportOnly
        Optional, switch. Pipes output through Format-Table and gives you only the user's name and username.
    .NOTES
        If you pipe fgm's output into fgm on a group with nested groups, the second fgm only processes the first nested
        group, not all of them.
    .EXAMPLE
        Find-HomeGroupMember GroupWithNestedGroups

        Returns first-level objects in GroupWithNestedGroups.
    .EXAMPLE
        $GroupWithNestedGroups = Find-HomeGroupMember GroupWithNestedGroups -Recurse

        Returns all objects in all nested groups in the GroupWithNestedGroups AD Group.
    .EXAMPLE
        Find-HomeGroupMember GroupWithNestedGroups -Recurse -ReportOnly

        Prints a formatted table of all nested object Names, and SAMAccountNames.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelinebyPropertyName = $True)]
        [string]
        $Group,

        [Parameter(Mandatory = $False)]
        [switch]
        $recurse,

        [Parameter(Mandatory = $False)]
        [switch]
        $ReportOnly
    )

    # Find the members of the group
    process {
        try {
            $GroupMembers   =   Get-ADGroupMember $Group -ErrorAction Stop

        }catch {
            Write-Error "No groups found for $Group"
        }

        # Go through each member of the group and if it's a group, not a user, find those group members
        if ($Recurse){
            $RecursiveList = @()

            foreach ($Member in $GroupMembers){
                # Do the actual recursion
                if ($Member.ObjectClass -eq 'Group'){

                    $RecursiveList += Find-HomeGroupMember $Member.Name -Recurse

                }else {
                    $RecursiveList += $Member
                }
            }

            # Output the results
            if ($ReportOnly) {
                return $RecursiveList | Format-Table Name,SAMAccountName

            }else {
                return $RecursiveList
            }
        }

        # Pretty output
        if ($ReportOnly) {
            return $GroupMembers | Format-Table Name,SAMAccountName

        }else {
            return $GroupMembers
        }
    }
}