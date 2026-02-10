# E-Commerce CRM Web Application

A scalable, production-ready CRM solution for e-commerce businesses to centralize customer data, orders, marketing interactions, and support tickets.

## Tech Stack
- **Backend**: NestJS + Prisma + PostgreSQL
- **Frontend**: React (Vite) + Tailwind CSS + Lucide Icons + Recharts
- **Auth**: JWT with Passport.js
- **Database**: PostgreSQL (Docker-ready)

## Features
1. **Authentication**: Secure JWT-based login with Role-based access.
2. **Customer Management**: Unified profiles with order history, tags, and LTV.
3. **Order Tracking**: Detailed transaction history and status tracking.
4. **Analytics**: KPI cards (Revenue, AOV, LTV) and interactive charts.
5. **Support Tickets**: Integrated helpdesk linked to customers and orders.
6. **Docker Ready**: Full-stack containerization via Docker Compose.

## Getting Started

### Prerequisites
- Node.js (v20+)
- Docker Desktop

### 1. Database Setup
Start the PostgreSQL database and Adminer (GUI):
```bash
docker-compose up -d db adminer
```

### 2. Backend Setup
```bash
cd server
npm install
npx prisma migrate dev --name init
npm run seed
npm run start:dev
```

### 3. Frontend Setup
```bash
cd client
npm install
npm run dev
```

## Architecture
- **Clean Architecture**: Separation of concerns between API (Controllers), Business Logic (Services), and Data Access (Prisma).
- **Component-Based UI**: Modular React components for tables, charts, and layouts.
- **RESTful API**: Extensible and well-documented endpoints.

## License
MIT
