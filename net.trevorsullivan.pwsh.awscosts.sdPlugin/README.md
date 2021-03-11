## Usage

1. Install `AWS.Tools.CostExplorer` module from PowerShell Gallery
1. Set up your AWS credentials profile
1. Make sure your AWS IAM credentials have an IAM policy attached allowing access to AWS Cost Explorer APIs
1. Open the `Get-ValueToDisplay.ps1` function and specify your AWS credentials profile name, on the line invoking `Get-CECostAndUsage`

**IMPORTANT**: Don't install `AWSPowerShell.NetCore` and `AWS.Tools.*` modules side-by-side. They'll complain about each other.