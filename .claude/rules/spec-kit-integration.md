<!-- ~/.claude/rules/spec-kit-integration.md -->

# Spec-Kit + Superpowers Integration

## Before Any Implementation Work

1. ALWAYS check `.specify/memory/constitution.md` for global constraints
2. Read the current feature's spec files in `.specify/<feature>/`
3. Verify all tasks in `tasks.md` before starting

## During Implementation

1. Follow Superpowers TDD workflow for each task:
   - brainstorm → write-tests → implement → run-tests → code-review
2. Ensure all CONSTITUTION constraints are met
3. Update implementation notes in relevant spec files

## After Implementation

1. Run Superpowers code review
2. Verify against spec acceptance criteria
3. Mark completed tasks in `.specify/<feature>/tasks.md`

## ⚠️ Do NOT

- Skip the specification phase
- Implement without checking constitution.md
- Merge code that violates defined constraints
