# Azure portal screenshot walkthrough

All 22 supplied Azure portal screenshots are included below, in the order supplied. They document the manual joiner/mover workflow before the PowerShell automation. Capture times belong to the supplied image files and are not asserted to be the time each lab action happened.

Images containing private details were edited with opaque privacy masks using AI-assisted image editing and visually checked against their sources. Images without private details retain their original pixels. All exported copies have image metadata removed. Edited copies are presentation derivatives and may differ in rendering or dimensions; they are not forensic originals.

## 01. Review the new Finance user

The creation review shows Alex Johnson, Financial Analyst, Finance, EMP001 and the generic lab attributes. This screen is a pre-creation review, not proof of submission.

![Review the new Finance user](azure-01-user-creation.png)

## 02. Confirm Alex appears in Users

The directory list includes Alex Johnson. The other account identity and user principal names are concealed.

![Confirm Alex appears in Users](azure-02-users-list.png)

## 03. Configure the Finance security group

The new-group form shows SG-Finance-Users, Security type, Assigned membership and one selected member. The form itself does not prove creation completed.

![Configure the Finance security group](azure-03-finance-group-setup.png)

## 04. Inspect the Finance enterprise application

Finance Portal - IAM Lab is present. Its application and object identifiers are concealed. The setup tiles do not establish that SSO or provisioning was configured.

![Inspect the Finance enterprise application](azure-04-finance-app-overview.png)

## 05. Open assignment management

The Assign users and groups tile identifies the next navigation step.

![Open assignment management](azure-05-assignment-navigation.png)

## 06. Check the initially empty Finance assignment list

No application assignments are displayed at this point, before the first assignment.

![Check the initially empty Finance assignment list](azure-06-finance-before-assignment.png)

## 07. Select Alex for Finance

Alex Johnson is selected in the user picker. Selection is an intermediate step, before the assignment result.

![Select Alex for Finance](azure-07-select-finance-user.png)

## 08. Verify the Finance assignment

Alex Johnson appears as a User in Finance Portal - IAM Lab assignment management.

![Verify the Finance assignment](azure-08-finance-user-assigned.png)

## 09. Review the test identity overview

Alex Johnson has one displayed group membership and one displayed application. User principal names and the user object ID are concealed.

![Review the test identity overview](azure-09-alex-user-overview.png)

## 10. Review the original Finance attributes

The job information form shows Financial Analyst, Finance and employee ID EMP001.

![Review the original Finance attributes](azure-10-finance-job-properties.png)

## 11. Prepare the IT department change

The job information form shows IT Support Analyst and Information Technology while keeping EMP001. Later validation, rather than this edit form alone, confirms the final department.

![Prepare the IT department change](azure-11-it-job-properties.png)

## 12. Inspect the existing Finance membership

The group list still shows the Finance group before its membership is removed. The name is truncated in the source, and its object ID is concealed.

![Inspect the existing Finance membership](azure-12-finance-group-membership.png)

## 13. Configure the IT security group

The new-group form shows SG-IT-Users with Assigned membership and one selected member.

![Configure the IT security group](azure-13-it-group-setup.png)

## 14. Verify both department groups exist

The directory lists SG-Finance-Users and SG-IT-Users as security groups. Object IDs are concealed. Group existence alone does not prove Alex belongs to either group.

![Verify both department groups exist](azure-14-finance-and-it-groups.png)

## 15. Review enterprise applications

The application list shows the Finance application. Its identifiers and homepage URL are concealed.

![Review enterprise applications](azure-15-enterprise-app-list.png)

## 16. Prepare the IT application

The creation form names IT Support Portal - IAM Lab and selects the non-gallery integration option. This is the creation form, not the completed result.

![Prepare the IT application](azure-16-it-app-creation.png)

## 17. Verify the IT application exists

The IT Support Portal - IAM Lab overview confirms the application exists. Its application and object IDs are concealed.

![Verify the IT application exists](azure-17-it-app-overview.png)

## 18. Select Alex for IT

The picker has Alex Johnson selected. The other account identity and all displayed email/domain values are concealed.

![Select Alex for IT](azure-18-select-it-user.png)

## 19. Verify the IT application assignment

Alex Johnson appears in IT Support Portal - IAM Lab assignment management.

![Verify the IT application assignment](azure-19-it-user-assigned.png)

## 20. Inspect Finance access before cleanup

Alex Johnson still appears in the Finance application assignment list before removal. This records the temporary overlap during the move.

![Inspect Finance access before cleanup](azure-20-finance-before-removal.png)

## 21. Verify Finance assignment removal

Finance Portal - IAM Lab displays No application assignments found after cleanup.

![Verify Finance assignment removal](azure-21-finance-assignment-removed.png)

## 22. Explore the next group configuration

The blank new-group form shows Assigned membership. It is a setup screen and does not demonstrate a dynamic rule or a completed dynamic group.

![Explore the next group configuration](azure-22-new-group-form.png)
