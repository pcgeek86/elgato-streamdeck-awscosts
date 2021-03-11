function Get-ValueToDisplay {
  <#
  .Synopsis
  This function does whatever you need it to, in order to retrieve data for use in the Send-StreamDeckImage command.
  #>

  Import-Module -Name AWS.Tools.CostExplorer

  $CacheFile = "$PSScriptRoot/../awscosts.cache.json"
  $CachedData = Get-Content -Path $CacheFile -Raw -ErrorAction Ignore | ConvertFrom-Json

  [System.Timespan] $TimeSinceLastUpdated = (Get-Date) - [datetime]$CachedData.LastUpdated

  if (!$CachedData.LastUpdated -or $TimeSinceLastUpdated.Hours -gt 12) {
    $Interval = [Amazon.CostExplorer.Model.DateInterval]::new()
    $Interval.Start = (Get-date -Day 1).ToString('yyyy-MM-dd')
    $Interval.End = (Get-Date -Day 1).AddMonths(1).AddDays(-1).ToString('yyyy-MM-dd')
    $Cost = Get-CECostAndUsage -Metric UnblendedCost -TimePeriod $Interval -Granularity MONTHLY -ProfileName cbt -Region us-west-2
    $MonthlyCost = '${0:0.##}' -f ([double]$Cost.ResultsByTime[0].Total.UnblendedCost.Amount)
    LogMessage -Message ('Wrote AWS costs to log file: {0}' -f $CacheFile)
    Set-Content -Path $CacheFile -Value (@{
      Cost = $MonthlyCost
      LastUpdated = Get-Date -Format s
    } | ConvertTo-Json)
  }
  else {
    LogMessage -Message 'Read AWS costs from cache file'
    $MonthlyCost = $CachedData.Cost
  }

  return $MonthlyCost
}
