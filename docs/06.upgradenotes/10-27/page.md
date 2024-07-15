---
id: 10-26-upgrade-notes
title: Upgrade notes for 10.26 -> 10.27
---

## Summary

The 10.27 release is mostly focused on better feature flagging in the core product. With this in mind, you will need to take some extra care when upgrading.

## Feature flagging

Prior to 10.27, many preside objects and services were available to the application, even when their features were not in use. From 10.27 onwards, extra effort is made to ensure that all parts of the system are appropriately feature flagged. This means that the system should run with fewer resources and create fewer database tables than before, especially when you have many disabled features.

The potential downside to this is that you may inadvertently be referencing services, handlers, views and objects that will no longer be available and your application will complain of missing resources. These will need to be tested and you **should never directly upgrade a production environment without testing first**.

Read the [[features]] documentation to familiarise yourself with the new feature flagging changes in Preside 10.27.