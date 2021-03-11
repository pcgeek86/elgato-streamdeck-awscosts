function Process-StreamDeckMessage {
    <#
    .Synopsis
    Called from the Receive-StreamDeckMessage function.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Message
    )
    $MessageObject = $Message | ConvertFrom-Json
    if ($MessageObject.Context) {
        $global:Context = $MessageObject.Context
        LogMessage -Message ('Set global context to: {0}' -f $MessageObject.Context)
    }
}