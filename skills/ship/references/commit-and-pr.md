# Commit message and PR body

## Good example

`commit-message.md`:

```
fix(billing): retry failed webhook deliveries (PROJ-123)

Webhook deliveries that failed with a 5xx were dropped silently.
Retries now run with exponential backoff, three attempts, and the
final failure is logged with the delivery id.
```

`pr-body.md`:

```
## Summary

- Retries a failed webhook delivery up to three times with backoff
- Logs the delivery id on final failure instead of dropping it

## Test plan

- `test run` green in acme.billing.api
- Added a unit test for the backoff schedule and the final-failure log line
```

Both are specific: the subject names the ticket, the body says what changed and why, the test plan names what was actually run — not "tests pass".

## Bad example

`pr-body.md`:

```
## Summary

Made some changes per the ticket.

## Test plan

Tested locally.
```

This names nothing a reviewer could act on. "Tested locally" names no command and no result — `standards check --stage ship`'s `pr` runner accepts the heading's presence, but a reviewer reading it later cannot tell what ran. A `commit-message.md` of "update code" is the same failure in miniature: no ticket key, no Conventional-Commit type, no reason.
