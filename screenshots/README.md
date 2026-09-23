# Screenshot inventory and naming plan

This folder contains all 22 supplied Azure portal screenshots and three PowerShell evidence screenshots. [Open the complete Azure walkthrough](AZURE-WALKTHROUGH.md).

Private values were concealed with opaque masks using AI-assisted image editing. Images that needed no redaction retain their original pixels. All exported images have metadata removed. Edited images were visually checked against the supplied sources, but may differ in rendering or dimensions; they are presentation copies, not forensic originals.

## PowerShell evidence

| File | Evidence |
|---|---|
| `01-application-discovery-redacted.png` | Finance application discovery and existing IT assignment |
| `02-finance-role-assignment-redacted.png` | Enabled User role and successful assignment result |
| `03-final-it-validation-redacted.png` | Final IT department, group and application output |

## Azure portal inventory

| File | Step | Handling |
|---|---|---|
| [azure-01-user-creation.png](azure-01-user-creation.png) | Review the new Finance user | Privacy masks applied |
| [azure-02-users-list.png](azure-02-users-list.png) | Confirm Alex appears in Users | Privacy masks applied |
| [azure-03-finance-group-setup.png](azure-03-finance-group-setup.png) | Configure the Finance security group | No private values visible; original pixels retained |
| [azure-04-finance-app-overview.png](azure-04-finance-app-overview.png) | Inspect the Finance enterprise application | Privacy masks applied |
| [azure-05-assignment-navigation.png](azure-05-assignment-navigation.png) | Open assignment management | No private values visible; original pixels retained |
| [azure-06-finance-before-assignment.png](azure-06-finance-before-assignment.png) | Check the initially empty Finance assignment list | No private values visible; original pixels retained |
| [azure-07-select-finance-user.png](azure-07-select-finance-user.png) | Select Alex for Finance | Privacy masks applied |
| [azure-08-finance-user-assigned.png](azure-08-finance-user-assigned.png) | Verify the Finance assignment | No private values visible; original pixels retained |
| [azure-09-alex-user-overview.png](azure-09-alex-user-overview.png) | Review the test identity overview | Privacy masks applied |
| [azure-10-finance-job-properties.png](azure-10-finance-job-properties.png) | Review the original Finance attributes | No private values visible; original pixels retained |
| [azure-11-it-job-properties.png](azure-11-it-job-properties.png) | Prepare the IT department change | No private values visible; original pixels retained |
| [azure-12-finance-group-membership.png](azure-12-finance-group-membership.png) | Inspect the existing Finance membership | Privacy masks applied |
| [azure-13-it-group-setup.png](azure-13-it-group-setup.png) | Configure the IT security group | No private values visible; original pixels retained |
| [azure-14-finance-and-it-groups.png](azure-14-finance-and-it-groups.png) | Verify both department groups exist | Privacy masks applied |
| [azure-15-enterprise-app-list.png](azure-15-enterprise-app-list.png) | Review enterprise applications | Privacy masks applied |
| [azure-16-it-app-creation.png](azure-16-it-app-creation.png) | Prepare the IT application | No private values visible; original pixels retained |
| [azure-17-it-app-overview.png](azure-17-it-app-overview.png) | Verify the IT application exists | Privacy masks applied |
| [azure-18-select-it-user.png](azure-18-select-it-user.png) | Select Alex for IT | Privacy masks applied |
| [azure-19-it-user-assigned.png](azure-19-it-user-assigned.png) | Verify the IT application assignment | No private values visible; original pixels retained |
| [azure-20-finance-before-removal.png](azure-20-finance-before-removal.png) | Inspect Finance access before cleanup | No private values visible; original pixels retained |
| [azure-21-finance-assignment-removed.png](azure-21-finance-assignment-removed.png) | Verify Finance assignment removal | No private values visible; original pixels retained |
| [azure-22-new-group-form.png](azure-22-new-group-form.png) | Explore the next group configuration | No private values visible; original pixels retained |

## Privacy handling

Redactions include account names and initials, emails and tenant domains, local usernames, passwords or password-field content, tenant/object/application identifiers, assignment identifiers and clipped fragments of private values where present. Alex Johnson, generic lab attributes, group/application names and useful results remain visible. Original files containing private information and intermediate edits are excluded.

## Future additions

Continue Azure captures with `azure-23-short-description.png`; continue PowerShell evidence with `04-short-description-redacted.png`. Inspect the full frame, including clipped edges, address bars, prompts, account menus and error diagnostics. Cover private values permanently, strip metadata and inspect the exported file before publication.

Useful future evidence would include both Finance membership checks and a live execution of the packaged mover script. Those future captures are not claimed as completed tests.
