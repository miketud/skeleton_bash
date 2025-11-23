# Project Scaffold Script

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

1. Make the script executable:

   ```
   chmod +x create-skeleton.sh
   ```

2. Run it:

   ```
   ./create-skeleton.sh
   ```

3. Follow the prompts:
   - Project name  
   - Database user  
   - Database password  
   - New database name (must not already exist)

## Run the Servers

Frontend:

```
cd frontend
npm run dev
```

Backend:

```
cd backend
npm run dev
```

## Notes

- The `.vscode` folder is optional. It contains a few workspace preferences that improve formatting and ensure VS Code uses the project's TypeScript version. These settings apply only inside VS Code and have no effect on other editors, tools, or the
  installation process. Developers who do not use VS Code can ignore the folder safely.

