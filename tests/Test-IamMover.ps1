# Offline behavioral checks. All Graph calls are replaced with in-memory fixtures.
#requires -Version 7.0
$ErrorActionPreference = 'Stop'
Import-Module Microsoft.Graph.Authentication
function Assert($Condition, $Message) { if (-not $Condition) { throw $Message } }
$global:iamTest_ids = 1..7 | ForEach-Object { ('00000000-0000-4000-8000-{0:d12}' -f $_) }
$config = @{
    TenantId=$global:iamTest_ids[0]; UserId=$global:iamTest_ids[1]
    Departments=@{
        Finance=@{GroupId=$global:iamTest_ids[2];GroupName='SG-Finance-Users';ServicePrincipalId=$global:iamTest_ids[4];ApplicationName='Finance Portal - IAM Lab';RoleDisplayName='User'}
        'Information Technology'=@{GroupId=$global:iamTest_ids[3];GroupName='SG-IT-Users';ServicePrincipalId=$global:iamTest_ids[5];ApplicationName='IT Support Portal - IAM Lab';RoleDisplayName='User'}
    }
}
$tempConfig = Join-Path ([IO.Path]::GetTempPath()) ('iam-test-' + [guid]::NewGuid() + '.json')
$config | ConvertTo-Json -Depth 6 | Set-Content $tempConfig
function Get-MgContext {
    @{TenantId=$global:iamTest_ids[0];AuthType='Delegated';Environment='Global';Scopes=@('User.Read.All','Group.Read.All','GroupMember.ReadWrite.All','Application.Read.All','AppRoleAssignment.ReadWrite.All')}
}
function Reset-Fixture {
    $global:iamTest_department='Information Technology'
    $global:iamTest_members=[Collections.Generic.List[string]]::new(); $global:iamTest_members.Add($global:iamTest_ids[2])
    $global:iamTest_assignments=[Collections.Generic.List[object]]::new()
    $global:iamTest_assignments.Add(@{id='old-assignment';principalId=$global:iamTest_ids[1];resourceId=$global:iamTest_ids[4];appRoleId=$global:iamTest_ids[6]})
    $global:iamTest_assignments.Add(@{id='unrelated';principalId=$global:iamTest_ids[1];resourceId='unmanaged-app';appRoleId=$global:iamTest_ids[6]})
    $global:iamTest_writes=[Collections.Generic.List[string]]::new()
    $global:iamTest_failGrant=$false
}
function Invoke-MgGraphRequest {
    param($Method,$Uri,$OutputType,$Body,$ContentType)
    if ($Method -eq 'GET') {
        if ($Uri -match '/memberOf') { return @{value=@($global:iamTest_members | ForEach-Object { @{id=$_} })} }
        if ($Uri -match '/appRoleAssignments') { return @{value=@($global:iamTest_assignments.ToArray())} }
        if ($Uri -match '/users/') { return @{id=$global:iamTest_ids[1];displayName='Alex Johnson';department=$global:iamTest_department} }
        if ($Uri -match '/groups/([^?]+)') {
            $gid=$Matches[1]; $entry=@($config.Departments.Values | Where-Object GroupId -eq $gid)[0]
            return @{id=$gid;displayName=$entry.GroupName;securityEnabled=$true;mailEnabled=$false;groupTypes=@();isAssignableToRole=$false;onPremisesSyncEnabled=$false}
        }
        if ($Uri -match '/servicePrincipals/([^?]+)') {
            $aid=$Matches[1]; $entry=@($config.Departments.Values | Where-Object ServicePrincipalId -eq $aid)[0]
            return @{id=$aid;displayName=$entry.ApplicationName;appRoles=@(@{id=$global:iamTest_ids[6];displayName='User';isEnabled=$true;allowedMemberTypes=@('User')})}
        }
    }
    $global:iamTest_writes.Add("$Method $Uri")
    if ($Method -eq 'POST' -and $Uri -match '/groups/([^/]+)/members/\$ref$') { $global:iamTest_members.Add($Matches[1]); return }
    if ($Method -eq 'POST' -and $Uri -match '/appRoleAssignedTo$') {
        if ($global:iamTest_failGrant) { throw 'Simulated grant failure' }
        $assignment=$Body | ConvertFrom-Json -AsHashtable; $assignment['id']='new-' + $assignment['resourceId']; $global:iamTest_assignments.Add($assignment); return
    }
    if ($Method -eq 'DELETE' -and $Uri -match '/appRoleAssignments/(.+)$') {
        $match=@($global:iamTest_assignments | Where-Object { $_.id -eq $Matches[1] })
        foreach ($item in $match) { $null=$global:iamTest_assignments.Remove($item) }; return
    }
    if ($Method -eq 'DELETE' -and $Uri -match '/groups/([^/]+)/members/[^/]+/\$ref$') { $null=$global:iamTest_members.Remove($Matches[1]); return }
    throw 'Unexpected mock request'
}
$runner=Join-Path $PSScriptRoot '../scripts/Invoke-IamMover.ps1'
try {
    Reset-Fixture
    $null=& $runner -ConfigPath $tempConfig
    Assert ($global:iamTest_writes.Count -eq 0) 'Preview must perform no writes.'
    $null=& $runner -ConfigPath $tempConfig -Apply -WhatIf
    Assert ($global:iamTest_writes.Count -eq 0) 'WhatIf must perform no writes.'
    $result=@(& $runner -ConfigPath $tempConfig -Apply)
    Assert ($result[-1].Status -eq 'Verified') 'Move must verify.'
    Assert ($global:iamTest_members.Contains($global:iamTest_ids[3]) -and -not $global:iamTest_members.Contains($global:iamTest_ids[2])) 'Group move failed.'
    Assert (@($global:iamTest_assignments | Where-Object id -eq 'unrelated').Count -eq 1) 'Unrelated app must survive.'
    $count=$global:iamTest_writes.Count
    $null=& $runner -ConfigPath $tempConfig -Apply
    Assert ($global:iamTest_writes.Count -eq $count) 'Rerun must be idempotent.'
    $global:iamTest_department='Finance'
    $result=@(& $runner -ConfigPath $tempConfig -Apply)
    Assert ($result[-1].Status -eq 'Verified' -and $global:iamTest_members.Contains($global:iamTest_ids[2])) 'Reverse move failed.'
    Reset-Fixture; $global:iamTest_failGrant=$true
    $failed=$false; try { $null=& $runner -ConfigPath $tempConfig -Apply } catch { $failed=$true }
    Assert $failed 'Grant failure must stop run.'
    Assert (@($global:iamTest_writes | Where-Object { $_ -like 'DELETE*' }).Count -eq 0) 'Do not revoke old access after failed grant.'
    Reset-Fixture; $global:iamTest_department='Unknown'
    $failed=$false; try { $null=& $runner -ConfigPath $tempConfig -Apply } catch { $failed=$true }
    Assert ($failed -and $global:iamTest_writes.Count -eq 0) 'Unknown department must stop before writes.'
    Reset-Fixture; $global:iamTest_assignments[0]['principalId']='inherited-group'
    $failed=$false; try { $null=& $runner -ConfigPath $tempConfig -Apply } catch { $failed=$true }
    Assert ($failed -and $global:iamTest_writes.Count -eq 0) 'Inherited access must stop before writes.'
    Write-Host 'PASS: preview, WhatIf, both directions, unrelated access, idempotency, failed grant, unknown department, inherited assignment.'
} finally { Remove-Item -LiteralPath $tempConfig -Force }
