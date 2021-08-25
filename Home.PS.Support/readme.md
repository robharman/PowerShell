[![Build Status](https://dev.azure.com/robbiecrash/Home.PS.Support/_apis/build/status/robharman.PowerShell?branchName=main)](https://dev.azure.com/robbiecrash/Home.PS.Support/_build/latest?definitionId=7&branchName=main)

# Home.PS.Support - Home Support
Contains common support commands and variables. Serves as a base for other support modules and scripts.

##### Current Version
1.0.0

## Getting Started
This module contains commands used for Service Desk and other common IT support functions.

### Exports
This module exports functions and variables for use with Home support Management tasks, and other more-advanced support
tasks. Anything that you find yourself using consistently for infrastructure management, or advanced support tasks is a
good candidate for adding here. Submit a pull request!

#### Functions
This module exports the following functions.

##### Connect-HomeExchangeShell
Connects to our On-Prem Exchange server.
##### Connect-HomeExchangeOnlineShell
Connects to Office 365's Exchange Online shell.
##### Connect-Home365SecurityShell
Connects to Office 365's Protection and Security shell.
##### Find-HomeEmailAddress
Finds an Email address in Exchange.
##### Find-HomeEmailSubject
Runs a message trace for emails with a certain subject.
##### Find-HomeGroup
Finds groups matching search query.
##### Find-HomeGroupMembers
Finds group members of an AD group.
##### Find-HomeComputer
Finds computers matching search query.
##### Find-HomeUser
Finds users matching search query.
##### New-HomePassword
Creates a new pseudo-random password which is *good enough* for a temporary user password.
##### Switch-HomePreviousCommand
Replaces a previous command with a new one, inline.
##### Update-HomeOutofOfficeMessage
Updates a user's out of office message using paste-able HTML.

#### Aliases
Do not use the following aliases in other scripts, that's just bad practice.

```
ems     >   Connect-HomeExchangeShell
3ems    >   Connect-HomeExchangeOnlineShell
3sec    >   Connect-Home365SecurityShell
fea     >   Find-HomeEmailAddress
fes     >   Find-HomeEmailSubject
gg      >   Find-HomeGroup
fgm     >   Find-HomeGroupMembers
fpc     >   Find-HomeComputer
fu      >   Find-HomeUser
upooo   >   Update-HomeOutofOfficeMessage
npwd    >   New-HomePassword
```