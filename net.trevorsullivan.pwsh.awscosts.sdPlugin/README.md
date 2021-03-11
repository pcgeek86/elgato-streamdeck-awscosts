# Elgato Stream Deck Plugin for Monthly AWS Cost Monitoring 

## Synopsis

If you have an Elgato Stream Deck device, it is a useful tool to simply display systems monitoring information. For example, we can use the AWS Cost Explorer APIs to retrieve the current monthly spend on AWS, and display our bill on the Stream Deck. This data is only updated every 24 hours, approximately. You can enable hourly cost data in your AWS account, for an added cost, however you would need to modify this plugin to obtain more granular data.

## Usage

1. Install `AWS.Tools.CostExplorer` module from PowerShell Gallery
1. Set up your AWS credentials profile
1. Make sure your AWS IAM credentials have an IAM policy attached allowing access to AWS Cost Explorer APIs
1. Open the `Get-ValueToDisplay.ps1` function and specify your AWS credentials profile name, on the line invoking `Get-CECostAndUsage`
1. Copy this plugin directory to your `%APPDATA%\Elgato\StreamDeck\Plugins\` directory

**IMPORTANT**: Don't install `AWSPowerShell.NetCore` and `AWS.Tools.*` modules side-by-side. They'll complain about each other.

Visit me online at https://trevorsullivan.net.
