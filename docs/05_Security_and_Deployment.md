# Security & Deployment Design: StudySphere AI

## 1. Security Implementation

### 1.1 Authentication & Authorization
- **JWT (JSON Web Tokens):** Short-lived access tokens (15m) and HTTP-only refresh tokens (7d) to prevent XSS theft.
- **Password Hashing:** `bcrypt` with a minimum salt round of 12.
- **RBAC:** Middleware on routes checks for `STUDENT`, `TEACHER`, or `ADMIN` roles. `ADMIN` is strictly required for endpoints in `/api/admin/*`.

### 1.2 Web & API Protection
- **CORS:** Restrict origin requests strictly to the frontend domains/app identifiers.
- **Rate Limiting:** `express-rate-limit` to prevent brute force attacks (e.g., max 5 login attempts per minute, max 50 AI generations per hour for free users).
- **Payload Validation:** Joi, Zod, or class-validator to strictly validate all incoming JSON requests.
- **SQL Injection:** Mitigated inherently by using the Prisma ORM.

### 1.3 Data & File Security
- **File Uploads:** S3 buckets must be configured to deny public list access. User uploads are scanned for malicious MIME types. PDFs should be validated by magic numbers, not just `.pdf` extension.
- **PII:** Minimal PII is collected (Email, Name). Data is encrypted in transit (TLS 1.2+) and at rest (AWS RDS/Postgres encryption).

## 2. Deployment Architecture (DevOps)

### 2.1 Infrastructure (AWS / Cloud)
- **Compute:** ECS (Elastic Container Service) or Google Cloud Run for the Node.js backend. Auto-scaling enabled based on CPU utilization to handle exam-season spikes.
- **Database:** Managed PostgreSQL (AWS RDS or Supabase) with pgvector extension enabled.
- **Caching & Queues:** AWS ElastiCache (Redis) to handle session state and BullMQ background job queues.
- **Storage:** S3 with CloudFront CDN for fast delivery of static assets and PDFs.

### 2.2 CI/CD Pipeline (GitHub Actions)
**Trigger: Push to `main`**
1. **Lint & Test:** Run ESLint, Prettier, Jest unit tests.
2. **Build Backend:** Build Node.js Docker image.
3. **Build Frontend:** Run `flutter build apk/ipa`.
4. **Deploy Backend:** Push Docker image to ECR, update ECS task definition.
5. **Release Frontend:** Upload binaries to App Store Connect (TestFlight) and Google Play Console (Internal Track) via Fastlane.

### 2.3 Docker Configuration Strategy
A `docker-compose.yml` is used for local development:
- **`api`:** Node.js Express server with volume mounts for hot-reloading.
- **`worker`:** Node.js instance dedicated to pulling from BullMQ to process AI/PDF tasks.
- **`db`:** `pgvector/pgvector:pg16` image.
- **`redis`:** `redis:alpine` image.

### 2.4 Monitoring & Logging
- **Logging:** Winston/Morgan logging in Node.js. Logs pushed to Datadog or AWS CloudWatch.
- **APM:** Sentry for error tracking and performance monitoring on both the Flutter app and Node backend.
