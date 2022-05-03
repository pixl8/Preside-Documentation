---
id: 10-17-upgrade-notes
title: Upgrade notes for 10.16 -> 10.17
---

## Summary

The 10.17.0 is a minor release with no backward-compatibility concerns for developers. Some changes that you may want to be aware of, however, are listed below.

## Database indexes

The 10.17 release adds database indexes to foreign key fields in version tables (these fields are full foreign keys in the main table but have their FK contstraints removed in the version table). If you have particularly large version tables, you may want to plan for the potentially slow addition of indexes to these existing version tables:

[PRESIDECMS-2233](https://presidecms.atlassian.net/browse/PRESIDECMS-2233) - Version tables: no indexes on columns that were FKs

## New admin menu system

[PRESIDECMS-2293](https://presidecms.atlassian.net/browse/PRESIDECMS-2293) - Admin main menu: create more portable configuration system

This ticket has been developed with backward-compatibility in mind, and you are not required to update any code. However, you may wish to acquaint yourself with the changes which are documented here:

[[adminmenuitems]]

