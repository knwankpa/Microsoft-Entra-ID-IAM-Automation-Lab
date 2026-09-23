#requires -Version 7.0
<#
.SYNOPSIS
Reconcile one test user's Finance/IT group and direct application assignments.
.DESCRIPTION
Reads Department; does not change identity attributes. Preview is the default.
Uses an existing delegated Microsoft Graph session. See README for setup.
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)][string]$ConfigPath,
    [switch]$Apply
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
$base = 'https://graph.microsoft.com/v1.0'
$stage = 'preflight'

function Get-Collection([string]$Uri) {
    do {
        if (-not $Uri.StartsWith("$base/", [StringComparison]::Ordinal)) {
            throw 'Unexpected pagination host.'
        }
        $page = Invoke-MgGraphRequest -Method GET -Uri $Uri -OutputType Hashtable
        foreach ($item in $page['value']) { $item }
        $Uri = $page['@odata.nextLink']
    } while ($Uri)
}
function Test-Guid([string]$Value) {
    $parsed = [guid]::Empty
    return ([guid]::TryParse($Value, [ref]$parsed) -and $parsed -ne [guid]::Empty)
}
function Get-State {
    $memberIds = @(Get-Collection "$base/users/$uid/memberOf?`$select=id" | ForEach-Object { $_['id'] })
    $assignments = @(Get-Collection "$base/users/$uid/appRoleAssignments")
    @{ Members = $memberIds; Assignments = $assignments }
}
function Test-Target($State) {
    $roleMatches = @($State.Assignments | Where-Object {
        $_['principalId'] -eq $uid -and $_['resourceId'] -eq $target.AppId -and $_['appRoleId'] -eq $target.RoleId
    })
    ($State.Members -contains $target.GroupId) -and $roleMatches.Count -gt 0
}
function Test-Final($State) {
    $oldAssignments = @($State.Assignments | Where-Object { $_['resourceId'] -eq $old.AppId })
    (Test-Target $State) -and ($State.Members -notcontains $old.GroupId) -and $oldAssignments.Count -eq 0
}
function Wait-State([switch]$Final) {
    for ($attempt = 0; $attempt -lt 6; $attempt++) {
        $state = Get-State
        if (($Final -and (Test-Final $state)) -or (-not $Final -and (Test-Target $state))) { return $state }
        if ($attempt -lt 5) { Start-Sleep -Seconds 2 }
    }
    throw 'Verification did not converge.'
}
try {
    $config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json -AsHashtable
    if (-not (Test-Guid $config.TenantId) -or -not (Test-Guid $config.UserId)) {
        throw 'Replace tenant and user placeholders.'
    }
    $context = Get-MgContext
    if (-not $context -or $context.TenantId -ne $config.TenantId -or $context.AuthType -ne 'Delegated' -or $context.Environment -ne 'Global') {
        throw 'Connect to the configured tenant using delegated Global-cloud authentication.'
    }
    $requiredScopes = @('User.Read.All','Group.Read.All','GroupMember.ReadWrite.All','Application.Read.All','AppRoleAssignment.ReadWrite.All')
    foreach ($scope in $requiredScopes) {
        if ($context.Scopes -notcontains $scope) { throw 'A required scope is missing.' }
    }
    $uid = $config.UserId
    $user = Invoke-MgGraphRequest -Method GET -Uri "$base/users/$uid`?`$select=id,displayName,department" -OutputType Hashtable
    if ($user['department'] -notin @('Finance','Information Technology')) { throw 'Unsupported department.' }
    $resolved = @{}
    foreach ($department in @('Finance','Information Technology')) {
        $entry = $config.Departments[$department]
        if (-not (Test-Guid $entry.GroupId) -or -not (Test-Guid $entry.ServicePrincipalId)) { throw 'Replace resource placeholders.' }
        $group = Invoke-MgGraphRequest -Method GET -Uri "$base/groups/$($entry.GroupId)?`$select=id,displayName,securityEnabled,mailEnabled,groupTypes,isAssignableToRole,onPremisesSyncEnabled" -OutputType Hashtable
        if ($group['displayName'] -cne $entry.GroupName -or -not $group['securityEnabled'] -or $group['mailEnabled'] -or
            $group['isAssignableToRole'] -or $group['onPremisesSyncEnabled'] -or $group['groupTypes'] -contains 'DynamicMembership') {
            throw 'Group must match its configured name and be a cloud-only assigned security group without role assignment.'
        }
        $app = Invoke-MgGraphRequest -Method GET -Uri "$base/servicePrincipals/$($entry.ServicePrincipalId)?`$select=id,displayName,appRoles" -OutputType Hashtable
        if ($app['displayName'] -cne $entry.ApplicationName) { throw 'Application name mismatch.' }
        $roles = @($app['appRoles'] | Where-Object {
            $_['displayName'] -ceq $entry.RoleDisplayName -and $_['isEnabled'] -and $_['allowedMemberTypes'] -contains 'User'
        })
        if ($roles.Count -ne 1) { throw 'Exactly one enabled user role must match the configured display name.' }
        $resolved[$department] = @{ GroupId=$entry.GroupId; AppId=$entry.ServicePrincipalId; RoleId=$roles[0]['id']; GroupName=$entry.GroupName; AppName=$entry.ApplicationName }
    }
    $target = $resolved[$user['department']]
    $oldDepartment = if ($user['department'] -eq 'Finance') { 'Information Technology' } else { 'Finance' }
    $old = $resolved[$oldDepartment]
    if ($target.GroupId -eq $old.GroupId -or $target.AppId -eq $old.AppId) { throw 'Resources must be distinct.' }
    $initial = Get-State
    $managedApps = @($target.AppId, $old.AppId)
    $inherited = @($initial.Assignments | Where-Object { $_['resourceId'] -in $managedApps -and $_['principalId'] -ne $uid })
    if ($inherited.Count -gt 0) { throw 'Inherited application access requires a separate group-assignment review.' }
    $plan = [Collections.Generic.List[object]]::new()
    if ($initial.Members -notcontains $target.GroupId) { $plan.Add([pscustomobject]@{Action='Add group membership';Resource=$target.GroupName}) }
    $hasRole = @($initial.Assignments | Where-Object { $_['principalId'] -eq $uid -and $_['resourceId'] -eq $target.AppId -and $_['appRoleId'] -eq $target.RoleId }).Count -gt 0
    if (-not $hasRole) { $plan.Add([pscustomobject]@{Action='Grant direct app role';Resource=$target.AppName}) }
    $oldAssignments = @($initial.Assignments | Where-Object { $_['principalId'] -eq $uid -and $_['resourceId'] -eq $old.AppId })
    foreach ($assignment in $oldAssignments) { $plan.Add([pscustomobject]@{Action='Remove direct app role';Resource=$old.AppName}) }
    if ($initial.Members -contains $old.GroupId) { $plan.Add([pscustomobject]@{Action='Remove group membership';Resource=$old.GroupName}) }
    $plan.ToArray()
    if (-not $Apply) { Write-Host 'PREVIEW ONLY: no changes made. Use -Apply after reviewing the plan.'; return }
    if ($plan.Count -gt 0 -and -not $PSCmdlet.ShouldProcess('Configured lab user', 'Apply the displayed mover plan')) { return }
    # Guard against an attribute change between planning and mutation.
    $freshUser = Invoke-MgGraphRequest -Method GET -Uri "$base/users/$uid`?`$select=department" -OutputType Hashtable
    if ($freshUser['department'] -ne $user['department']) { throw 'Department changed; generate a new plan.' }
    $stage = 'grant target access'
    if ($initial.Members -notcontains $target.GroupId) {
        $body = @{ '@odata.id' = "$base/directoryObjects/$uid" } | ConvertTo-Json
        $null = Invoke-MgGraphRequest -Method POST -Uri "$base/groups/$($target.GroupId)/members/`$ref" -Body $body -ContentType 'application/json'
    }
    if (-not $hasRole) {
        $body = @{ principalId=$uid; resourceId=$target.AppId; appRoleId=$target.RoleId } | ConvertTo-Json
        $null = Invoke-MgGraphRequest -Method POST -Uri "$base/servicePrincipals/$($target.AppId)/appRoleAssignedTo" -Body $body -ContentType 'application/json'
    }
    $stage = 'verify target access'
    $null = Wait-State
    $stage = 'remove previous department access'
    foreach ($assignment in $oldAssignments) {
        $assignmentId = [uri]::EscapeDataString($assignment['id'])
        $null = Invoke-MgGraphRequest -Method DELETE -Uri "$base/users/$uid/appRoleAssignments/$assignmentId"
    }
    if ($initial.Members -contains $old.GroupId) {
        # $ref is essential: remove membership, never delete the user object.
        $null = Invoke-MgGraphRequest -Method DELETE -Uri "$base/groups/$($old.GroupId)/members/$uid/`$ref"
    }
    $stage = 'verify final scoped state'
    $null = Wait-State -Final
    [pscustomobject]@{ Status='Verified'; Department=$user['department']; Group=$target.GroupName; Application=$target.AppName; PreviousDepartmentAccess='Removed within managed scope' }
} catch {
    # Graph errors can contain private IDs and request data. Do not echo the raw exception.
    throw "Mover stopped during '$stage'. No success is claimed. Check configuration, permissions and current lab state privately. Changes may be partial; there is no automatic rollback."
}
