---
id: workflow
title: Workflow Engine (Preside 10.30+)
---

## Introduction

In Preside **10.30** we included an abstract stateful workflow engine system, [cfflow](https://pixl8.github.io/cfflow), with two concrete implementations for Preside. These have been used and road tested by Pixl8 in a private extension for several years.

This section covers the Workflow system, including guides, how-tos, and best practices for using and extending workflows in Preside.

### Webflow

Webflows are flows that are expected to be undertaken by an individual user in a single unified stepped flow interface. The webflow system provides default UI for the stepped flow process and provides a framework for developers to define flows, sub-flows and re-usable steps.

Once a flow has been defined by a developer, the system also provides UI for admin editorial users to configure the flow's editorial content + any developer defined configuration for the flow and its steps.

Flows can be developed for frontend websites and also for admin interfaces.

Read more: [[webflow]].

### Datamanager workflow

Datamanager workflow is a system whereby you can introduce JIRA-like workflows to any Preside object that is managed via datamanager.

In its current form, developers must define workflows and this creates a powerful system to introduce status flows for your entities.

Read more: [[datamanagerworkflow]].