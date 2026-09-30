---
id: labs
title: Labs experiments
---

## Overview

>>> Labs feature introduced in **Preside 10.31**

Labs is a way to ship experimental admin behaviour that individual administrators can turn on, without making it the permanent behaviour of the application.

It is deliberately separate from [[features|feature flags]]. Feature flags are decided in code and change the makeup of the application, including its database structure. A Labs experiment is a runtime choice: the code for both behaviours is always present, and whether the experimental one is used is resolved per request from a code default, a site-wide setting and the logged-in administrator's own preference.

The `labs` feature flag (see [[features]]) is switched on automatically whenever at least one configurable experiment is registered, and it depends on the `admin` feature. With no configurable experiments registered, the Labs system settings page and the Edit profile Labs tab are hidden.

## Registering an experiment

Register experiments in your application's or extension's `Config.cfc`, inside `settings.labs.experiments`. The key is the experiment ID. The only setting is `mode`:

```luceescript
settings.labs                  = settings.labs ?: {};
settings.labs.experiments      = settings.labs.experiments ?: {};
settings.labs.experiments.myExperiment = {
    mode = "labsDefaultOff"
};
```

Extension and application configuration is loaded before Preside finalises the Labs setup, so registering here is enough. You do not add a field to the Labs system settings form: every configurable experiment appears there automatically.

### Modes

* `labsDefaultOff` is off until a site administrator enables it, or a user opts in. This is the default when `mode` is omitted or unrecognised.
* `labsDefaultOn` is on for everyone until a site administrator saves the Labs settings without it, or a user opts out.
* `alwaysOn` is always on. The experiment is not shown in system settings, Edit profile or the signpost, because there is nothing to configure. Use this once an experiment has graduated and you want the new behaviour everywhere while calls to `isLabEnabled()` remain in place.

An experiment registered with `labsDefaultOn` is seeded into the injected default for the `labs.enabled_experiments` system setting, so the Labs settings form shows it checked before anyone has saved that form. If the environment already supplies `labs.enabled_experiments` (see **Environment overrides** below), that list is used instead and the seed is skipped.

## Labels and descriptions

Each experiment needs a title and description in `/i18n/labs.properties`, keyed by the experiment ID:

```
myExperiment.title=My experiment
myExperiment.description=What turning this experiment on changes.
```

These two keys are the single source of copy. They are used for:

* the checkbox in **System > Settings > Labs**
* the fieldset title, description and field label on **Edit profile > Labs**
* the title in the navbar signpost that points administrators at new experiments


## Checking whether an experiment is enabled

In handlers and views:

```luceescript
if ( isLabEnabled( "myExperiment" ) ) {
    // experimental behaviour
}
```

In services that extend the [[presidesuperclass]]:

```luceescript
if ( $isLabEnabled( "myExperiment" ) ) {
    // experimental behaviour
}
```

An unknown experiment ID returns `false`. The result is cached for the rest of the request.

### Resolution order

For a known experiment, the result is decided in this order:

1. `alwaysOn` is on, regardless of settings and user preferences.
2. The logged-in administrator's own preference wins when it is `on` or `off`.
3. Otherwise the experiment is on when its ID appears in the site-wide `labs.enabled_experiments` setting.

`labs.enabled_experiments` is a comma separated list. Membership is case insensitive and matches whole IDs only. When nobody has saved the Labs settings, the list falls back to the injected default described above, which is the experiments registered as `labsDefaultOn`.

## Site-wide and per-user settings

**System > Settings > Labs** has a single *Enabled experiments* field: a checkbox per configurable experiment. Saving it stores one `enabled_experiments` value. This is the site-wide default.

**Edit profile > Labs** lets each administrator override that default per experiment:

* *Use system default* follows `labs.enabled_experiments`.
* *On* uses the experimental behaviour, even when it is off site-wide.
* *Off* uses the stable behaviour, even when it is on site-wide.

Preferences are stored per user in the `admin_lab_preference` object. The Edit profile tab is only rendered when `labsService.hasConfigurableExperiments()` is true.

A navbar signpost lists configurable experiments that are currently off for the logged-in user and have not been dismissed. Dismissing it does not change the user's on/off preference. No per-experiment work is required for the signpost beyond the `labs.properties` keys.

## Environment overrides

To fix the site-wide list from the environment, supply `labs.enabled_experiments` as an injected setting (a comma separated list of experiment IDs) before application start. When that key is already present, Preside does not replace it with the `labsDefaultOn` seed.

Core experiments may also read their own environment variable when choosing a mode, for example `LABS_DATATABLES_OVERHAUL` and `LABS_TIPTAP_EDITOR`, whose value is one of the modes above. That is part of each experiment's registration, not of the framework: an application experiment can do the same, or simply hard-code its mode.

