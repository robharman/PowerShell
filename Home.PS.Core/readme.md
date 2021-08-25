[![Build Status](https://dev.azure.com/robbiecrash/Home.PS.Core/_apis/build/status/robharman.PowerShell?branchName=main)](https://dev.azure.com/robbiecrash/Home.PS.Core/_build/latest?definitionId=6&branchName=main)

# Home.PS.Core - HomeCore
Contains common functions, variables, .etc used in other scripts.
##### Current Version
1.0.0

## Getting Started
This module comprises the core functions shared throughout my PowerShell scripts and modules. These functions are used across other automated and interactive scripts. It's installed by default on all PowerShell enabled systems.

### Exports
This module exports functions and variables for use across all other Home scripts. This  module is used to centrally manage servers, and code snippets. Anything that I find myself using across multiple instances, systems or services goes here.

#### Functions
This module exports the following functions.

##### Confirm-HomeLANConnectivity
Quick way to validate LAN connectivity. Returns a Boolean.

##### Get-HomeYesorNo
Yes/No prompt to convert user input into a Boolean.

##### Set-HomeVariables
Sets the following common global variables.

###### PSEmailServer
Sets default PowerShell email server. `smtp.robharman.me`

###### ITAlerts
IT Alerts email address. `italerts@robharman.me`

###### ITServices
IT Services email address. `itservices@robharman.me`

###### ITSupport
IT Support email address. `servicedesk@robharman.me`


### Prerequisites
You must be using Windows PowerShell 5.0 or PowerShell Core 7.0 or greater. Though, this requirement is probably a lie, I just haven't tested it on anything older. 😇
