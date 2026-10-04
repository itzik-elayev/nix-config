# Personal engineering preferences

<!-- TOP:START -->
## TOP RULES — always apply

- Comments: only when non-obvious; max 2 lines; explain *why* not *what*; no ticket/conversation refs; stand alone.
- No magic numbers or strings — extract named constants.
- Functions small, do one thing; args 0-2, no boolean-flag args (split instead).
- DRY: reuse/consolidate existing code before adding; don't force abstraction over things only alike today.
- No stray debug prints; log at right level with source component + key-value context.
- Output: terse, bullets/code over prose, no hedging or fluff.
- Commits: Conventional Commits, imperative subject, body only when the why isn't obvious.
- Docs/comments stand alone: no session/ticket refs, no real customer/backend names as examples — write for a cold reader.
<!-- TOP:END -->

## Process

- TDD: write the failing test first, then the minimum code to pass it, then refactor.
- Before writing new code, search for similar existing code and consolidate instead of duplicating.
- Minimize code duplication overall — extract shared logic once a pattern repeats, not before.

## Code style

Clean code, per Robert C. Martin's *Clean Code*:

- Functions: small, do one thing, one level of abstraction per function.
- Names: intention-revealing, pronounceable, searchable. No abbreviations, no single letters except trivial loop indices. No noise words (`data`, `info`, `manager`) unless they add meaning.
- Function args: fewer is better. 0-2 ideal, 3 needs justification, avoid boolean flag args (split into two functions instead).
- No side effects hidden behind a name that doesn't say so.
- Stanza formatting: one blank line between each logical step in a function (error check, declaration, mutation, side effect, return) — no dense unbroken blocks.
- Prefer exceptions over error codes; don't return null, don't pass null.
- DRY — no duplication, but per the "similar code" rule above, don't force an abstraction over things that only look similar today.
- No comments by default. Comments are a failure to express intent in code — first try to make the code self-explanatory (rename, extract function) before reaching for a comment.
- Add a comment only when the code is genuinely non-obvious (tricky algorithm, workaround, non-standard control flow) and cannot be clarified further by rewriting.
- When a comment is needed: max 2 lines, precise, technical, no filler words.
- Don't explain *what* the code does (names should do that) — only *why*, when the why isn't obvious.
- Comments must stand alone with no reference to the current task, conversation, or ticket — a future reader has none of that context. No "fixed per review", no "changed because user asked", no issue links as the only explanation.
- No commented-out code, no journal comments, no closing-brace comments.
- No magic numbers or strings — extract to named constants.
- Booleans named with `is`/`has`/`should`/`can` prefix — no bare adjectives (`valid`, `active`) as variable names.

## Writing for the repo, not the session

When editing or authoring code comments, documentation, runbooks, or shared instruction files (AGENTS.md, CLAUDE.md, READMEs, design docs — not commit messages, PR descriptions, or chat replies, which may reference the current task) — write for a reader who has none of this conversation's context and is opening the file cold, possibly months later.

- Never write "as we found", "this session", "earlier in this conversation", "the user asked", or a ticket/PR number as the only explanation for a rule. State the rule and its rationale so it stands alone without that context.
- Never use a real customer, tenant, or backend name as a worked example — not even a genuinely representative one. Invent a generic placeholder (acme-corp, cluster-a/cluster-b, `<name>`) or reuse a placeholder convention the doc already has.
- When a real environment's data grounds a formula, threshold, or constant, keep what was observed and the derivation — but strip its specific identity from the prose. The reasoning must be fully intact without knowing which cluster it came from.
- Before finishing an edit to a shared doc, do one pass specifically hunting for: session-specific phrasing, real customer/backend names used as examples, and any claim that only makes sense to someone who was in this conversation.

## Planning output

- TLDR style always. Bullet points and code blocks, not prose.
- Be short. Prefer code blocks over prose explanations.
- Don't write long paragraphs — text is tiring to read, code is faster to scan.
- Get to the point: technical, precise, no hedging, no padding, no fluff.

## Commit messages

- Conventional Commits format (`feat:`, `fix:`, `refactor:`, etc).
- Short subject line, imperative mood, no trailing period.
- Body only when the why isn't obvious from the diff — no restating what changed line by line.

## Dependencies

- Minimal dependencies. Justify any new package before adding it — check if the stdlib or an existing dependency already covers it.

## Logging

- No stray debug `console.log`/`print` statements left in code — use the project's logger.
- Log at the right level: `trace`/`debug` for step-by-step flow, `info` for meaningful state changes, `error` for failures.
- Every log line should make it clear what the code is doing and where execution currently is.
- Include all relevant key-value context in the log line itself (ids, inputs, state) — a log line should be understandable without reading the surrounding code.
- Every log line identifies its source component/subsystem (module name, service name, or logger namespace) — never ambiguous which part of the system emitted it.

## Security

- Validate input only at trust boundaries (user input, external APIs) — trust internal code and framework guarantees elsewhere.
- Never hand-roll auth or crypto — use vetted libraries/standards.
- Proactively flag OWASP-class issues (injection, XSS, broken auth, etc) when spotted, even if not asked to review for them.

## Feedback style

- Be judgmental, not agreeable. If something is wrong, bad practice, or a worse option, say so directly.
- Do not soften critique to be polite. Do not praise by default.
- If asked to review or choose between options, give a clear verdict with a reason, not a balanced-sounding non-answer.
