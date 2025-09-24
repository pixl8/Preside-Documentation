---
id: cfflow-storage
title: "Workflow reference: CfFlow Storage Provider"
---

## CfFlow Storage Provider

Preside provides Preside Objects and registers the [[api-cfflowpresidestorage|CfFlowPresideStorage service]] to act as CfFlow instance storage (see [CfFlow instance storage documentation](https://pixl8.github.io/cfflow/guides/extending/statestorage.html) for further details).

The storage provider ID is `preside.standard.db`.

### Data model

The table and diagram below shows how the data model for workflow instance persistence is constructed. See table and links for links to the object references themselves.

#### Database Structure

The CfFlow storage system uses a relational database structure with the following objects and relationships:

**Core Objects:**

* **`cfflow_workflow_instance`**
	* The main table that stores core records for each active workflow instance

**Related Objects:**

* **`cfflow_workflow_instance_step`**
	* Stores the status of each step within a workflow instance
	* Has a one-to-many relationship with `cfflow_workflow_instance`
	* Each workflow instance can have multiple steps

* **`cfflow_workflow_instance_history`**
	* Records all actions performed and the state at the time of each action
	* Has a one-to-many relationship with `cfflow_workflow_instance`
	* Each workflow instance can have multiple history records

* **`cfflow_workflow_instance_history_transition`**
	* Stores detailed information about step transition changes
	* Has a one-to-many relationship with `cfflow_workflow_instance_history`
	* Each history record can have multiple transition details

* **`cfflow_workflow_archived_instance`**
	* Stores archived workflow instances for metrics and historical analysis
	* Has a one-to-one relationship with `cfflow_workflow_instance`
	* Contains archived copies of completed workflow instances

#### Object list

<div class="table-resp">
    <table class="table">
        <thead>
            <tr>
                <th>Object</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>[[presideobject-cfflow_workflow_instance|cfflow_workflow_instance]]</td>
                <td>Core record for a single active instance</td>
            </tr>
            <tr>
                <td>[[presideobject-cfflow_workflow_instance_step|cfflow_workflow_instance_step]]</td>
                <td>Status of any given step in the current instance</td>
            </tr>
            <tr>
                <td>[[presideobject-cfflow_workflow_instance_history|cfflow_workflow_instance_history]]</td>
                <td>Records actions and the state at time of action for a given instance</td>
            </tr>
            <tr>
                <td>[[presideobject-cfflow_workflow_instance_history_transition|cfflow_workflow_instance_history_transition]]</td>
                <td>Details of step transition changes for each historic action</td>
            </tr>
            <tr>
                <td>[[presideobject-cfflow_workflow_archived_instance|cfflow_workflow_archived_instance]]</td>
                <td>Archived workflow instances for metrics</td>
            </tr>
        </tbody>
    </table>
</div>