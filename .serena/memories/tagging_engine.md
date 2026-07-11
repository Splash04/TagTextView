## Tagging engine internals (`UITagTextView.swift`)

- `tagRegex` is lazily rebuilt only when `mentionSymbol`/`hashTagSymbol` actually change
  (`_cachedTagRegex`/`_cachedTagRegexPattern`), not recompiled per keystroke.
- `updateAttributeText` mutates `textStorage` in place (`beginEditing`/`setAttributes`/`endEditing`)
  instead of reassigning `.attributedText`, specifically so the caret/selection is never reset as a
  side effect; a negative `selectedLocation` means "leave caret alone" (used for passive/background
  refresh calls like `recalculateAttributes`).
- Marked-text (IME/predictive) state machine, in this order of precedence:
  1. While `markedTextRange != nil`, `textViewDidChange`/`shouldChangeTextIn` skip attribute rewriting
     and tag-range mutation entirely, only setting `needsPostCompositionRefresh = true` — iOS owns the
     caret during composition.
  2. Once composition ends (`markedTextRange == nil` again) and `wasMarkedTextActive`/
     `needsPostCompositionRefresh` is set, `fixedWhenMarkedTextUnmatch()` runs once to re-derive
     `arrTags` ranges from a fresh regex scan (`findMentions()`), because composition can silently
     desync the manually-tracked ranges.
  3. `recalculateAttributes()` (called externally, e.g. from the SwiftUI `Coordinator.update`) is a
     no-op while `markedTextRange != nil` for the same reason.
- Deleting a character inside an existing tag's range removes that tag from `arrTags` and collapses the
  tag to a single space (via `textStorage.replaceCharacters`, not `.text =`, again to preserve caret
  state) rather than deleting the whole tag text.
- `textLengthLimit` enforcement interacts with tag insertion: `addTag` will truncate the tag text itself
  to fit the remaining budget rather than rejecting the insert outright.
- See `mem:conventions` for where this fits in the wider architecture; see `docs/ARCHITECTURE.md` in the
  repo for the same material written for non-Serena-equipped agents/humans.
