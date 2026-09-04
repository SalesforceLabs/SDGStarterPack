# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Salesforce **managed 2GP package** (AppExchange: "SDG Starter Pack" by Salesforce Labs) for tracking organizational outcomes against UN Sustainable Development Goals. Metadata is `sfdx` source format under `force-app/`, orchestrated with **CumulusCI**. Namespace: `sdgsfdev`. API version: `58.0`.

## Commands

Development uses CumulusCI, not raw `sf` for the common loop. DevHub alias is `TTSDevHub`; scratch org def is `orgs/dev.json`.

```bash
cci flow run dev_org --org tts_dev        # spin up + deploy + assign perms to a dev scratch org
cci flow run qa_org --org tts_qa          # QA org build
cci task run retrieve_changes --org tts_dev   # pull org changes back to source
cci task run run_tests --org tts_dev      # Apex tests, enforces 75% coverage (cumulusci.yml)
cci task run robot --org tts_dev          # Robot Framework UI tests (robot/SDGStarterPack/tests)
cci task run load_dataset --org tts_dev   # load sample data (datasets/mapping.yml)
```

Run a single Apex test class directly:
```bash
sf apex run test --tests SDG_Get_Latest_List_Test --result-format human --code-coverage -o tts_dev
```

Packaging (maintainers) — package id `0HoDm000000CaU1KAK`, see `sfdx_commands.txt` / `CONTRIBUTING.md`:
```bash
sf package version create --package 0HoDm000000CaU1KAK --target-dev-hub TTSDevHub --installation-key-bypass --code-coverage --wait 10
sf package version promote --target-dev-hub TTSDevHub --package 04t...
```

## Architecture

### Namespace (important)
Apex references custom objects/fields with the `sdgsfdev__` prefix (e.g. `sdgsfdev__SDG_Goal__c`, `sdgsfdev__Code__c`). New Apex touching package objects must use this prefix or it won't compile against the packaging org.

### Data model — two layers
1. **Reference data, synced from the UN API** (read-only catalog of the 17 SDGs):
   `SDG_Goal__c` → `SDG_Goal_Target__c` (lookup `Goal__c`) → `SDG_Target_Indicator__c` (lookup `Goal_Target__c`). Every record is keyed by an external-id `Code__c` and written via `upsert ... Code__c`.
2. **User tracking data**:
   `SDG_Outcome__c` (lookups to `Goal__c`, `Goal_Target__c`, `Target_Indicator__c`) → `SDG_Outcome_Measure__c` (lookup `SDG_Outcome__c`). This is what customers create to record progress.

### UN API sync pipeline (`classes/SDG_Get_Latest_List.cls`)
A chained async callout flow against `https://unstats.un.org/sdgapi` (allowed via the `SDG_API` remote site setting):

`invocableFetchGoals` (Flow entry point) → `fetchGoals()` synchronous callout, upserts Goals → enqueues one `AsyncFetchTargets` Queueable per goal → `fetchTargets()` `@future(callout=true)` fetches targets+indicators, upserts Targets → enqueues `AsyncBulkInsertIndicators` Queueable → bulk-upserts Indicators.

The chaining exists to stay under callout/DML governor limits. Callouts are **skipped when `Test.isRunningTest()`** — the test class exercises the deserialization/upsert paths, not live HTTP.

### Automation (Flows, `flows/`)
- `SDG_Weekly_SDG_Information_Checker` — **Scheduled** flow; calls the invocable above to refresh reference data weekly.
- `SDG_Ensure_Outcome_is_Linked_to_Goal` — record-triggered before-save on Outcome.
- `SDG_Check_and_Update_Outcome_Status` — record-triggered after-save on Outcome.
- `SDG_Set_Status_for_Measure` — record-triggered after-save on Measure.
- `SDG_Initial_Setup_Flow` — screen flow for post-install setup.

### Access
Two permission sets: `SDG_Admin` (config) and `SDG_User` (base). `dev_org`/`qa_org` flows assign `SDG_Admin`. Custom app: `Sustainable_Development_Goals`.

## Conventions
- All package metadata is prefixed `SDG_`.
- Reference-data records are matched by `Code__c`; never insert them without upsert-on-Code or you'll create duplicates on the next sync.
- Minimum Apex coverage is 75% (enforced by `run_tests` and package version create).
