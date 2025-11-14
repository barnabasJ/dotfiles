# Small Feature - Streamlined Four-Phase Workflow

You orchestrate a lightweight version of the four-phase workflow, moving quickly
through research, planning, breakdown, and execution while maintaining quality
through agent consultation.

use one page in logseq to track notes

## Streamlined Four-Phase Process

### **🚨 PHASE 0: MANDATORY Memory Consultation (DO THIS FIRST)**

**CRITICAL**: Before starting ANY work, you MUST check with the memory agent for
similar features.

**Why this is mandatory:**

- ✅ Prevents repeating similar work
- ✅ Leverages previous solutions
- ✅ Avoids known pitfalls
- ✅ Maintains consistency

**❌ DO NOT PROCEED to Phase 1 without completing memory checks**

### **Phase 1: Quick Impact Analysis (Lightweight Research)**

**Goal**: Understand what needs to change without extensive documentation
gathering.

1. **Codebase Analysis**
   - Identify files requiring changes (3-8 files typical)
   - Find existing patterns to follow
   - Check for similar implementations in the codebase
   - Identify dependencies and imports

2. **Quick Architecture Check**
   - Consult architecture-agent if file placement is unclear
   - Validate integration approach for new components
   - Confirm established patterns for this type of change

3. **Document Findings** (Keep it brief - 1-2 paragraphs)
   - Files to change with specific line references
   - Existing patterns to follow with examples
   - Any potential risks or blockers

### **Phase 2: Implementation Approach (Lightweight Planning)**

**Goal**: Define the approach without extensive documentation.

1. **Feature Specification** (Keep it concise)
   - What the feature does (2-3 sentences)
   - Key user-facing behavior
   - Success criteria

2. **Technical Approach** (Brief but specific)
   - Which existing patterns to follow
   - File organization and structure
   - Integration points
   - Consult elixir skill or other domain experts as needed

3. **Testing Strategy** (High-level)
   - Test coverage expectations
   - Testing approach following project patterns

### **Phase 3: Task Checklist (Lightweight Breakdown)**

**Goal**: Create actionable checklist without extensive substeps.

1. **Create Numbered Checklist** (3-8 main tasks typical)
   - Each task represents a logical unit of work
   - Include file references from Phase 1
   - Add commit message for each task
   - Keep substeps minimal (2-4 per task)

2. **Test Requirements**
   - Each task includes: complete → run tests → verify green → commit
   - Clear testing approach per task

### **Phase 4: Execute Implementation**

**Goal**: Implement following the checklist while consulting agents.

1. **Sequential Implementation**
   - Work through checklist tasks in order
   - 🚨 **Check memories FIRST** when encountering any problem
   - Consult agents for guidance as needed:
     - Ask about patterns (elixir skill provides Elixir/Phoenix guidance)
     - architecture-agent for code placement questions
     - Domain experts for testing approaches

2. **Quality Gates**
   - Run tests after each task (MANDATORY)
   - Verify all tests pass before committing
   - Commit with suggested message after tests are green

3. **Final Review**
   - Run ALL review agents in parallel after completion
   - Address any issues identified

### **🚨 PHASE 5: MANDATORY Memory Storage**

**CRITICAL**: After completing the feature, you MUST store learnings.

**Required Memory Storage:**

1. **Store implementation patterns**: What worked well for this type of feature
2. **Store hard-won knowledge**: Any problems solved and solutions found
3. **Store project context**: New patterns or preferences discovered
4. **Update existing memories**: If retrieved memories were incomplete or
   incorrect

**What to store:**

- Implementation approach that worked
- Problems encountered and solutions
- Project-specific patterns discovered
- Testing approaches that worked well

**How to store:**

- Use memory-agent in STORE mode
- Choose appropriate category (project-knowledge, technical-patterns,
  hard-won-knowledge)
- Include concrete examples and file references

**❌ DO NOT consider work complete without storing memories**

## Streamlined Documentation

**Minimal LogSeq Structure**

```
projects/[project]/[feature-name]/notes
```
