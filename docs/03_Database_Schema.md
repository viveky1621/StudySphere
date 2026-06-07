# Database Schema: StudySphere AI

The database is built on **PostgreSQL** and incorporates `pgvector` for embedding storage.

## 1. Entity-Relationship (ER) Overview
- A `User` can have many `PDF`s, `Notes`, `Quizzes`, and `StudyPlans`.
- A `PDF` is broken down into `DocumentChunk`s (vectors) for RAG.
- A `Quiz` contains many `Question`s.
- `Flashcard`s belong to a user and track spaced repetition data.
- `StudyPlan` contains multiple `Task`s.

## 2. Prisma Schema Representation

```prisma
datasource db {
  provider   = "postgresql"
  url        = env("DATABASE_URL")
  extensions = [vector]
}

generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["postgresqlExtensions"]
}

enum Role {
  STUDENT
  TEACHER
  ADMIN
}

enum SubTier {
  FREE
  PREMIUM
}

model User {
  id            String    @id @default(uuid())
  email         String    @unique
  passwordHash  String?
  googleId      String?
  name          String
  role          Role      @default(STUDENT)
  subscription  SubTier   @default(FREE)
  xpPoints      Int       @default(0)
  studyStreak   Int       @default(0)
  
  pdfs          Pdf[]
  notes         Note[]
  quizzes       Quiz[]
  flashcards    Flashcard[]
  studyPlans    StudyPlan[]
  chats         Chat[]
  
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
}

model Pdf {
  id            String    @id @default(uuid())
  userId        String
  title         String
  fileUrl       String
  tags          String[]
  summary       String?
  
  user          User      @relation(fields: [userId], references: [id])
  chunks        DocumentChunk[]
  
  createdAt     DateTime  @default(now())
}

model DocumentChunk {
  id            String    @id @default(uuid())
  pdfId         String
  content       String
  // Using pgvector for the embedding
  embedding     Unsupported("vector(1536)")? 
  
  pdf           Pdf       @relation(fields: [pdfId], references: [id])
}

model Note {
  id            String    @id @default(uuid())
  userId        String
  title         String
  content       String    @db.Text
  
  user          User      @relation(fields: [userId], references: [id])
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
}

model Quiz {
  id            String    @id @default(uuid())
  userId        String
  title         String
  topic         String
  score         Float?
  
  user          User      @relation(fields: [userId], references: [id])
  questions     Question[]
  
  createdAt     DateTime  @default(now())
}

model Question {
  id            String    @id @default(uuid())
  quizId        String
  prompt        String
  options       Json      // Array of string options
  answer        String
  explanation   String?
  
  quiz          Quiz      @relation(fields: [quizId], references: [id])
}

model Flashcard {
  id            String    @id @default(uuid())
  userId        String
  front         String
  back          String
  
  // Spaced Repetition logic
  interval      Int       @default(0)
  repetition    Int       @default(0)
  easeFactor    Float     @default(2.5)
  nextReview    DateTime  @default(now())
  
  user          User      @relation(fields: [userId], references: [id])
}

model Chat {
  id            String    @id @default(uuid())
  userId        String
  title         String
  
  user          User      @relation(fields: [userId], references: [id])
  messages      Message[]
  
  createdAt     DateTime  @default(now())
}

model Message {
  id            String    @id @default(uuid())
  chatId        String
  role          String    // "user" or "assistant"
  content       String    @db.Text
  
  chat          Chat      @relation(fields: [chatId], references: [id])
  createdAt     DateTime  @default(now())
}

model StudyPlan {
  id            String    @id @default(uuid())
  userId        String
  title         String    // e.g., "3-Day Physics Revision"
  
  user          User      @relation(fields: [userId], references: [id])
  tasks         Task[]
  
  createdAt     DateTime  @default(now())
}

model Task {
  id            String    @id @default(uuid())
  planId        String
  title         String
  isCompleted   Boolean   @default(false)
  dueDate       DateTime?
  
  plan          StudyPlan @relation(fields: [planId], references: [id])
}
```

## 3. Important Indexes
- **Vector Search Index:** Created on `DocumentChunk.embedding` using HNSW (Hierarchical Navigable Small World) for fast cosine similarity lookups.
- **Foreign Key Indexes:** Standard B-Tree indexes on `userId` and `pdfId` across all models to speed up relational queries.
- **Unique Constraint:** On `User.email`.
