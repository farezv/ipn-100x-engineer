# Advanced Claude Code Features for Restaurant Finder

This document covers advanced Claude Code capabilities for enhancing development workflow in this project.

---

## Table of Contents

1. [Hooks - Automated Workflow](#hooks---automated-workflow)
2. [Self-Documenting with CLAUDE.md](#self-documenting-with-claudemd)
3. [Session Tracking & Changelog](#session-tracking--changelog)
4. [Claude Web Integration](#claude-web-integration)
5. [PRD: Reservations & Reviews with SQLite](#prd-reservations--reviews-with-sqlite)

---

## Hooks - Automated Workflow

Hooks are shell commands that execute at specific points in Claude Code's lifecycle. They provide deterministic control over behavior.

### Setup

Run `/hooks` in Claude Code to configure, or add directly to `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write \"$(jq -r '.tool_input.file_path')\" 2>/dev/null || true"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '=== Session Started ===' >> .claude/session-log.txt && date >> .claude/session-log.txt"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/generate-changelog.sh"
          }
        ]
      }
    ]
  }
}
```

### Available Hook Events

| Event | When It Fires | Use Case |
|-------|---------------|----------|
| `PreToolUse` | Before any tool call | Block/validate commands |
| `PostToolUse` | After tool completes | Auto-format, lint, log |
| `SessionStart` | Session begins | Load context, setup env |
| `SessionEnd` | Session ends | Generate changelog, cleanup |
| `UserPromptSubmit` | User submits prompt | Validate, inject context |

### Recommended Hooks for This Project

Create `.claude/hooks/generate-changelog.sh`:

```bash
#!/bin/bash
# Auto-generate changelog entry after each Claude session

DATE=$(date +"%Y-%m-%d %H:%M")
CHANGELOG=".claude/CHANGELOG.md"

# Get git diff summary
CHANGES=$(git diff --stat HEAD 2>/dev/null | tail -1)

if [ -n "$CHANGES" ]; then
  echo "" >> $CHANGELOG
  echo "## $DATE" >> $CHANGELOG
  echo "" >> $CHANGELOG
  echo "### Changes" >> $CHANGELOG
  git diff --name-only HEAD 2>/dev/null | while read file; do
    echo "- Modified: \`$file\`" >> $CHANGELOG
  done
  echo "" >> $CHANGELOG
  echo "Stats: $CHANGES" >> $CHANGELOG
fi
```

Make it executable:
```bash
chmod +x .claude/hooks/generate-changelog.sh
```

---

## Self-Documenting with CLAUDE.md

The `CLAUDE.md` file system provides persistent memory across Claude sessions.

### Memory Hierarchy

| Level | File | Scope |
|-------|------|-------|
| Project | `./CLAUDE.md` | Team-wide, committed to git |
| Rules | `.claude/rules/*.md` | Modular, path-scoped rules |
| Local | `./CLAUDE.local.md` | Personal, gitignored |
| User | `~/.claude/CLAUDE.md` | All your projects |

### Path-Scoped Rules

Create focused rule files in `.claude/rules/`:

**`.claude/rules/api.md`**
```markdown
---
paths: app/api/**/*.ts
---

# API Route Standards

- All API routes must validate query parameters
- Return proper HTTP status codes (400, 404, 500)
- Include error messages in response body
- Log errors to console in development
```

**`.claude/rules/components.md`**
```markdown
---
paths: components/**/*.tsx
---

# Component Standards

- Use functional components with TypeScript
- Props interface must be defined and exported
- Include JSDoc comments for complex components
- Use Tailwind CSS for styling
```

### Session Documentation Template

Add to `CLAUDE.md` for automatic session tracking:

```markdown
## Session Log

Claude will document significant changes at the end of each session:

### Template
- **Date**: [Auto-filled]
- **Features Added**: [List]
- **Bugs Fixed**: [List]
- **Files Modified**: [List]
- **Next Steps**: [Recommendations]
```

---

## Session Tracking & Changelog

### Automatic Checkpointing

Claude Code automatically captures file state before each edit. Access with:
- `Esc Esc` - Open rewind menu
- `/rewind` - Slash command alternative

### Creating a Session Changelog

Create `.claude/CHANGELOG.md` to track all Claude sessions:

```markdown
# Claude Code Session Changelog

This file is auto-updated by Claude Code hooks after each session.

---

## 2024-XX-XX HH:MM

### Changes
- Modified: `file1.ts`
- Modified: `file2.tsx`

Stats: 2 files changed, 45 insertions(+), 12 deletions(-)

---
```

### Manual Session Summary Command

Ask Claude to generate a session summary anytime:

> "Summarize all changes made in this session and add to .claude/CHANGELOG.md"

---

## Claude Web Integration

Claude Code can interact with web content for research and testing.

### Use Cases for This Project

1. **API Documentation Lookup**
   - Fetch latest Next.js docs for API routes
   - Research SQLite/Prisma documentation

2. **Testing External APIs**
   - Verify geocoding API responses
   - Test restaurant data sources

3. **Competitive Research**
   - Analyze similar restaurant finder apps
   - Review UX patterns

### Example Workflow

```
User: "Look up the Haversine formula and verify our implementation"

Claude: [Uses WebSearch to find authoritative sources]
        [Compares with utils/distance.ts implementation]
        [Reports any discrepancies]
```

---

## PRD: Reservations & Reviews with SQLite

### Executive Summary

Add reservation booking and user reviews functionality using SQLite as a lightweight, file-based database. **No Docker required** - SQLite runs as a single file in your project.

### Why SQLite?

| Advantage | Description |
|-----------|-------------|
| Zero Configuration | No server setup, no Docker, no external dependencies |
| File-Based | Database is a single `.db` file in your project |
| Fast | Up to 2000+ queries/second with proper indexing |
| Production-Ready | Used by major apps (WhatsApp, Firefox, many mobile apps) |
| Easy Backup | Just copy the `.db` file |

### Technical Approach

**Recommended Stack:**
- `better-sqlite3` - Fastest SQLite library for Node.js (synchronous API)
- **OR** `Prisma + SQLite` - If you prefer an ORM with migrations

### Database Schema

```sql
-- Reservations Table
CREATE TABLE reservations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  restaurant_id TEXT NOT NULL,
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  customer_phone TEXT,
  party_size INTEGER NOT NULL,
  reservation_date DATE NOT NULL,
  reservation_time TEXT NOT NULL,
  status TEXT DEFAULT 'pending', -- pending, confirmed, cancelled
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Reviews Table
CREATE TABLE reviews (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  restaurant_id TEXT NOT NULL,
  reviewer_name TEXT NOT NULL,
  reviewer_email TEXT,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  title TEXT,
  comment TEXT,
  visit_date DATE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_reservations_restaurant ON reservations(restaurant_id);
CREATE INDEX idx_reservations_date ON reservations(reservation_date);
CREATE INDEX idx_reviews_restaurant ON reviews(restaurant_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
```

### Implementation Steps

#### Phase 1: Database Setup

1. **Install better-sqlite3**
   ```bash
   npm install better-sqlite3
   npm install -D @types/better-sqlite3
   ```

2. **Create database utility** (`lib/db.ts`)
   ```typescript
   import Database from 'better-sqlite3';
   import path from 'path';

   const dbPath = path.join(process.cwd(), 'data', 'restaurant-finder.db');
   const db = new Database(dbPath);

   // Enable WAL mode for better performance
   db.pragma('journal_mode = WAL');

   export default db;
   ```

3. **Create migration script** (`scripts/init-db.ts`)
   ```typescript
   import db from '../lib/db';

   const initSQL = `
     CREATE TABLE IF NOT EXISTS reservations (...);
     CREATE TABLE IF NOT EXISTS reviews (...);
   `;

   db.exec(initSQL);
   console.log('Database initialized!');
   ```

4. **Add to package.json**
   ```json
   {
     "scripts": {
       "db:init": "tsx scripts/init-db.ts",
       "db:reset": "rm -f data/restaurant-finder.db && npm run db:init"
     }
   }
   ```

#### Phase 2: Reservations API

**`app/api/reservations/route.ts`**
```typescript
import { NextRequest, NextResponse } from 'next/server';
import db from '@/lib/db';

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const restaurantId = searchParams.get('restaurantId');

  const stmt = db.prepare(`
    SELECT * FROM reservations
    WHERE restaurant_id = ?
    ORDER BY reservation_date, reservation_time
  `);

  const reservations = stmt.all(restaurantId);
  return NextResponse.json(reservations);
}

export async function POST(request: NextRequest) {
  const body = await request.json();

  const stmt = db.prepare(`
    INSERT INTO reservations
    (restaurant_id, customer_name, customer_email, customer_phone,
     party_size, reservation_date, reservation_time, notes)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const result = stmt.run(
    body.restaurantId,
    body.customerName,
    body.customerEmail,
    body.customerPhone,
    body.partySize,
    body.reservationDate,
    body.reservationTime,
    body.notes
  );

  return NextResponse.json({ id: result.lastInsertRowid }, { status: 201 });
}
```

#### Phase 3: Reviews API

**`app/api/reviews/route.ts`**
```typescript
import { NextRequest, NextResponse } from 'next/server';
import db from '@/lib/db';

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const restaurantId = searchParams.get('restaurantId');

  const stmt = db.prepare(`
    SELECT * FROM reviews
    WHERE restaurant_id = ?
    ORDER BY created_at DESC
  `);

  const reviews = stmt.all(restaurantId);

  // Calculate average rating
  const avgStmt = db.prepare(`
    SELECT AVG(rating) as avgRating, COUNT(*) as totalReviews
    FROM reviews WHERE restaurant_id = ?
  `);
  const stats = avgStmt.get(restaurantId);

  return NextResponse.json({ reviews, stats });
}

export async function POST(request: NextRequest) {
  const body = await request.json();

  const stmt = db.prepare(`
    INSERT INTO reviews
    (restaurant_id, reviewer_name, reviewer_email, rating, title, comment, visit_date)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `);

  const result = stmt.run(
    body.restaurantId,
    body.reviewerName,
    body.reviewerEmail,
    body.rating,
    body.title,
    body.comment,
    body.visitDate
  );

  return NextResponse.json({ id: result.lastInsertRowid }, { status: 201 });
}
```

#### Phase 4: UI Components

1. **ReservationForm Component**
   - Date/time picker
   - Party size selector
   - Contact information fields
   - Confirmation display

2. **ReviewForm Component**
   - Star rating selector
   - Text input for title/comment
   - Submit and validation

3. **ReviewsList Component**
   - Display reviews with ratings
   - Sort by date/rating
   - Pagination

4. **Restaurant Detail Page**
   - Integrate reservation form
   - Show reviews section
   - Display average rating

### File Structure

```
├── data/
│   └── restaurant-finder.db      # SQLite database file
├── lib/
│   └── db.ts                     # Database connection
├── scripts/
│   └── init-db.ts                # Database initialization
├── app/
│   ├── api/
│   │   ├── reservations/
│   │   │   └── route.ts
│   │   └── reviews/
│   │       └── route.ts
│   └── restaurant/
│       └── [id]/
│           └── page.tsx          # Restaurant detail page
├── components/
│   ├── ReservationForm.tsx
│   ├── ReviewForm.tsx
│   └── ReviewsList.tsx
└── types/
    ├── reservation.ts
    └── review.ts
```

### Deployment Considerations

| Platform | SQLite Support | Notes |
|----------|----------------|-------|
| Vercel | Limited | Use Turso or external DB for serverless |
| Railway | Yes | Persistent volume required |
| Render | Yes | Disk-backed service |
| Self-hosted | Yes | Best option for SQLite |
| Local Dev | Yes | Just works |

**Recommendation for Production:**
- For serverless (Vercel): Consider Turso (SQLite edge) or Supabase
- For traditional hosting: SQLite works great

### Estimated Effort

| Phase | Tasks | Complexity |
|-------|-------|------------|
| Setup | Install deps, create db utils | Low |
| Reservations API | CRUD endpoints | Low-Medium |
| Reviews API | CRUD + aggregations | Low-Medium |
| UI Components | Forms, lists, validation | Medium |
| Integration | Connect to restaurant pages | Medium |

---

## Quick Start Commands

```bash
# Initialize Claude Code hooks
mkdir -p .claude/hooks
# Add settings.json as shown above

# Setup SQLite (when ready to implement PRD)
npm install better-sqlite3 @types/better-sqlite3
mkdir -p data
npm run db:init

# View Claude Code costs
# Run /cost in Claude Code

# Check loaded memories
# Run /memory in Claude Code
```

---

## References

- [better-sqlite3 Documentation](https://www.npmjs.com/package/better-sqlite3)
- [Next.js 14 with SQLite Guide](https://medium.com/@claudio-dev/setting-up-and-seeding-an-sqlite-database-in-a-next-js-14-fullstack-project-using-prisma-cc5f5f678b19)
- [Drizzle ORM + Next.js + SQLite Example](https://github.com/gustavocadev/nextjs-drizzle-orm-sqlite)
