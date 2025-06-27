---
id: cfflow-scheduler
title: "Workflow reference: CfFlow Scheduler"
---

## CfFlow Scheduler

In CfFlow, schedulers are used to implement delayed and repeated evaluation and execution of automatic conditional actions. For example:

> Wait on this step for at least three days, then check daily whether the contact has completed their profile. If they have, move to next step in the flow.

Preside provides an implementation based on the [[taskmanager-adhoctasks|Preside adhoc task system]].

The implementation can be found under the [[api-cfflowpresidescheduler|CfFlowPresideScheduler service]]. It is registered with the ID: `preside.scheduler`.