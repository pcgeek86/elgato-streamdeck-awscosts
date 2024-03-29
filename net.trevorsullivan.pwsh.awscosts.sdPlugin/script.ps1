Set-PSDebug -Strict
$ErrorActionPreference = 'Continue'

# Plugin context placeholder
$Context = ''

# Clean up all log files in extension directory
#Remove-Item -Path $PSScriptRoot/*.txt

# Import supporting function files from ./functions child directory
# NOTE: This must execute before any of the supporting functions are called, otherwise you'll get "command not found" or related error messages.
foreach ($Function in (Get-ChildItem -Path $PSScriptRoot/functions -Filter *.ps1)) {
    . $Function.FullName
}

$LogPath = "$PSScriptRoot/output-$PID.txt"
LogMessage -Message ('PowerShell starting up with process ID {0}' -f $PID)
LogMessage -Message $args
LogMessage -Message ('Stream Deck version {0} connected' -f $ArgumentList.application.version)

# Parse the incoming arguments from callps.cmd
$ArgumentList = @{
    Port = $args[1]
    PluginUUID = $args[3]
    RegisterEvent = $args[5]
    Info = $args[7] | ConvertFrom-Json
}
LogMessage -Message 'Finished parsing arguments into HashTable'

# Create a WebSocket client
LogMessage -Message 'Connecting to Stream Deck from script.ps1'
[System.Net.WebSockets.ClientWebSocket] $Websocket = Connect-StreamDeck -Port $ArgumentList.Port

# Register the plugin with Stream Deck
LogMessage -Message 'Starting to register plugin with Stream Deck'
Register-StreamDeck -RegisterEvent $ArgumentList.RegisterEvent -PluginUUID $ArgumentList.PluginUUID -WSClient $Websocket
LogMessage -Message 'Successfully registered plugin with Stream Deck'

try {
    while ($true) {
        # If the context variable is empty, then we need to populate it, so that Send-StreamDeckImage knows how to send
        # image data to the Stream Deck WebSocket API.
        if ($Context -eq '') {
            Receive-StreamDeckMessage -WSClient $Websocket
        }
        LogMessage -Message Sleeping...
        LogMessage -Message $Websocket.State

        Send-StreamDeckImage -WSClient $Websocket -Context $Context

        if (!(Test-StreamDeck)) { $Websocket.Abort() }
        if (!($Websocket.State -eq 'Open')) {
            throw 'Websocket is not open anymore. {0}' -f $Websocket.State
        }
        # Kill the WebSocket connection if Stream Deck has been closed
        Start-Sleep -Seconds 5
    }

}
catch {
    LogMessage -Message $PSItem | ConvertTo-Json
}
finally {
    $Websocket.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, 'Closing program', $CancelToken)
    LogMessage -Message 'Closed websocket connection. Plugin terminated.'
    $Websocket.Dispose()
}
