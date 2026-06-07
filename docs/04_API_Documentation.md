# API Documentation: StudySphere AI

This outlines the core RESTful endpoints exposed by the Node.js/Express backend. All non-auth endpoints require a valid JWT `Authorization: Bearer <token>`.

## 1. Authentication
`POST /api/auth/register`
- **Body:** `{ "email": "stu@exam.com", "password": "...", "name": "John" }`
- **Response:** `{ "token": "jwt...", "user": { ... } }`

`POST /api/auth/login`
- **Body:** `{ "email": "stu@exam.com", "password": "..." }`
- **Response:** `{ "token": "jwt...", "user": { ... } }`

## 2. User & Profile
`GET /api/users/me`
- **Response:** Returns the logged-in user's profile, XP, streak, and role.

`PATCH /api/users/me`
- **Body:** `{ "name": "John Doe", "pushToken": "..." }`

## 3. PDFs & Documents
`POST /api/pdfs/upload`
- **Type:** `multipart/form-data`
- **Behavior:** Uploads to S3, saves DB record, and queues AI text-extraction & embedding.
- **Response:** `{ "pdf": { "id": "...", "fileUrl": "...", "status": "processing" } }`

`GET /api/pdfs`
- **Query Params:** `?page=1&limit=20`
- **Response:** List of user's PDFs.

`GET /api/pdfs/:id`
- **Response:** Retrieves PDF details and generated summary.

## 4. AI Tutor & Chat
`POST /api/chats`
- **Body:** `{ "title": "Math Doubt Session" }`
- **Response:** Creates a new chat session.

`POST /api/chats/:id/messages`
- **Body:** `{ "content": "Explain Newton's laws from my Physics PDF.", "pdfId": "optional-context-id" }`
- **Behavior:** Performs vector search on `pdfId` chunks, sends context + prompt to LLM, saves result.
- **Response:** Server-Sent Events (SSE) stream or full JSON: `{ "message": { "role": "assistant", "content": "..." } }`

`POST /api/ai/generate`
- **Body:** `{ "type": "flashcards", "sourceText": "..." }`
- **Response:** Generates quick flashcards, mind-map JSON, or summary based on raw text.

## 5. Quizzes
`POST /api/quizzes/generate`
- **Body:** `{ "pdfId": "...", "difficulty": "medium", "questionCount": 10 }`
- **Behavior:** Enqueues quiz generation task. Returns task ID or waits and returns the quiz.

`POST /api/quizzes/:id/submit`
- **Body:** `{ "answers": { "q1_id": "Option A", ... } }`
- **Behavior:** Scores the quiz, updates user XP, updates weak areas.
- **Response:** `{ "score": 8, "total": 10, "xpEarned": 50 }`

## 6. Flashcards
`GET /api/flashcards/review`
- **Response:** Returns an array of flashcards due for review today based on the spaced repetition algorithm (e.g., SuperMemo-2 logic).

`POST /api/flashcards/:id/review`
- **Body:** `{ "quality": 4 }` (0-5 scale of how easy it was)
- **Behavior:** Updates the `interval`, `easeFactor`, and `nextReview` dates.

## 7. Study Plans
`POST /api/study-plans/generate`
- **Body:** `{ "subject": "Biology", "examDate": "2026-10-15" }`
- **Behavior:** AI generates a series of Tasks scheduled out until the exam.
