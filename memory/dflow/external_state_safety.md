---
name: external_state_safety
description: Environment inventory and approval rules for secrets, IAM, deploy bindings, DNS, auth, and production traffic
---

Before writing a plan that changes external state, inventory the real deployed
state for every affected environment. Never infer production architecture from
develop, staging, sandbox, local configuration, or naming conventions.

Treat Secret Manager versions, IAM, deployment bindings, DNS, auth providers,
production traffic, and database connection settings as separate production
mutations. A code or build-config change does not authorize creating or updating
a production secret.

For DesignFlow DB configuration:

- develop uses the complete `*_DEV` five-tuple;
- staging uses the complete `*_STAGING` five-tuple;
- unsuffixed DB resources are production-only;
- never read or mutate an unsuffixed production DB secret without Albert's
  explicit production approval;
- a missing substitution must fail; it must never fall back to production;
- provider, host class, port, database, user class, resource ID, and numeric
  secret version must agree before a service starts;
- production deploys use no-traffic revisions, provider-aware smoke checks,
  gradual traffic, and a tested rollback.

Instructions and prompts are advisory. Enforce these boundaries in reviewed
infrastructure code, IAM, protected production environments, CI negative tests,
numeric secret-version pins, and audit alerts.
