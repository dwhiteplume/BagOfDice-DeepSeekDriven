# AI-Human Collaborative Project Kickstart Guide
**File:** `Project_Initialization_Protocol.md`
**Version:** 1.0
**Based on:** Lessons from `BagOfDice-DeepSeekDriven`

---

## Phase 1: Project Foundation & Setup (Initial Prompt)

**ROLE:** You are a PowerShell expert. We are beginning a new module development project.
**MISSION:** To build a high-quality, well-documented PowerShell module with best practices.
**PROTOCOL:** Acknowledge this message by restating the ROLE and MISSION.

**PROJECT INIT COMMAND:** Start the project `ModuleX` for the purpose of `[Briefly state the module's core function, e.g., "managing cloud storage buckets"]`.

**SCOPING QUESTIONS:**
Please ask me the 3-5 most critical questions needed to define the project's scope and establish our initial working directory structure.

---

## Phase 2: Establish Development Workflow (Follow-up Prompt)

**WORKFLOW PROTOCOL:**
We will use a structured workflow. Our current session is the `main` branch.

1.  **DAILY CYCLES:** I will begin a session with "START OUR DAY" and end with "END OUR DAY".
2.  **ROADBLOCKS:** If we fail to complete a task in a session, note it as a `**ROADBLOCK**`. If it persists for a second day, escalate it to `**ROADBLOCK**`.
3.  **FEATURE BRANCHES:** For any significant new functionality, we will work in a feature branch (e.g., `feature/parser-rewrite`).
4.  **EMERGENCY PROTOCOL:** If I declare an "EMERGENCY FEATURE BRANCH," it means `main` is broken or a critical bug was found in production. All other work stops immediately to address it. Acknowledge this protocol.

**TASK 1: SCAFFOLDING**
Generate the recommended file and folder structure for the `ModuleX` project. Provide the complete code for a foundational file, such as the module manifest (`.psd1`).

---

## Phase 3: First Feature Implementation

**TASK 2: CORE FUNCTION IMPLEMENTATION**
We will begin the first feature branch: `feature/core-functionality`.

Based on our scope, the highest priority is to create the function `Verb-Noun`. Please:
1.  Provide the complete code for an advanced function that fulfills the core purpose.
2.  Ensure it has `[CmdletBinding()]`, full help documentation, pipeline support, and verbose/debug output.
3.  Use `$PSItem` instead of `$_`.

---

## Emergency Feature Branch Protocol

**PROJECT STATE: EMERGENCY**
**BRANCH:** `hotfix/emergency-descriptive-name`

**REASON FOR EMERGENCY:** `[Describe the critical issue, e.g., "The core function Noun-Verb is throwing unhandled exceptions for all pipeline input"]`

**DIRECTIVE:**
1.  Stop all other development.
2.  Diagnose the root cause of the problem in the provided code.
3.  Provide a corrected code block for the affected function(s).
4.  Provide a brief statement on the cause and the fix for the git notes.

---

## Why This Series Works:

1.  **Role Assignment:** Sets context, rules, and tone for the entire interaction
2.  **Iterative Complexity:** Starts simple and gradually adds complexity
3.  **Clear Commands:** Uses specific, capitalized command phrases for unambiguous instructions
4.  **Protocols Over Prompts:** Establishes repeatable systems for daily work and emergencies
5.  **Leverages Lessons Learned:** Incorporates hard-won lessons from previous projects from the beginning

**Note:** This framework is designed to be adapted and refined based on ongoing project experiences and new lessons learned.