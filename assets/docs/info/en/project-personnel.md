---
title: "Project personnel"
sidebar:
  order: 0
---

Personnel records represent people who participate in the project. A person is stored once in the database and can be assigned to multiple projects. Removing a person from this panel removes the project assignment; permanent deletion is managed in Settings.

## NAHPU roles

- **Cataloger:** records specimen data and may supply initials and a personal field number for Field IDs.
- **Determiner only:** identifies specimens but does not catalog or prepare them.
- **Preparator only:** prepares specimens but does not catalog them.
- **None:** participates in fieldwork without a specimen-care role.

These are NAHPU workflow roles that control what a person can be assigned to inside the app. They are not the same as the roles reported in an export, which follow each record’s actual relationships.

## Darwin Core context

A person is exported as an agent identified by `dwc:agentID`, taken from the ORCID when one is recorded and from the NAHPU identifier otherwise; personnel notes become `dwc:agentRemarks`. Specimen relationships supply the agent terms: the collector fills `dwc:recordedBy` and `dwc:recordedByID`, and the determiner fills `dwc:identifiedBy` and `dwc:identifiedByID`.
