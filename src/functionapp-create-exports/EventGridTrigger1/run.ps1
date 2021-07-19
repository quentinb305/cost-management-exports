# Input bindings are passed in via param block.
param($eventGridEvent, $TriggerMetadata)

# Get storage variables
$RgReportsStorage = '%rg_name%'
$ReportsStorage = '%sa_acm_reports_name%'
$ReportsStorageContainer = "%sa_ctn_acm_reports_name%"

$stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$stopWatch.Start()
$totalseconds = $stopWatch.Elapsed.TotalSeconds
Write-Host "********************* Timer initialized: $totalseconds *********************"

# Convertion of event grid event into JSON 
$eventGridEvent | ConvertTo-JSON -Depth 5 | Out-String -Width 200 | Write-Host

$totalseconds = $stopWatch.Elapsed.TotalSeconds
Write-Host "********************* Event grid event converted to JSON: $totalseconds *********************"

# Extract resource group from event
$EventGridSubjectSplit = $eventGridEvent.subject.split("/")
$RGIndex = [int]$EventGridSubjectSplit.indexof('resourceGroups') + 1
$RGName = $EventGridSubjectSplit[$RGIndex]

$totalseconds = $stopWatch.Elapsed.TotalSeconds
Write-Host "********************* Event grid subject split: $EventGridSubjectSplit : $totalseconds *********************"
Write-Host "********************* Event grid resource group name index: $RGIndex : $totalseconds *********************"
Write-Host "********************* Event grid event resource group name: $RGName : $totalseconds *********************"

# Get Date for Timeframe
$date = Get-Date
$year = $date.Year
$month = $date.Month
$startOfMonth = Get-Date -Year $year -Month $month -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0
$endOfMonth = ($startOfMonth).AddMonths(1).AddTicks(-1)
$RecurrencePeriodStart = $startOfMonth.AddMonths(+1).ToString("yyyy-MM-ddTHH:mm:ssZ")
$RecurrencePeriodEnd = $endOfMonth.AddYears(+1).AddMonths(+1).ToString("yyyy-MM-ddTHH:mm:ssZ")

$DestinationStorageAccount = Get-AzStorageAccount -ResourceGroupName $RgReportsStorage -Name $ReportsStorage
$DestinationStorageAccountId = $DestinationStorageAccount.Id

$Rg = Get-AzResourceGroup -Name $RGName
$RgId = $Rg.ResourceId

# Get project owner of resource group based on ProjectOwner Tag
$Tags = Get-AzTag -ResourceId $RgId
$ProjectOwnerTagValue = $Tags.Properties.TagsProperty.ProjectOwner

$totalseconds = $stopWatch.Elapsed.TotalSeconds
Write-Host "********************* Resource Group Id is $RgId with ProjectOwner Tag $ProjectOwnerTagValue : $totalseconds *********************"

# Create or Update Azure Cost Management Export / https://docs.microsoft.com/en-us/rest/api/cost-management/query/usage#timeframetype
$Params = @{
    Name                      = 'CostManagementMonthlyExport_' + $RGName
    DefinitionType            = 'Usage'
    Scope                     = $RgId
    DestinationResourceId     = $DestinationStorageAccountId
    DestinationContainer      = $ReportsStorageContainer
    DefinitionTimeframe       = 'TheLastMonth'
    ScheduleRecurrence        = 'Monthly'
    RecurrencePeriodFrom      = $RecurrencePeriodStart
    RecurrencePeriodTo        = $RecurrencePeriodEnd
    ScheduleStatus            = 'Active'
    DestinationRootFolderPath = $ProjectOwnerTagValue
    Format                    = 'Csv'
    DatasetGranularity        = 'Daily'
}

$totalseconds = $stopWatch.Elapsed.TotalSeconds
Write-Host "********************* Creating new cost management monthly export...: $totalseconds *********************"
New-AzCostManagementExport @Params

$stopWatch.Stop()
$totalseconds = $stopWatch.Elapsed.TotalSeconds
Write-Host "********************* New cost management monthly export created for Resource Group $RGName : $totalseconds *********************"