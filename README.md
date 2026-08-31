# 🏨 AudioCodes Live Hub — Workshop Hotel PMS

> Hotel Property Management System portal for **AudioCodes Live Hub** AI Agent workshops.

## What is this?

This is a simulated hotel management system that serves as an external REST API backend for AI Agents built during AudioCodes Live Hub workshops. Workshop participants create voice AI agents in Live Hub that call this portal's API to manage hotel operations via phone calls.

## Architecture

```
Guest Phone Call → Live Hub (SIP Trunk + AI Agent) → REST API → This Portal
                                                   ← JSON Response ←
```

- **Frontend:** Static dashboard (Cloudflare Pages)
- **Backend:** Hono.js API (Cloudflare Workers)
- **Database:** Cloudflare D1 (SQLite)
- **Hosting:** Cloudflare (free tier)

## API Endpoints

### 🛏️ Rooms
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/rooms` | List all rooms |
| `GET` | `/api/rooms/available` | Check availability |
| `GET` | `/api/rooms/:number` | Room details |

### 📋 Reservations
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/reservations` | Create reservation |
| `GET` | `/api/reservations/:id` | Get reservation |
| `PUT` | `/api/reservations/:id` | Modify reservation |
| `DELETE` | `/api/reservations/:id` | Cancel reservation |

### 🧹 Housekeeping
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/housekeeping/requests` | Create request |
| `GET` | `/api/housekeeping/requests/:id` | Get request status |

### 🍽️ Room Service
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/roomservice/menu` | Get menu |
| `POST` | `/api/roomservice/orders` | Place order |

### 🔧 Maintenance
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/maintenance/tickets` | Report issue |
| `GET` | `/api/maintenance/tickets/:id` | Get ticket status |

### ⏰ Wake-up Calls
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/wakeup` | Schedule wake-up |

### 📡 Webhooks (from Live Hub)
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/webhooks/post-call` | Post-call analysis |
| `POST` | `/api/webhooks/call-events` | In-call events |
| `POST` | `/api/webhooks/dialout-status` | Dialout status |

### ℹ️ Hotel Info
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/hotel/info` | Hotel information |

## Authentication

Each workshop participant receives a unique API key:
```
Authorization: Bearer wk-participant-XX-xxxxxx
```

## Quick Start

```bash
npm install
npm run db:init       # Create local D1 tables
npm run db:seed       # Load sample data
npm run dev           # Start local dev server
```

## Deploy to Cloudflare

```bash
npx wrangler d1 create hotel-db                # Create D1 database
# Update wrangler.toml with returned database_id
npm run db:init:remote                          # Init remote DB
npm run db:seed:remote                          # Seed remote DB
npm run deploy                                  # Deploy to CF Workers
```

## License

MIT — Built for AudioCodes Live Hub workshops.
