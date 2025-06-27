---
id: datamanagerworkflow
title: Datamanager Workflow (Preside 10.30+)
---

# Datamanager Workflow

## Introduction

Preside **10.30** introduces Data manager workflow. This is a JIRA-like workflow
system for your preside objects, managed through admin data manager screens. A summary of working with the system:

1. Configure an object to be workflow enabled
2. Define and develop workflow(s) through a yml definition file
3. Enhance the flow with i18n, and any accompanying logic in handlers
4. Get an auto-generated UI in your data manager screens for users to progress a record through the flow and view/query its status
5. Get new rules engine filter expressions to query workflow state for your records
6. Use other helper functions in your datamanager logic that allow you to query the state of a record's workflow

![Figure 1: Datamanager Flow UI](images/screenshots/dmflow-example.png)

## Next steps

* Take the [[dmflowquickstart]]