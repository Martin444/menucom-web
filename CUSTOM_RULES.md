# Custom Project Rules

## Flutter Analysis Requirement
Whenever a new implementation, modification, or refactoring is performed, you **MUST** run the analysis command to verify that no new errors have been introduced.

### Command
If the project uses FVM (check for `.fvm/fvm_config.json`):
```bash
fvm flutter analyze
```
Otherwise:
```bash
flutter analyze
```

### Protocol
1. Perform the code changes.
2. Run the analysis command.
3. If errors are found (exit code 1 with "error" level issues), they **MUST** be fixed before concluding the task.
4. Report the analysis results to the user.
