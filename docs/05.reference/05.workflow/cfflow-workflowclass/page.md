---
id: cfflow-workflowclass
title: "Workflow reference: CfFlow Workflow Class"
---

## CfFlow Workflow Class

In CfFlow, [workflow classes](https://pixl8.github.io/cfflow/guides/extending/workflowclass.html) are a single string identifier that can be used to tell CfFlow to use a particular combination of storage provider and scheduler.

Preside currently provides a single workflow class to use named `preside.standard.flow`. This class makes any instances of the flows that use it use our [[cfflow-storage|storage provider]] and [[cfflow-scheduler|scheduler]].

All [[webflows|Webflows]] and [[datamanagerworkflow|Datamanager Workflows]] use the `preside.standard.flow` workflow class.