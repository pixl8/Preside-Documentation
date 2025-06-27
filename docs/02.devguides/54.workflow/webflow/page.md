---
id: webflow
title: Webflow (Preside 10.30+)
---

## Webflow (Preside 10.30+)

### Introduction

**Webflows** are a powerful abstraction on top of [CfFlow](https://pixl8.github.io/cfflow) that enable developers to define user journeys defined as `yml` workflow files. They provide a framework for developers and a unified user experience for webmasters and editors.

![Figure 1: Webflow admin screen](images/screenshots/webflow-admin-screen.png)

### What are Webflows

Webflows...

* Are defined through a [[cfflowreference|documented schema]]
* Automatically generate admin screens for editing editorial content and flow _configuration_
* Takes care of all the handler and layout logic of rendering, submitting and journeying through the steps of your flow
* Can be broken down into re-usable steps and subflows
* Are highly configurable; you can override and extend layouts, configuration forms, etc.

### What should they be used for

Webflows could/should be used for:

* Login/register flows
* Event registration flows
* Membership application flows
* Shopping checkout flows
* Any other flow that a **single user undertakes from start to finish through a series of web page steps**

### Tutorials

* Take the [[webflowquickstart|Quick start tutorial]]
* Take the [[webflowglobalsteps|Defining global steps tutorial]]
* Take the [[webflowsubflows|Defining subflows tutorial]]

### Further reading and how-tos

* [[webflowcancellation]]
* [[webflowstyling]]
* [[webflowsubflowconfig]]
* [[webflowextendsubflowstepconfig]]
