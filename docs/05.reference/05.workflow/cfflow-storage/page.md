---
id: cfflow-storage
title: "Workflow reference: CfFlow Storage Provider"
---

## CfFlow Storage Provider

Preside provides Preside Objects and registers the [[api-cfflowpresidestorage|CfFlowPresideStorage service]] to act as CfFlow instance storage (see [CfFlow instance storage documentation](https://pixl8.github.io/cfflow/guides/extending/statestorage.html) for further details).

The storage provider ID is `preside.standard.db`.

### Data model

The table and diagram below shows how the data model for workflow instance persistence is constructed. See table and links for links to the object references themselves.

#### ERD

{% mermaid %}
classDiagram
   cfflow_workflow_instance --* cfflow_workflow_instance_step
   cfflow_workflow_instance --* cfflow_workflow_instance_history
   cfflow_workflow_instance_history --* cfflow_workflow_instance_history_transition
   cfflow_workflow_archived_instance *-- cfflow_workflow_instance
   cfflow_workflow_instance : Core record for a single active instance
   cfflow_workflow_instance_step : Status of any given step in the current instance
   cfflow_workflow_instance_history : Records actions and the state at time of action for a given instance
   cfflow_workflow_instance_history_transition : Details of step transition changes for each historic action
   cfflow_workflow_archived_instance : Archived workflow instances for metrics
{% endmermaid %}

#### Object list

| Object | Description |
|-------|--------|
| [[presideobject-cfflow_workflow_instance]]                    | Core record for a single active instance |
| [[presideobject-cfflow_workflow_instance_step]]               | Status of any given step in the current instance |
| [[presideobject-cfflow_workflow_instance_history]]            | Records actions and the state at time of action for a given instance |
| [[presideobject-cfflow_workflow_instance_history_transition]] | Details of step transition changes for each historic action |
| [[presideobject-cfflow_workflow_archived_instance]]           | Archived workflow instances for metrics |