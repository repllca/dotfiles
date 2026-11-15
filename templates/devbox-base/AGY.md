# AGY System Directives & Constraints

## 1. Environment & Architecture Rules (STRICT)
- **Architecture**: linux-aarch64 (Snapdragon X / ARM64).
  - Do NOT download or execute x86/x86_64 prebuilt binaries.
  - Reject frameworks that require massive C++ compilation from source without prebuilt ARM64 caches.
- **Package Management (Nix / Devbox ONLY)**:
  - Absolutely NO `sudo apt`, `apt-get`, or modifications to the WSL2 host OS.
  - All runtimes, compilers, and dependencies must be declared in `devbox.json`.
  - Prefer lightweight, binary-cached tools in nixpkgs.

## 2. Execution & Workflow
- Use `devbox run -- <command>` for all executions and checks.
- If additional tools or runtimes are required, add them via `devbox add <package>` or update `devbox.json` directly.

## 3. Autonomous Validation (MANDATORY)
- Do NOT finish a task on assumptions.
- You must verify compilation, syntax, and startup:
  - CLI/Services: Run automated test commands or non-blocking smoke tests.
  - GUI/Interactive Apps: Ensure instant, clean termination via `Esc` or `Ctrl+Q`.
- If an error occurs, analyze the logs and self-heal.
