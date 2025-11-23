# Skeleton Script for Bash

A Bash script that generates a full-stack project with a consistent structure and minimal setup.

## Stack

- Next.js (frontend)
- Fastify (backend)
- PostgreSQL + Prisma
- TypeScript
- Prettier + VS Code settings
- Git initialization

## Requirements

- Bash  
  (included in Linux/macOS; Windows via WSL: https://learn.microsoft.com/windows/wsl/install)
- Node.js 20+  
  https://nodejs.org
- PostgreSQL  
  https://www.postgresql.org/download/
- PostgreSQL client tools (`psql` and `createdb`)  
  included in PostgreSQL installations

## What the Script Does

- Creates the frontend (Next.js + TypeScript)
- Creates the backend (Fastify + Prisma)
- Enforces choosing a **new** database name  
  (existing databases are rejected to avoid conflicts)
- Creates the database, runs the initial Prisma migration, and generates the client
- Generates all root-level tooling (`.vscode`, Prettier config, gitignore)
- Initializes Git, creates the first commit, and optionally adds a remote

## How to Use

### 1. Where to Run the Script

You must run the script **from a Bash-compatible terminal**.  
Below are the supported terminals for each operating system:

- **macOS**  
  Use the built-in **Terminal.app** or **iTerm2**.  
  Both include Bash or zsh (which can run Bash scripts).

- **Linux (Ubuntu, Debian, Fedora, Arch, etc.)**  
  Use any terminal (GNOME Terminal, KDE Konsole, xterm, etc.).  
  Bash is the default shell on most distributions.

- **Windows**  
  You must use **WSL (Windows Subsystem for Linux)**.  
  Install WSL using Microsoft’s instructions:  
  https://learn.microsoft.com/windows/wsl/install  
  Then open the **Ubuntu** (or other WSL distribution) terminal.  
  *Do not use PowerShell or Command Prompt for this script.*

---

### 2. Place the Script

Put `skeleton_bash.sh` in any folder where you want new projects to be created.

Example:  
If the script lives in:

```
~/Code/
```

and you run it there, the generated project folder will also appear in:

```
~/Code/
```

---

### 3. Make the Script Executable

```
chmod +x skeleton_bash.sh
```

---

### 4. Run the Script

```
./skeleton_bash.sh
```

---

### 5. Follow the Prompts

- **Project name**  
  A new folder with this name will be created next to the script.

- **Database user**  
  Usually `postgres` on local installations.

- **Database password**  
  Must match your local PostgreSQL installation.

- **Database name**  
  Must be a *new* database name (existing names are rejected to protect data).

---

### After Completion

Your project structure will look like:

```
project-name/
  frontend/
  backend/
  .vscode/
  README.md
  .gitignore
  .prettierrc.json
```

The project is ready for development immediately.

## Notes

- The `.vscode` folder is optional. It contains a few workspace preferences that improve formatting and ensure VS Code uses the project's TypeScript version. These settings apply only inside VS Code and have no effect on other editors, tools, or the
  installation process. Developers who do not use VS Code can ignore the folder safely.

