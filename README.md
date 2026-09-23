# Microsoft Entra ID IAM Automation Lab

**Department-driven access management with Microsoft Graph and PowerShell.**

[Access model](#access-model) · [Lab environment](#environment-and-test-identity) · [Complete walkthrough](#complete-lab-walkthrough) · [Run the mover script](#reusable-mover-script) · [Lessons learned](#lessons-learned)

I built this lab to practice the **joiner and mover** portions of the identity lifecycle in a Microsoft Entra ID test tenant. Using a fictional employee, Alex Johnson, I created an identity, modeled department access with security groups, and used Microsoft Graph PowerShell to change and validate group memberships and direct enterprise application assignments.

The central scenario is an employee transfer between **Finance** and **Information Technology**. The lab ended with Alex in IT, with IT group membership and an IT Support Portal assignment. Temporary Finance access was removed.

> Scope: this demonstrates Entra directory membership and application-role assignment management. It does not establish that SSO, downstream application login, SCIM provisioning, session revocation, or a complete leaver process was configured or tested.

## Access model

```mermaid
flowchart TD
    A[Alex Johnson: Department attribute] --> B{Department}
    B -->|Finance| C[SG-Finance-Users membership]
    B -->|Finance| D[Direct Finance Portal User role]
    B -->|Information Technology| E[SG-IT-Users membership]
    B -->|Information Technology| F[Direct IT Support Portal User role]
    C --> G[Validate target assignments and remove previous department access]
    D --> G
    E --> G
    F --> G
```

Groups and application assignments are **separate access changes** in this lab. The tenant encountered a licensing restriction when attempting group-to-application assignment, so application roles were assigned directly to Alex. Removing a group membership alone does not remove a direct application assignment. Microsoft documents the requirements for [user and group application assignments](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/assign-user-or-group-access-portal).

## Environment and test identity

Microsoft Entra ID · Microsoft Graph · Microsoft Graph PowerShell SDK · PowerShell 7 · macOS Terminal

| Attribute | Initial lab value |
|---|---|
| Display name | Alex Johnson |
| Department | Finance |
| Job title | Financial Analyst |
| Employee ID | EMP001 |
| Employee type | Full-Time |
| Office | Philadelphia |
| Illustrative email | alex.johnson@example.com — documentation only |

The employee ID remained stable during the department change. The manual Finance-to-IT scenario included changing the job title to IT Support Analyst.

| Department | Assigned security group | Enterprise application | Assignment approach |
|---|---|---|---|
| Finance | SG-Finance-Users | Finance Portal - IAM Lab | Direct user app-role assignment |
| Information Technology | SG-IT-Users | IT Support Portal - IAM Lab | Direct user app-role assignment |

## What I implemented

1. **Joiner setup:** created the fictional employee and populated identity attributes; created the Finance security group and enterprise application assignment.
2. **Manual mover:** changed the employee's department and job information, removed Finance membership, added IT membership, and updated the direct application assignments.
3. **Attribute-driven group automation:** read `Department` using Microsoft Graph, added Finance membership during a reverse-move test, removed IT membership, and checked the resulting memberships.
4. **Application-role automation:** queried the Finance service principal, inspected its available roles, and created Alex's direct `User` role assignment.
5. **Return to IT:** restored `Information Technology`, restored IT membership, removed Finance membership and the Finance application assignment, and checked the final directory state.

Dynamic membership was explored but was not the implemented automation path. The working approach used PowerShell to maintain **assigned** security groups. The original Finance test briefly left both application assignments in place; it was stopped and Alex was returned to IT before completing an IT-application removal in that direction.

## Complete lab walkthrough

### Part 1: Azure portal — joiner setup and manual mover

The following 22 screenshots cover identity creation, Finance access, the move to IT, and Finance assignment cleanup. Setup forms show configuration; assignment lists show the recorded results. Capture times belong to the supplied files, rather than necessarily indicating when each action occurred.

#### 01. Review the new Finance user

The creation review shows Alex Johnson, Financial Analyst, Finance, EMP001 and the generic lab attributes. 

![Review the new Finance user](screenshots/azure-01-user-creation.png)

#### 02. Confirm Alex appears in Users

The directory list includes Alex Johnson. The other account identity and user principal names are concealed.

![Confirm Alex appears in Users](screenshots/azure-02-users-list.png)

#### 03. Configure the Finance security group

The new-group form shows SG-Finance-Users, Security type, Assigned membership and one selected member. The form itself does not prove creation completed.

![Configure the Finance security group](screenshots/azure-03-finance-group-setup.png)

#### 04. Inspect the Finance enterprise application

Finance Portal - IAM Lab is present. Its application and object identifiers are concealed. The setup tiles do not establish that SSO or provisioning was configured.

![Inspect the Finance enterprise application](screenshots/azure-04-finance-app-overview.png)

#### 05. Open assignment management

The Assign users and groups tile identifies the next navigation step.

![Open assignment management](screenshots/azure-05-assignment-navigation.png)

#### 06. Check the initially empty Finance assignment list

No application assignments are displayed at this point, before the first assignment.

![Check the initially empty Finance assignment list](screenshots/azure-06-finance-before-assignment.png)

#### 07. Select Alex for Finance

Alex Johnson is selected in the user picker. Selection is an intermediate step, before the assignment result.

![Select Alex for Finance](screenshots/azure-07-select-finance-user.png)

#### 08. Verify the Finance assignment

Alex Johnson appears as a User in Finance Portal - IAM Lab assignment management.

![Verify the Finance assignment](screenshots/azure-08-finance-user-assigned.png)

#### 09. Review the test identity overview

Alex Johnson has one displayed group membership and one displayed application. User principal names and the user object ID are concealed.

![Review the test identity overview](screenshots/azure-09-alex-user-overview.png)

#### 10. Review the original Finance attributes

The job information form shows Financial Analyst, Finance and employee ID EMP001.

![Review the original Finance attributes](screenshots/azure-10-finance-job-properties.png)

#### 11. Prepare the IT department change

The job information form shows IT Support Analyst and Information Technology while keeping EMP001. Later validation, rather than this edit form alone, confirms the final department.

![Prepare the IT department change](screenshots/azure-11-it-job-properties.png)

#### 12. Inspect the existing Finance membership

The group list still shows the Finance group before its membership is removed. The name is truncated in the source, and its object ID is concealed.

![Inspect the existing Finance membership](screenshots/azure-12-finance-group-membership.png)

#### 13. Configure the IT security group

The new-group form shows SG-IT-Users with Assigned membership and one selected member.

![Configure the IT security group](screenshots/azure-13-it-group-setup.png)

#### 14. Verify both department groups exist

The directory lists SG-Finance-Users and SG-IT-Users as security groups. Object IDs are concealed. Group existence alone does not prove Alex belongs to either group.

![Verify both department groups exist](screenshots/azure-14-finance-and-it-groups.png)

#### 15. Review enterprise applications

The application list shows the Finance application. Its identifiers and homepage URL are concealed.

![Review enterprise applications](screenshots/azure-15-enterprise-app-list.png)

#### 16. Prepare the IT application

The creation form names IT Support Portal - IAM Lab and selects the non-gallery integration option. This is the creation form, not the completed result.

![Prepare the IT application](screenshots/azure-16-it-app-creation.png)

#### 17. Verify the IT application exists

The IT Support Portal - IAM Lab overview confirms the application exists. Its application and object IDs are concealed.

![Verify the IT application exists](screenshots/azure-17-it-app-overview.png)

#### 18. Select Alex for IT

The picker has Alex Johnson selected. The other account identity and all displayed email/domain values are concealed.

![Select Alex for IT](screenshots/azure-18-select-it-user.png)

#### 19. Verify the IT application assignment

Alex Johnson appears in IT Support Portal - IAM Lab assignment management.

![Verify the IT application assignment](screenshots/azure-19-it-user-assigned.png)

#### 20. Inspect Finance access before cleanup

Alex Johnson still appears in the Finance application assignment list before removal. This records the temporary overlap during the move.

![Inspect Finance access before cleanup](screenshots/azure-20-finance-before-removal.png)

#### 21. Verify Finance assignment removal

Finance Portal - IAM Lab displays No application assignments found after cleanup.

![Verify Finance assignment removal](screenshots/azure-21-finance-assignment-removed.png)

#### 22. Explore the next group configuration

The blank new-group form shows Assigned membership. It is a setup screen and does not demonstrate a dynamic rule or a completed dynamic group.

![Explore the next group configuration](screenshots/azure-22-new-group-form.png)

### Part 2: PowerShell — automation and final validation

#### 23. Discover application objects and existing assignments

The Graph session locates the Finance enterprise application and lists Alex's existing IT application assignment. The service principal object ID and application/client ID are different identifiers; the script uses the service principal object ID for role assignment.

![Graph application discovery and existing IT assignment](screenshots/01-application-discovery-redacted.png)

#### 24. Inspect roles and assign Finance access

An earlier request using an empty role ID failed. Inspecting the application's roles revealed an enabled `User` role; using that role produced an assignment result for Alex Johnson. The reusable script resolves an enabled user role rather than copying a tenant-specific role ID or assuming an empty role is valid.

![Enabled application roles and successful assignment to Alex Johnson](screenshots/02-finance-role-assignment-redacted.png)

#### 25. Validate the final IT state

The captured output shows Alex's department as `Information Technology`, `SG-IT-Users` in the displayed group results, and `IT Support Portal - IAM Lab` in the displayed application results. Finance entries are absent from those displayed results.

![Final user, group and application validation](screenshots/03-final-it-validation-redacted.png)

The original screenshot commands do not provide a comprehensive effective-access audit: for example, group lookups suppress errors and the displayed listing commands omit `-All`. The new script follows pagination and checks the explicitly managed resources; it still does not prove downstream application access or the absence of every other access path.

## Reusable mover script

[`scripts/Invoke-IamMover.ps1`](scripts/Invoke-IamMover.ps1) is a **new reusable implementation based on the lab**, not a claim that this exact script was run in the original session.

It reads the existing department and reconciles one user's membership in the two configured groups and direct assignments to the two configured applications. It does not update department, job title or other identity attributes.

- Preview by default; writes require `-Apply`. Supports `-WhatIf`.
- Validates the tenant, explicit resource IDs, resource names, group type and enabled user role.
- Refuses unsupported departments and detected inherited app assignments for managed applications.
- Grants target access, verifies it, then removes previous department access.
- Removes **all direct roles for that user on the previous department's configured application**.
- Preserves unrelated groups, unrelated applications and other target-application roles.
- Follows paginated reads; skips already-correct assignments on repeat runs.
- Stops on errors, checks final state with bounded retries, and avoids printing raw Graph errors containing private identifiers.

Grant-before-revoke temporarily permits both departments' access. Use this sequence only where the lab's access policy permits that overlap. It is not a transaction: failures can leave partial changes, and the script does not roll back automatically. Review current state before retrying. Run one mover at a time for a given user.

### Prerequisites

Use PowerShell 7 and a separate lab tenant in the Microsoft Graph Global cloud. Create the two cloud-only, assigned, non-mail-enabled security groups and enterprise applications first. Each application must expose exactly one enabled user-assignable role matching the configured display name (default `User`). Role-assignable and synchronized groups are rejected.

The delegated session requests:

| Scope | Purpose |
|---|---|
| User.Read.All | Read the test identity and department |
| Group.Read.All | Validate group properties and membership |
| GroupMember.ReadWrite.All | Add and remove membership |
| Application.Read.All | Inspect enterprise applications and roles |
| AppRoleAssignment.ReadWrite.All | Manage direct app-role assignments |

Admin consent and appropriate Entra administrative authority are required; scopes alone do not grant the operator that authority. See Microsoft's [membership removal requirements](https://learn.microsoft.com/en-us/graph/api/group-delete-members?view=graph-rest-1.0) and [application-role assignment requirements](https://learn.microsoft.com/en-us/graph/api/user-post-approleassignments?view=graph-rest-1.0).

### Configure and preview

Run from the repository root in PowerShell:

```powershell
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser
Copy-Item ./config.example.json ./config.local.json
```

Edit `config.local.json` privately. Replace every placeholder with IDs from your own lab. `UserId` is the test user's object ID; `ServicePrincipalId` is the enterprise application's **object ID**, not its application/client ID. Match display names exactly, including punctuation. Do not commit the local file.

```powershell
$config = Get-Content ./config.local.json -Raw | ConvertFrom-Json
$scopes = @(
    'User.Read.All'
    'Group.Read.All'
    'GroupMember.ReadWrite.All'
    'Application.Read.All'
    'AppRoleAssignment.ReadWrite.All'
)
Connect-MgGraph -TenantId $config.TenantId -Scopes $scopes -ContextScope Process -NoWelcome

# Reads live lab state and prints the planned changes; performs no writes.
./scripts/Invoke-IamMover.ps1 -ConfigPath ./config.local.json

# Optional additional preview using PowerShell's WhatIf support.
./scripts/Invoke-IamMover.ps1 -ConfigPath ./config.local.json -Apply -WhatIf
```

After reviewing the plan:

```powershell
./scripts/Invoke-IamMover.ps1 -ConfigPath ./config.local.json -Apply
Disconnect-MgGraph
```

For the documented final state, first set the test user's department to `Information Technology` in Entra. To test the reverse direction, change it to `Finance`, preview, then apply. The script intentionally leaves identity-attribute changes to the lab operator.

### Verification and limits

The script's final result reports `Verified` only after the target membership and selected direct role are present, the old direct membership is absent, and no old-application assignment appears in its reads. This is a scoped directory check. Nested group access, alternate accounts, application-local permissions, active sessions, SSO and downstream provisioning require separate validation.

The repository's offline tests cover preview and WhatIf, both mover directions, repeat-run idempotency, preservation of unrelated assignments, failure before old-access removal, unsupported departments, and inherited-assignment rejection:

```powershell
pwsh -NoProfile -File ./tests/Test-IamMover.ps1
```

**Validation performed for this package:** PowerShell syntax check and mocked offline behavioral tests. The new script has not been executed against a live tenant. The screenshots document the original interactive lab, not a live test of this packaged script.

## Repository layout

```text
entra-iam-automation-lab/
├── README.md
├── .gitignore
├── config.example.json
├── scripts/
│   └── Invoke-IamMover.ps1
├── tests/
│   └── Test-IamMover.ps1
└── screenshots/
    ├── README.md
    ├── AZURE-WALKTHROUGH.md
    ├── azure-01-...png through azure-22-...png
    ├── 01-application-discovery-redacted.png
    ├── 02-finance-role-assignment-redacted.png
    └── 03-final-it-validation-redacted.png
```

## Lessons learned

- A department attribute describes intended access; it does not itself change assigned group memberships or direct application roles.
- Removing group membership and removing a direct application assignment are separate operations.
- Service principal IDs, application/client IDs, app-role IDs and assignment IDs serve different purposes.
- Successful commands need follow-up state checks; a printed success message alone is not validation.
- Licensing constraints affect the implementation path and should be documented honestly.

## Portfolio summary

Built a Microsoft Entra ID IAM lab using Microsoft Graph and PowerShell to manage a fictional employee's department-based security group memberships and direct enterprise application roles. Tested Finance/IT mover scenarios, resolved an app-role assignment error, and validated the final IT directory state while removing temporary Finance assignments.

## Publishing

Upload the contents of this folder to a new GitHub repository. The README uses relative image links so the screenshots render on GitHub. Include `.gitignore`; exclude `config.local.json`, original screenshots, transcripts, tokens and credentials. No license is assumed or added; choose a license if you want to grant reuse rights.
