# Activity Contracts (v2)

## Purpose

This document is the source of truth for route JSON activities in Flutter Quest.

Goals:
- one official shape per activity type
- stricter content validation
- less ambiguous code exercises
- reusable authoring rules for open-source contributors

---

## Global principles

1. Every evaluable step must include:
- `correctExplanation`
- `incorrectExplanation`
- `xpReward`

2. Add explicit clarity for open-ended coding prompts:
- `acceptanceCriteria` (user-visible checklist)
- `validationMode` (`exact`, `multiAnswer`, `containsTokens`, `regex`)
- `acceptedAnswers` when more than one valid solution exists
- `requiredTokens` / `forbiddenTokens` for intent-based validation
- `errorTolerance` for minor syntax variance

3. If naming is strict, say it:
- `namingPolicy: fixed` and provide expected names/tokens
- optional `suggestedName` for better guidance

4. Prerequisites are explicit:
- `prerequisites: ["node_id_a", "node_id_b"]`
- all prerequisites must reference previous nodes in the same route

---

## New common optional fields (evaluable steps)

```json
{
  "validationMode": "multiAnswer",
  "acceptedAnswers": ["for (var i = 0; i < 4; i++)", "for (var i = 0; i <= 3; i++)"],
  "requiredTokens": ["for", "i++", "print"],
  "forbiddenTokens": ["while"],
  "acceptanceCriteria": [
    "Itera de 0 a 3",
    "Imprime un valor por vuelta"
  ],
  "customKeywords": ["UserRepository", "loadProducts", "setState"],
  "suggestedName": "UserRepository",
  "namingPolicy": "flexible",
  "errorTolerance": {
    "allowMissingSemicolon": true,
    "allowWhitespaceVariance": true,
    "allowQuoteStyleVariance": true
  },
  "prerequisites": ["dart_loops"]
}
```

### Validation modes

- `exact`: strict-ish match with tolerance options
- `multiAnswer`: any answer in `acceptedAnswers` is valid
- `containsTokens`: valid when all `requiredTokens` are present and no forbidden token appears
- `regex`: valid when any regex pattern in `acceptedAnswers` matches

---

## Type-specific contract (official)

### `intro`
Required:
- `id`, `type`, `title`, `body`
Optional:
- `example`
Not evaluable.

### `multipleChoice`
Required:
- `id`, `type`, `question`, `options`, `correctAnswer`, `correctExplanation`, `incorrectExplanation`, `xpReward`
Optional:
- `shuffle` (default true)
- common optional fields (except errorTolerance is ignored)
Rule:
- `correctAnswer` must exist in `options`.

### `fillInTheCode` / `completeSnippet` / `fixTheBug`
Required:
- `id`, `type`, `prompt`, `initialCode`, `expectedAnswer`, `correctExplanation`, `incorrectExplanation`, `xpReward`
Optional:
- `hint`
- all common optional fields

### `orderCodeBlocks`
Required:
- `id`, `type`, `prompt`, `blocks`, `correctOrder`, `correctExplanation`, `incorrectExplanation`, `xpReward`
Optional:
- `shuffle` (default true)
- `acceptanceCriteria`, `customKeywords`, `prerequisites`
Rule:
- `correctOrder` must be a permutation of `blocks`.

### `findTheWrongLine`
Required:
- `id`, `type`, `prompt`, `codeLines`, `wrongLineIndex`, `correctExplanation`, `incorrectExplanation`, `xpReward`
Optional:
- `acceptanceCriteria`, `prerequisites`
Rule:
- `wrongLineIndex` must be within codeLines bounds.

### `matchConcept`
Required:
- `id`, `type`, `prompt`, `pairs`, `correctExplanation`, `incorrectExplanation`, `xpReward`
Optional:
- `shuffle` (default true)
- `acceptanceCriteria`, `prerequisites`
Rule:
- only `pairs` is allowed; no legacy alternatives.

### `predictOutput`
Required:
- `id`, `type`, `question`, `codeSnippet`, `options`, `correctAnswer`, `correctExplanation`, `incorrectExplanation`, `xpReward`
Optional:
- `shuffle` (default true)
- common optional fields

### `guidedWriting`
Required:
- `id`, `type`, `instructions`, `starterCode`, `expectedFragments`, `correctExplanation`, `incorrectExplanation`, `xpReward`
Optional:
- `hint`
- common optional fields
Rule:
- `starterCode` can be empty string when writing from scratch.

---

## Authoring recommendations (important)

1. Avoid hidden requirements.
- If class/function names are required, state them in prompt and criteria.

2. Prefer `multiAnswer` or token-based checks for equivalent logic.
- Example: `i < 4` and `i <= 3` should both pass.

3. Don’t introduce concepts before they are taught.
- Use `prerequisites` and route sequencing discipline.

4. Technical precision matters.
- Use precise definitions (e.g., Flutter is an SDK).

---

## Migration notes from v1

- Legacy strict-only coding checks are deprecated.
- New content should include at least one of:
  - `acceptedAnswers`
  - `requiredTokens`
  - `acceptanceCriteria`
- Existing JSON remains compatible; new fields are optional.
