# CodeX-Ray — AI Skill Guide
# This file tells any AI editor how to use CodeX-Ray when the user asks to analyze a project.

## Tool Location
```
PLUGIN_ROOT = ~/.codex-ray/codex-ray-plugin
SKILL_DIR   = $PLUGIN_ROOT/skills/understand
AGENTS_DIR  = $PLUGIN_ROOT/agents
CORE_DIR    = $PLUGIN_ROOT/packages/core
```

On Windows: replace `~` with `%USERPROFILE%` (e.g. `C:\Users\<user>\.codex-ray\codex-ray-plugin`)

## Trigger Phrases
When the user says any of these, activate CodeX-Ray:
- "analyze the project" / "analyze this codebase"
- "understand this project" / "understand the code"
- "create knowledge graph" / "map the codebase"
- "update the graph" / "re-index" / "reanalyze changes" → use /understand-update
- "حلل المشروع" / "افهم المشروع" / "خريطة الكود"
- "حدّث الخريطة" / "أعد الفهرسة" → use /understand-update
- "/understand" or any /understand-* command

## Prerequisites Check (run once per session)
```bash
node --version   # Must be 22+
test -f "$PLUGIN_ROOT/packages/core/dist/index.js"  # Must exist
# If not built: cd $PLUGIN_ROOT && pnpm install && pnpm --filter @codex-ray/core build
```

## Pipeline Execution

Execute ALL 7 phases sequentially. Do NOT skip any phase.

### Phase 0: Pre-flight
```bash
PROJECT_ROOT="<user's target project path>"
mkdir -p "$PROJECT_ROOT/.codex-ray/intermediate"
mkdir -p "$PROJECT_ROOT/.codex-ray/tmp"
```
- Read README.md (first 3000 chars)
- Read package.json / pyproject.toml / composer.json
- Check if knowledge-graph.json already exists → decide full vs incremental

### Phase 1: SCAN
```bash
node "$SKILL_DIR/scan-project.mjs" "$PROJECT_ROOT" "$PROJECT_ROOT/.codex-ray/tmp/ua-scan-files.json"
```
Read the output JSON. Then extract import map:
```bash
node "$SKILL_DIR/extract-import-map.mjs" "$PROJECT_ROOT/.codex-ray/tmp/ua-import-map-input.json" "$PROJECT_ROOT/.codex-ray/tmp/ua-import-map-output.json"
```
Combine scan + import map → write `scan-result.json` to intermediate/

### Phase 1.5: BATCH
```bash
node "$SKILL_DIR/compute-batches.mjs" "$PROJECT_ROOT"
```
Reads scan-result.json → writes batches.json

### Phase 2: ANALYZE (CRITICAL — read EVERY file)
For each batch in batches.json:
1. Run `extract-structure.mjs` for deterministic structural extraction via Tree-sitter
2. Read EVERY file in the batch and generate:
   - Summary for each file, function, and class
   - Tags (security, auth, api, database, etc.)
   - Complexity ratings
   - Semantic edges (calls, depends_on, contains, etc.)
3. Write batch-N.json to intermediate/

Then merge all batches:
```bash
python "$SKILL_DIR/merge-batch-graphs.py" "$PROJECT_ROOT"
```

### Phase 3: ASSEMBLE REVIEW
Read assembled-graph.json and verify:
- No dangling edges (source/target must exist as nodes)
- No orphan nodes (every node should have at least one edge)
- Consistency with scan results
- Fix issues or report warnings

### Phase 4: ARCHITECTURE
Read agents/architecture-analyzer.md instructions, then:
1. Group files by directory
2. Match directory patterns → layer assignments (routes→API, models→Data, etc.)
3. Compute import adjacency
4. Assign 3-10 layers
5. Write layers to the graph

### Phase 5: TOUR
Read agents/tour-builder.md instructions, then:
1. Compute fan-in/fan-out rankings
2. Find entry points (main files, index files, app files)
3. BFS traversal from entry points
4. Design 5-15 pedagogical steps
5. Write tour to the graph

### Phase 6: REVIEW
Run 9 quality checks:
1. Every edge source/target exists as a node
2. No duplicate node IDs
3. Every layer has at least one node
4. Tour covers entry points
5. Summaries are non-empty
6. Tags are valid strings
7. Complexity values are valid
8. File paths match scan results
9. Graph is connected (no isolated subgraphs)

### Phase 7: SAVE
- Assemble final `knowledge-graph.json` with: nodes, edges, layers, tour, project metadata
- Write to `$PROJECT_ROOT/.codex-ray/knowledge-graph.json`
- Write `meta.json` with commit hash and timestamp
- Build fingerprints for incremental updates
- Clean up intermediate/ and tmp/

## Post-Analysis Skills

### /understand-chat
Read knowledge-graph.json → search nodes/edges to answer user questions about the codebase.

### /understand-diff
Read knowledge-graph.json + `git diff` → trace edges from changed files → report impact analysis.

### /understand-update (Incremental Re-index)
When the user says "update the graph", "re-index", "حدّث الخريطة", or "reanalyze changes":

1. **Detect changes**: Run `git diff --name-only HEAD~N` (default N=5, or since last analysis via meta.json commit hash)
2. **Load existing graph**: Read `$PROJECT_ROOT/.codex-ray/knowledge-graph.json`
3. **Re-scan changed files only**:
   ```bash
   node "$SKILL_DIR/scan-project.mjs" "$PROJECT_ROOT" "$PROJECT_ROOT/.codex-ray/tmp/ua-scan-files.json"
   ```
4. **Filter**: From the scan output, keep only files that appear in the git diff list
5. **Re-analyze changed files**:
   - Run `extract-structure.mjs` on each changed file
   - Read each changed file fully
   - Generate updated: summary, tags, complexity, edges
6. **Merge into existing graph**:
   - Remove old nodes/edges for changed files
   - Insert new nodes/edges
   - Add nodes/edges for any NEW files
   - Remove nodes/edges for DELETED files
7. **Re-validate**: Run Phase 6 quality checks on the updated graph
8. **Save**: Write updated `knowledge-graph.json` + update `meta.json` with new commit hash

This is **much faster** than a full analysis — only changed files are re-processed.

### /understand-explain <file>
Find node for file + read actual source → deep explanation combining graph context and code.

### /understand-onboard
Use tour steps → generate onboarding guide for new developers.

### /understand-domain
Extract domains and business flows from the graph.

## Key File References
- Full pipeline instructions: `$SKILL_DIR/SKILL.md`
- Agent prompts: `$AGENTS_DIR/*.md` (9 specialized agents)
- Schema/Types: `$CORE_DIR/src/types.ts`
- Validation schema: `$CORE_DIR/src/schema.ts`
