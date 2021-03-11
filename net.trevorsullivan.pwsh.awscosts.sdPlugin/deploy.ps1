$PluginDir = "$env:APPDATA\Elgato\StreamDeck\Plugins\net.trevorsullivan.pwsh.awscosts.sdPlugin"
if (!(Test-Path -Path $PluginDir)) {
  mkdir -Path $PluginDir
}
Copy-Item -Path $PSScriptRoot/* -Destination $PluginDir -Recurse -Force