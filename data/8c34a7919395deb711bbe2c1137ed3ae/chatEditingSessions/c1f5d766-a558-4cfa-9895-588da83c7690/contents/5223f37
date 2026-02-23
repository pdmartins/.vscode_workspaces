# Git

Scripts for managing and exporting Git repositories.

## Scripts

| Script | Description |
|--------|-------------|
| `export-git-repos.ps1` | Searches for Git repos and generates a script to clone the structure |
| `export-git-repos.sh` | Searches for Git repos and generates a script to clone the structure |

## Requirements

- Git installed and accessible in PATH
- Read access to folders to be scanned

## Usage

### PowerShell

```powershell
.\export-git-repos.ps1 [-Path <path>] [-Output <file>]
```

### Bash

```bash
./export-git-repos.sh [-p|--path <path>] [-o|--output <file>]
```

## Parameters

| Parameter | Required | Description | Default |
|-----------|----------|-------------|---------|
| `-Path` / `-p` | No | Root folder to search for repos | Current directory |
| `-Output` / `-o` | No | Output file for the script | `clone-repos.{ps1\|sh}` |

## What the script does

1. **Recursive search**: Searches for all `.git` folders inside the specified folder
2. **Collects information**: For each repo, gets:
   - `origin` remote URL
   - Current branch
   - Relative path to the search folder
3. **Generates clone script**: Creates an executable script that can be used to replicate the structure

## Examples

### Interactive usage

```powershell
.\export-git-repos.ps1
```

```bash
./export-git-repos.sh
```

The script will prompt for the search folder and output file name.

### With parameters

```powershell
# Export repos from Projects folder
.\export-git-repos.ps1 -Path C:\Users\user\Projects -Output my-repos.ps1
```

```bash
# Export repos from ~/projects folder
./export-git-repos.sh -p ~/projects -o my-repos.sh
```

### Using the generated script

The generated clone script can be used like this:

```powershell
# Clone to current folder
.\clone-repos.ps1

# Clone to specific folder
.\clone-repos.ps1 -BaseDir D:\NewProjects
```

```bash
# Clone to current folder
./clone-repos.sh

# Clone to specific folder
./clone-repos.sh ~/new-projects
```

## Notes

- Local repos (without remote origin) are skipped with a warning
- The generated script is idempotent: it won't clone repos that already exist
- If the specified branch doesn't exist on remote, uses the default branch
- The original folder structure is preserved
