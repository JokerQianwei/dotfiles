---
name: find-simplifications
description: 'Use when finding non-obvious simplification candidates in a codebase, especially dead, duplicated, speculative, over-built, added-then-removed, or hand-rolled-where-a-dependency-exists surfaces. Produces evidence-backed proposals or targeted TODO/FIXME/XXX notes.'
---

# Finding Simplifications

Turn a broad "find things to simplify" request into evidence-backed proposals that remove or collapse existing surface area. This is guidance, not a checklist: follow the code, keep judgment active, and prefer a few well-proven candidates over a pile of thin guesses.

## Start With Repo Context

- Read the applicable `AGENTS.md` files and repository documentation for architecture, testing, dependencies, and defensive patterns.
- Inspect decision records and current code before judging an unusual seam. Tests and historical decisions are evidence, not unquestionable truth.
- Record explicit user constraints and protected designs before looking for deletion candidates.

## What Counts As A Strong Candidate

A strong simplification removes, folds, or demotes something real and has clear evidence that the current design costs more than it buys:

- A public method, event, config knob, registry notification, helper, package, durable event, or test artifact has no production consumer.
- Tests or docs are the only consumers, and the behavior they pin is not load-bearing.
- Two representations mirror the same fact, especially across durable session events and transient `agent/*` events.
- A seam has methods every implementation must support but no consumer uses.
- A separate package exists only for test/demo/support code and adds publish or dependency overhead.
- A feature implements speculative product generality: multi-session/session-load, background job rosters, live registry invalidation, mid-turn steering, tool-owned UI rendering, and similar designs with no product owner.
- An invariant, rollback path, set of expected outputs, or special-case test exists only to protect an unused API.
- Hand-rolled code reimplements what a well-maintained external package or a standard-library facility at the supported runtime floor already provides, and the swap would delete the implementation plus its dedicated tests.
- The simplified behavior may differ slightly, but the new behavior is still reasonable and easier to explain.

Thin candidates are usually not enough for a durable proposal: deleting one typo, running an unused-code detector once, removing an intentionally documented backend/adapter, or flagging "this looks complex" without call-site proof.

## Survey Broadly

Use parallel subagents when the user asks for breadth or many candidates. Give each agent a domain and require evidence, not guesses. Useful domains:

- Runtime and persistence: state boundaries, cancellation, durable events, replay, and recovery.
- Public interfaces and UI: protocol settlement, teardown, rendering, and interaction state.
- Tools and execution: foreground/background ownership, output bounds, subprocesses, and adapters.
- Packages, examples, scripts, and tests: package splits, static inventories, redundant snapshots, and support-only modules.

If subagents are unavailable, simulate the same breadth yourself. Do not let the first good candidate stop the survey.

Start with the largest production-code deltas. A broad simplification audit that stops after obvious unused symbols can miss the files where duplicated lifecycle or defensive machinery carries most of the cost.

## Audit Trust And Lifecycle Boundaries

For every defensive copy, freeze, validator, and callback capture, name where the value came from and who owns it next. Same-process typed service/plugin calls ordinarily borrow readonly values; parsers, config loaders, queues, model/tool JSON, durable files, workers, processes, and wire decoders own or validate their data. Tests built around hostile getters, fake typed objects, callback replacement, or mutation after a same-process handoff are evidence of a potentially speculative contract, not automatic justification for keeping it.

For complex asynchronous code, draw the ownership graph and map each sentinel, readiness promise, cancellation path, disposer, and state flag to a distinct owner or transition. When several mechanisms mirror the same liveness or settlement fact, propose one transaction or lifecycle controller instead. Preserve separate machinery where it protects synchronous publication and rollback, callback containment, first-terminal-outcome arbitration, worker/process ownership, or dispose-to-quiescence.

## Hand-Rolled Code Versus A Dependency

Introducing a dependency can be a simplification move when repository policy permits it. When surveying protocol parsers, framers, retry/backoff loops, glob matchers, diff engines, and similar infrastructure, ask whether a well-maintained package or standard-library facility at the runtime floor already does the job.

Prove a dependency-swap candidate like any other, plus:

- Read the hand-rolled implementation and name the exact surface the package covers; residual semantics the package does not cover count against the swap and stay in the proposal.
- Check the package's health honestly (maintenance, adoption, transitive footprint) and prefer builtins when the engine floor has them.
- Check decision records first. A swap that collapses a recorded seam must beat its rationale, not merely cite a general dependency preference.
- Weigh net deletion: implementation plus dedicated tests plus docs, minus the glue that remains. A wrapper that relocates the same complexity is not a win.

## Prove Or Reject Each Candidate

For every symbol or behavior, classify consumers before writing:

- Production corpus: shipped source, runtime scripts, examples that are product entry paths, loaders, and configuration paths.
- Non-production corpus: tests, README/docs, decision records, snapshots, generated expected outputs, and comments.
- Ambiguous corpus: examples and scripts that may be product smoke paths. Inspect usage before classifying.

Use `rg` first. Good searches include the exact symbol, event name, package name, config key, method name with both `.name(` and `name(`, and any wire strings. Then read the call sites. Unused-code tools can help, but they do not replace understanding public interfaces, dynamic names, tests, docs, loaders, and configuration.

Reject or downgrade a candidate when:

- A production caller exists and the simplification would be a feature decision rather than a cleanup.
- The API is explicitly justified by a decision record or a hard-won defensive pattern, and the new evidence does not beat that reason.
- The removal would force unrelated churn without actually reducing the public API or required behavior.
- The idea is correct but tiny. Add a targeted TODO/FIXME/XXX instead, following repository conventions.

## Record Durable Decisions

Use the repository's existing decision-record format when a simplification changes public behavior, architecture, durable data, protocol shape, or another choice maintainers may reasonably revisit. If no such format exists, report an evidence-backed proposal without creating new documentation infrastructure.

A durable proposal should name the current surface and its consumers, state exactly what to remove or fold, present the strongest reason to keep it, describe the capability given up, define the observable end state, and identify risks and validation. Update an existing owner instead of creating a duplicate.

When a simplification fully supersedes an older decision, preserve its unique rationale, alternatives, consequences, verification evidence, and reintroduction conditions in the current owner before deleting it. Keep partially superseded records cross-linked.

## Inline TODO Notes

Use inline TODO/FIXME/XXX only for small, local cleanups that are clearly useful but not durable design decisions. Follow repository conventions and keep them short and actionable:

- Name the smell with a stable tag, e.g. `TODO(double-default)` or `XXX(unused-default)`.
- Explain why it is safe to revisit and what action would simplify it.
- Do not add TODOs for speculative complaints or for behavior that needs a durable decision record.

## When Folding Another PR Or Branch

Diff the sibling branch against its verified base, not against the current working branch, so you see its independent contribution. For each item:

- Port non-overlapping decision records or TODOs that meet the quality bar.
- Consolidate overlapping material into the existing record that owns the topic.
- Do not port duplicate or lower-confidence proposals just to preserve the count.
- Update the PR body so reviewers see the true candidate count and scope.
- Close the duplicate PR only when the user asked you to, or when you clearly own that housekeeping.

## Validation And PR Hygiene

Run the narrow checks that cover the changed surface, plus repository-required documentation, lint, type, test, or build gates and `git diff --check`. Do not claim checks supplied by hooks or CI unless they actually ran and passed.

When opening or updating a PR, summarize:

- How many durable records and inline notes were added, consolidated, retained as partial supersessions, or deleted.
- The main areas surveyed.
- What was intentionally excluded.
- Which checks passed.

For each consolidation group, name the old and current owners, state the evidence for full supersession, and explain why deletion is safe. If an added-then-removed scan finds no qualifying note, report that result and the representative partial cases retained.

Use a draft PR while the survey is still expanding; mark ready only when the candidate set, review responses, and validation are settled.
