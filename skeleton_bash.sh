#!/usr/bin/env bash
set -e
set +H

# ================================
# COLORS
# ================================
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RED="\033[1;31m"
NC="\033[0m"

# ================================
# RUNTIME TIMER
# ================================
start_time=$(date +%s)

# ================================
# OS DETECTION
# ================================
OS_NAME="$(uname -s 2>/dev/null || echo Unknown)"
IS_WSL=false
if [ "$OS_NAME" = "Linux" ] && grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=true
fi

# ================================
# STEP COUNTER (NO PROGRESS BAR)
# ================================
total_steps=16
current_step=0

step() {
  current_step=$((current_step + 1))
  if [ $current_step -gt $total_steps ]; then
    current_step=$total_steps
  fi

  local msg="$1"
  local pct=$(( current_step * 100 / total_steps ))
  if [ $pct -gt 100 ]; then
    pct=100
  fi

  echo -e "${YELLOW}${msg}... ${pct}%${NC}"
}

# ================================
# PROJECT NAME
# ================================
read -rp "Project name: " project
if [ -z "$project" ]; then
  echo -e "${RED}Project name required.${NC}"
  exit 1
fi
if [ -d "$project" ]; then
  echo -e "${RED}Folder '$project' already exists. Delete it first.${NC}"
  exit 1
fi

mkdir "$project"
cd "$project" || exit 1
step "Project folder created"

# ================================
# FRONTEND
# ================================
mkdir -p frontend
cd frontend

cat > package.json << 'EOF'
{
  "name": "frontend",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "format": "prettier --write . ../README.md"
  },
  "dependencies": {
    "next": "15.5.4",
    "react": "19.0.0",
    "react-dom": "19.0.0",
    "framer-motion": "^12.0.0"
  },
  "devDependencies": {
    "typescript": "^5.9.0",
    "@types/node": "^22.0.0",
    "@types/react": "^19.0.0",
    "prettier": "^3.6.0"
  }
}
EOF
step "Frontend package.json created"

npm install >/dev/null
step "Frontend dependencies installed"

mkdir -p app/\(site\)/dashboard components hooks lib \
  public/figma/icons public/figma/illustrations public/figma/animations \
  public/images public/fonts styles

cat > app/layout.tsx << 'EOF'
import "../styles/globals.css";
import React from "react";

export const metadata = { title: "New Project" };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        <link
          href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600&family=Roboto:wght@400;500&display=swap"
          rel="stylesheet"
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
EOF

cat > app/error.tsx << 'EOF'
"use client";

export default function GlobalError({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  return (
    <html>
      <body style={{ padding: 40, fontFamily: '"Montserrat", "Roboto", system-ui' }}>
        <h1>Something went wrong.</h1>
        <p>{error.message}</p>
        <button
          style={{
            marginTop: 16,
            padding: "8px 16px",
            border: "2px solid #000",
            background: "#fff",
            cursor: "pointer",
          }}
          onClick={() => reset()}
        >
          Try again
        </button>
      </body>
    </html>
  );
}
EOF

cat > app/page.tsx << 'EOF'
"use client"

import { useEffect, useState } from "react"
import { motion, AnimatePresence } from "framer-motion"

type Friend = { id: number; name: string; email?: string | null }

export default function HomePage() {
  const [friends, setFriends] = useState<Friend[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [name, setName] = useState("")
  const [email, setEmail] = useState("")
  const [saving, setSaving] = useState(false)
  const [saveDone, setSaveDone] = useState(false)
  const [readme, setReadme] = useState<string | null>(null)
  const [readmeOpen, setReadmeOpen] = useState(false)
  const [backendOk, setBackendOk] = useState<boolean | null>(null)

  useEffect(() => {
    const checkHealth = async () => {
      try {
        const r = await fetch("http://localhost:4000/health")
        setBackendOk(r.ok)
      } catch {
        setBackendOk(false)
      }
    }

    const loadFriends = async () => {
      try {
        const r = await fetch("http://localhost:4000/friends")
        setFriends(await r.json())
      } finally {
        setLoading(false)
      }
    }

    checkHealth()
    loadFriends()
  }, [])

  const handleSave = async () => {
    if (!name.trim()) return
    setSaving(true)

    try {
      const r = await fetch("http://localhost:4000/friends", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, email }),
      })
      const created = await r.json()
      setFriends((p) => [...p, created])
      setName("")
      setEmail("")
      setSaveDone(true)
      setTimeout(() => setSaveDone(false), 700)
    } finally {
      setSaving(false)
    }
  }

  const handleToggleReadme = async () => {
    if (!readme) {
      const r = await fetch("http://localhost:4000/readme")
      const j = await r.json()
      setReadme(j.content)
      setReadmeOpen(true)
    } else {
      setReadmeOpen((p) => !p)
    }
  }

  return (
    <main className="page" style={{ position: "relative" }}>
      {backendOk === false && <div className="health-banner">Backend offline.</div>}

      <section className="welcome">
        <h1>
          "But when that light hits the sky, it's no longer a signal — it's a warning to
          them." – The Batman (2022)
        </h1>
      </section>

      <hr style={{ border: "2px solid #000", margin: "24px 0" }} />

      <button className="primary-button" onClick={handleToggleReadme}>
        {readmeOpen ? "Hide README" : "Show README"}
      </button>

      <hr style={{ border: "2px solid #000", margin: "24px 0" }} />

      <AnimatePresence>
        {readmeOpen && readme && (
          <>
            <motion.div
              key="overlay-bg"
              initial={{ opacity: 0 }}
              animate={{ opacity: 0.85 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.35 }}
              style={{
                position: "fixed",
                top: 0,
                left: 0,
                width: "100vw",
                height: "100vh",
                background: "#000",
                zIndex: 9998,
              }}
            />

            <motion.div
              key="overlay-panel"
              initial={{ opacity: 0, y: 40 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 40 }}
              transition={{ duration: 0.35, ease: "easeOut" }}
              style={{
                position: "fixed",
                top: "5vh",
                left: "max(24px, 5vw)",
                width: "70vw",
                height: "85vh",
                background: "#111",
                color: "#fff",
                border: "3px solid #000",
                padding: "24px",
                overflowY: "auto",
                zIndex: 9999,
                boxShadow: "0 0 40px rgba(0,0,0,0.8)",
              }}
            >
              <button
                onClick={() => setReadmeOpen(false)}
                style={{
                  background: "#fff",
                  color: "#000",
                  border: "2px solid #000",
                  padding: "4px 12px",
                  fontWeight: 600,
                  cursor: "pointer",
                  marginBottom: "24px",
                }}
              >
                × Close
              </button>

              <pre
                style={{
                  whiteSpace: "pre-wrap",
                  fontSize: "16px",
                  lineHeight: "22px",
                }}
              >
                {readme}
              </pre>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      <section className="friends">
        <h2>Friends</h2>

        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: "12px",
            marginBottom: "16px",
            height: "40px",
          }}
        >
          <motion.button
            className="primary-button"
            style={{ height: "40px" }}
            onClick={() => setShowForm(true)}
          >
            Add Friend
          </motion.button>

          <AnimatePresence>
            {showForm && (
              <motion.div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                  border: "2px solid #000",
                  background: "#fff",
                  padding: "4px 8px",
                  height: "40px",
                }}
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }}
              >
                <input
                  placeholder="Name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  style={{ width: "140px", height: "28px" }}
                />
                <input
                  placeholder="Email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  style={{ width: "200px", height: "28px" }}
                />

                <motion.button
                  className="primary-button"
                  style={{ height: "32px" }}
                  onClick={handleSave}
                  disabled={saving}
                >
                  {saving ? "Saving..." : saveDone ? "Saved!" : "Save"}
                </motion.button>

                <motion.button
                  onClick={() => setShowForm(false)}
                  style={{
                    border: "2px solid #000",
                    background: "#fff",
                    padding: "0 10px",
                    cursor: "pointer",
                    fontWeight: 600,
                    height: "32px",
                  }}
                >
                  ×
                </motion.button>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {loading ? (
          <p>Loading...</p>
        ) : (
          <ul>
            {friends.map((f) => (
              <li key={f.id}>
                {f.name}
                {f.email ? ` (${f.email})` : ""}
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  )
}
EOF

cat > styles/globals.css << 'EOF'
body { margin:0; padding:0; font-family:"Montserrat","Roboto",system-ui; }
.page { padding:40px; }
.primary-button { padding:8px 16px; border:2px solid #000; background:#fff; cursor:pointer; }
.health-banner { border:2px solid #000; padding:8px; background:#ffecec; margin-bottom:16px; }
.friend-form { margin-top:16px; display:flex; gap:8px; border:2px solid #000; padding:8px; }
.readme { margin-top:16px; border:2px solid #000; padding:16px; background:#f7f7f7; white-space:pre-wrap; }
EOF

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ESNext",
    "lib": ["dom", "dom.iterable", "esnext"],
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve"
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
EOF

cat > .gitignore << 'EOF'
node_modules/
.next/
out/
dist/

.env
.env.local
.env.*.local

npm-debug.log*
yarn-debug.log*
pnpm-debug.log*

.DS_Store
Thumbs.db
.idea/

*.log
.cache/
coverage/
EOF

cd ..
step "Frontend scaffold created"

# ================================
# BACKEND
# ================================
mkdir -p backend
cd backend

cat > .gitignore << 'EOF'
node_modules/
dist/

.env
.env.local
.env.*.local

npm-debug.log*
yarn-debug.log*
pnpm-debug.log*

.DS_Store
Thumbs.db
.vscode/
.idea/

*.log
.cache/
coverage/
EOF

cat > package.json << 'EOF'
{
  "name": "backend",
  "version": "1.0.0",
  "private": true,
  "type": "commonjs",
  "main": "dist/server.js",
  "scripts": {
    "dev": "ts-node-dev src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "prisma:migrate": "prisma migrate dev",
    "prisma:generate": "prisma generate"
  },
  "dependencies": {
    "fastify": "^5.6.0",
    "@fastify/cors": "^11.1.0",
    "@fastify/rate-limit": "^10.0.0",
    "@prisma/client": "6.19.0"
  },
  "devDependencies": {
    "prisma": "6.19.0",
    "typescript": "^5.9.0",
    "ts-node": "^10.9.0",
    "ts-node-dev": "^2.0.0",
    "@types/node": "^22.0.0",
    "prettier": "^3.6.0"
  }
}
EOF

step "Backend package.json created"

npm install >/dev/null
step "Backend dependencies installed"

mkdir -p src/routes src/plugins prisma

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist",
    "moduleResolution": "node",
    "resolveJsonModule": true
  },
  "include": ["src/**/*", "prisma/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

cat > prisma/schema.prisma << 'EOF'
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model Friend {
  id    Int     @id @default(autoincrement())
  name  String
  email String?
}
EOF

cat > src/plugins/prisma.ts << 'EOF'
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
export default prisma;
EOF

cat > src/routes/friendsRoute.ts << 'EOF'
import { FastifyInstance } from "fastify";
import prisma from "../plugins/prisma";

export default async function friendsRoutes(app: FastifyInstance) {
  app.get("/", async () => {
    const list = await prisma.friend.findMany();
    if (list.length === 0) {
      const batman = await prisma.friend.create({
        data: { name: "Batman", email: "bruce@wayneindustries.com" }
      });
      return [batman];
    }
    return list;
  });

  app.post("/", async (req, reply) => {
    const body = req.body as { name?: string; email?: string | null };
    if (!body.name || !body.name.trim()) {
      reply.status(400);
      return { error: "Name required" };
    }
    return prisma.friend.create({
      data: { name: body.name.trim(), email: body.email ?? null }
    });
  });
}
EOF

cat > src/server.ts << 'EOF'
import "dotenv/config";
import Fastify from "fastify";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";
import path from "path";
import fs from "fs";
import friendsRoutes from "./routes/friendsRoute";

const app = Fastify({ logger: true });

const { DATABASE_URL } = process.env;
if (!DATABASE_URL) throw new Error("DATABASE_URL missing");

app.register(cors, { origin: ["http://localhost:3000"] });
app.register(rateLimit, { max: 100, timeWindow: "1 minute" });

app.get("/health", async () => ({ ok: true }));

app.get("/readme", async () => {
  const readmePath = path.resolve(__dirname, "..", "..", "README.md");
  const content = fs.readFileSync(readmePath, "utf8");
  return { content };
});

app.register(friendsRoutes, { prefix: "/friends" });

app.listen({ port: 4000 }, (err, addr) => {
  if (err) {
    app.log.error(err);
    process.exit(1);
  }
  console.log("Backend listening on " + addr);
});
EOF

step "Backend scaffold created"

# ================================
# DATABASE SETUP
# ================================
echo -e "${YELLOW}Configuring Postgres and Prisma...${NC}"

if ! command -v createdb >/dev/null || ! command -v psql >/dev/null; then
  echo -e "${RED}PostgreSQL client tools (psql/createdb) are missing.${NC}"
  case "$OS_NAME" in
    Darwin)
      echo -e "${YELLOW}On macOS, install with Homebrew:${NC}"
      echo -e "${BLUE}  brew install postgresql${NC}"
      ;;
    Linux)
      if [ "$IS_WSL" = true ]; then
        echo -e "${YELLOW}In WSL install:${NC}"
        echo -e "${BLUE}  sudo apt update && sudo apt install postgresql-client${NC}"
      else
        echo -e "${YELLOW}On Linux:${NC}"
        echo -e "${BLUE}  sudo apt install postgresql-client${NC}"
      fi
      ;;
    *)
      echo -e "${YELLOW}Install PostgreSQL client tools appropriate for your OS.${NC}"
      ;;
  esac
  exit 1
fi

detect_pg_host() {
  case "$OS_NAME" in
    Darwin) PG_HOST="localhost" ;;
    Linux)
      if [ "$IS_WSL" = true ]; then
        PG_HOST=$(ip route | awk '/default/ {print $3}')
      else
        PG_HOST="localhost"
      fi
      ;;
    *) PG_HOST="localhost" ;;
  esac
}
detect_pg_host

# Ask only for DB user — NOT DB name
read -rp "Database user: " dbuser

tries=0
max=3

while true; do
  read -rsp "Database password: " dbpass
  printf "\n"

  export PGPASSWORD="$dbpass"
  test_conn=$(psql -h "$PG_HOST" -U "$dbuser" -tAc "SELECT 1" 2>/dev/null || echo "")

  if [ "$test_conn" = "1" ]; then
    echo -e "${GREEN}  - Password accepted.${NC}"
    break
  fi

  tries=$((tries + 1))
  if [ $tries -ge $max ]; then
    echo -e "${RED}Too many failed attempts.${NC}"
    exit 1
  fi

  echo -e "${YELLOW}Incorrect password. Try again (${tries}/3)...${NC}"
done

# ================================
# REQUIRE NEW DATABASE NAME
# (NO reuse allowed)
# ================================
while true; do
  read -rp "Database name: " dbname

  exists=$(psql -h "$PG_HOST" -U "$dbuser" -tAc \
    "SELECT 1 FROM pg_database WHERE datname='${dbname}'" 2>/dev/null || echo "")

  if [ "$exists" = "1" ]; then
    echo -e "${RED}Database '$dbname' already exists. Enter a different name.${NC}"
    continue
  fi

  break
done

connection_string="postgresql://${dbuser}:${dbpass}@${PG_HOST}:5432/${dbname}?schema=public"
echo "DATABASE_URL=\"$connection_string\"" > .env

# ================================
# CREATE NEW DATABASE + MIGRATE
# ================================
createdb -h "$PG_HOST" -U "$dbuser" "$dbname" 2>/dev/null || \
psql -h "$PG_HOST" -U "$dbuser" -c "CREATE DATABASE \"$dbname\""

DATABASE_URL="$connection_string" npx prisma migrate dev --name init_friends >/dev/null
DATABASE_URL="$connection_string" npx prisma generate >/dev/null

cd ..

# ================================
# ROOT TOOLING
# ================================
mkdir -p .vscode

cat > .vscode/settings.json << 'EOF'
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "files.eol": "\n",
  "typescript.tsdk": "frontend/node_modules/typescript/lib"
}
EOF

cat > .vscode/extensions.json << 'EOF'
{
  "recommendations": ["esbenp.prettier-vscode","dbaeumer.vscode-eslint"]
}
EOF

cat > .prettierrc.json << 'EOF'
{
  "singleQuote": false,
  "semi": false,
  "printWidth": 90,
  "trailingComma": "es5"
}
EOF

cat > .gitignore << 'EOF'
node_modules/
frontend/node_modules/
backend/node_modules/

.env
.env.local
.env.*.local

.DS_Store
Thumbs.db
.idea/

npm-debug.log*
yarn-debug.log*
pnpm-debug.log*
*.log

frontend/.next/
frontend/out/
backend/dist/
dist/

.cache/
coverage/
EOF

cat > README.md << EOF
This codebase answers that warning. Use it to cut through hollow design and the bad code that hides in the shadows.
- The original Dark Knight

# $project is buit on:

STACK:
- Next.js 15.5.x
- React 19
- Fastify 5
- Prisma 6.19
- PostgreSQL (local)
- TypeScript 5.9
- Node.js 20.x

## Features
- A disciplined scaffold for frontend and backend development
- Strict TypeScript settings to keep the codebase sharp
- Prisma initialized with a simple sample model and route to verify the stack
- Database setup enforces **new database creation only**  
  (existing database names are rejected to protect existing data)
- Local PostgreSQL connection generated and written to `.env`
- Automatic Prisma migration and client generation on the new database
- Baseline API endpoints to confirm the backend’s heartbeat
- Prettier configuration enforcing consistent formatting across the project
- VS Code workspace settings to keep every file aligned
- Project structure generated in the correct order: frontend → backend → root

## Git
- Repository auto-initialized with `main` as the default branch
- Global Git defaults applied for clean, predictable workflows
- Minimal credential helper used to avoid silent background prompts
- Recommended workflow when pushing for the first time:
  - `git config --global credential.helper manager-core`
  - `git push -u origin main`

EOF

step "Root tooling and README created"

# ================================
# GIT INIT
# ================================
git config --global init.defaultBranch main >/dev/null 2>&1
git config --global push.autoSetupRemote true >/dev/null 2>&1
git config --global help.autocorrect 20 >/dev/null 2>&1
git config --global color.ui auto >/dev/null 2>&1
git config --global pull.rebase true >/dev/null 2>&1
git config --global credential.helper "" >/dev/null 2>&1

step "Global Git defaults applied"

# ================================
# GIT IDENTITY
# ================================
echo -e "${YELLOW}Checking Git identity...${NC}"

name=$(git config --global user.name || echo "")
email=$(git config --global user.email || echo "")
valid_identity=true

# Determine if existing identity is valid
[ -z "$name" ] && valid_identity=false
[ -z "$email" ] && valid_identity=false

if [ "$valid_identity" = true ]; then
  echo -e "${GREEN}Existing Git identity detected:${NC}"
  echo "  user.name  = $name"
  echo "  user.email = $email"
  read -rp "Use these? (y/n): " confirm

  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    valid_identity=false
  fi
fi

# If invalid OR user chooses no → reconfigure
if [ "$valid_identity" = false ]; then
  attempts=0
  max_attempts=3

  echo -e "${YELLOW}Configure Git user.name and user.email.${NC}"

  while [ $attempts -lt $max_attempts ]; do
    echo ""
    read -rp "Git user.name: " git_name
    read -rp "Git user.email: " git_email

    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
      git config --global user.name "$git_name"
      git config --global user.email "$git_email"
      echo -e "${GREEN}Git identity set.${NC}"
      break
    fi

    attempts=$((attempts + 1))
    echo -e "${RED}Both fields required. Try again (${attempts}/3).${NC}"
  done

  if [ $attempts -ge $max_attempts ]; then
    echo -e "${RED}Git identity required. Exiting.${NC}"
    exit 1
  fi
fi

step "Git identity checked"

git init >/dev/null
git branch -M main
step "Git repository initialized"

default_prefix="https://github.com/$(git config --global user.name | tr ' ' '_' | tr -d '\n')/"

read -rp "Add a Git remote? (y/n): " addremote
if [[ "$addremote" =~ ^[yY]$ ]]; then
  read -rp "Git remote URL [${default_prefix}]: " giturl
  if [[ -n "$giturl" && "$giturl" != http* && "$giturl" != git@* ]]; then
    giturl="${default_prefix}${giturl}"
  fi
  giturl="${giturl:-$default_prefix}"
  git remote add origin "$giturl"
fi

step "Git remote configuration complete"

git add .
git commit -m "Initial project scaffold" >/dev/null
step "Initial commit created"

# ================================
# FINALIZATION
# ================================
end_time=$(date +%s)
runtime=$((end_time - start_time))

echo -e "${GREEN}Setup complete in ${runtime} seconds.${NC}"
echo -e "${GREEN}Your codebase is armed, tested in darkness, as a new Dark Knight rises.${NC}"
echo ""
