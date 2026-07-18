# Phase 2 gate interview — session prompt

> **Purpose.** Kickoff instructions for a Claude Code cloud session that
> conducts the Phase 2 phase-gate interview with Jonathan (answering from
> the Claude mobile app), records the decisions, and turns the Phase 2
> skeleton into a real plan. Start the session with:
> *"Read plans/phase-2-gate-interview-prompt.md and run the Phase 2 gate
> interview."*

## What to read first (in order)

1. [DECISIONS.md](DECISIONS.md) — the `## Open — settle at phase gates`
   table. This interview covers the rows gated on **Phase 2**: Q2, Q4, Q6,
   Q7, Q8, Q9.
2. [phase-2-features-0.4.0.md](phase-2-features-0.4.0.md) — the skeleton,
   especially which Tier 2 items are gated on which questions.
3. [archive/hdatools-design-review.md](archive/hdatools-design-review.md)
   §3 — the full context and recommended default for each question.
4. [ROADMAP.md](ROADMAP.md) — phase table and standing conventions.

## Interview protocol

- Ask **one question at a time**, in order (Q2, Q4, Q6, Q7, Q8, Q9). For
  each: state the question, summarize the design-review context in 2–4
  sentences (including what it gates in the Phase 2 plan), then give the
  recommended default and ask Jonathan to accept it or answer otherwise.
- Answers arrive from a phone — keep each turn compact and skimmable. If an
  answer is ambiguous or partial, ask a short follow-up before recording it.
- If an answer contradicts an already-settled decision in DECISIONS.md,
  stop and flag the conflict instead of overwriting.

## Recording answers

After each answer (not batched at the end), append a row to the
`## Settled` table in DECISIONS.md: today's date, the Q-ref, the decision
(lead with a bold phrase), the rationale Jonathan gave (or "accepted
recommended default"), and Binds scope. **Do not delete the Open-table
rows** — the log is append-only; the dashboard cross-references them
automatically.

## After all six answers

1. Update [phase-2-features-0.4.0.md](phase-2-features-0.4.0.md): remove
   the "Skeleton only" blockquote; set header **Status** to `not started`;
   expand the Tier 2 items into `## Session N — Title` sections shaped by
   the answers (drop or defer items the answers ruled out, and say why).
   Keep the phase-plan template conventions: header key/value table,
   `## Session N` headings, bold `**Goal:**` / `**Steps:**` /
   `**Verification:**` / `**Stop here if:**` labels, trailing `## Findings`
   with the "(none yet)" placeholder — the dashboard's parser depends on
   these anchors.
2. Update [ROADMAP.md](ROADMAP.md): Phase 2 status → `**next up**`; remove
   the `(skeleton)` suffix from its Plan file cell.
3. Do **not** touch the R package tree, and don't try to regenerate the
   dashboard here (its output is gitignored and the generator wants gh;
   Jonathan regenerates locally after merging).
4. Commit (imperative mood, **no Claude/Anthropic co-author line** — repo
   convention), push the session branch, and open a PR to `main` titled
   "Phase 2 gate: record interview decisions, finalize phase plan" with a
   short summary of each decision in the body.
