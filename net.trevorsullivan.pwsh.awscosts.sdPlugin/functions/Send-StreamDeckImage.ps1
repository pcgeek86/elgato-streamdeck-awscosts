function Send-StreamDeckImage {
    <#
    .Synopsis
    Sends an image to the Stream Deck WebSocket API

    .Description
    Stream Deck supports SVG and Base64-encoded PNG files, among perhaps others. This function is responsible
    for generating a dynamic SVG file, and encoding it for transmission to Elgato Stream Deck over the WebSocket API.
    
    This function really needs to be refactored, but I am not going to bother doing that for now. Unfortunately it's currently
    hard-coded to retrieve GPU wattage consumption from another function and render that out as an SVG file.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Net.WebSockets.ClientWebSocket] $WSClient,
        [string] $Context
    )

    try {
        LogMessage -Message 'Sending image to Stream Deck'
    
        if ($Context -eq '') {
            throw 'Context is empty. Please populate.'
            return
        }

        # Generate SVG file
        $SVG = Get-Content -Raw -Path $PSScriptRoot/../assets/template.svg
        LogMessage -Message 'Retrieved SVG image template'
        $MonthlyCost = Get-ValueToDisplay
        
        $Payload = @{
            event = 'setImage'
            context = $Context
            payload = @{
                image = 'data:image/svg+xml;charset=utf8,{0}' -f $SVG.Replace('AWSMONTHLY', $MonthlyCost)
                target = 0
            }
        }
        LogMessage -Message 'Created SVG payload to send to Stream Deck'
        
        $PayloadJson = $Payload | ConvertTo-Json
        LogMessage -Message $PayloadJson
        $PayloadBytes = [System.Text.Encoding]::UTF8.GetBytes($PayloadJson)
    
        $SendSegment = [System.ArraySegment[Byte]]::new($PayloadBytes)
        $SendToken = [System.Threading.CancellationToken]::new($false)
    
        LogMessage -Message 'Calling SendAsync() from Send-StreamDeckImage'
        $SendTask = $WSClient.SendAsync($SendSegment, [System.Net.WebSockets.WebSocketMessageType]::Binary, $true, $SendToken)
        while (!$SendTask.IsCompleted) {
            LogMessage -Message 'Updating image on Stream Deck device'
            Start-Sleep -Milliseconds 50
        }

    }
    catch {
        LogMessage -Message $PSItem
    }
}
