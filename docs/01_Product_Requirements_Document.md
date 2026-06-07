# Product Requirements Document (PRD): StudySphere AI

## 1. Product Overview
**StudySphere AI** is an AI-powered educational ecosystem designed to act as a unified hub for students. By combining the best elements of Notion (organization), Quizlet (flashcards/quizzes), and ChatGPT (AI tutoring/generation), StudySphere AI aims to streamline exam preparation, learning, and revision.

## 2. Target Audience & Personas
### 2.1 Student (Primary)
- **Goals:** Learn, revise, practice, and master subjects efficiently.
- **Key Actions:** Upload PDFs, generate AI summaries/quizzes/flashcards, chat with AI Tutor, track study streaks, and build revision plans.

### 2.2 Teacher (Secondary)
- **Goals:** Distribute materials and monitor student engagement.
- **Key Actions:** Upload materials, create structured quizzes, publish curated notes, and view analytics.

### 2.3 Admin (Operational)
- **Goals:** Maintain platform health, monitor AI usage, and manage subscriptions.
- **Key Actions:** Moderate content, manage users (RBAC), view revenue analytics, monitor AI token usage.

## 3. Core Features & Requirements
### 3.1 Authentication & Onboarding
- **Methods:** Email/Password, Google OAuth.
- **Verification:** OTP for email verification, Forgot Password flow.
- **Session:** JWT with short-lived access tokens and refresh tokens.

### 3.2 Home Dashboard
- **Content:** Recent PDFs, Recommended Materials, Trending Notes, Upcoming Exams.
- **Gamification:** Study Streak, XP Points, Levels, Progress Analytics.

### 3.3 PDF & Document Management
- **Storage:** AWS S3 for PDF storage.
- **Features:** Organize by subjects/tags, global search.
- **Reader:** Highlight text, bookmark pages, text-to-speech, AI tools (Explain, Simplify, Translate on selection).

### 3.4 AI Tutor & PDF Processing (RAG)
- **Automated Processing:** Extract text, chunk, embed, and store in Vector DB (`pgvector`). Generate automated summaries, notes, flashcards, MCQs, and mind maps.
- **AI Tutor Chat:** Context-aware chatbot that uses uploaded PDFs to answer doubts, explain formulas, and provide step-by-step solutions. Voice chat support.

### 3.5 Quiz & Flashcard Engines
- **Quiz:** MCQ, Multiple Correct, True/False, Fill Blank. Supports timed tests and difficulty levels.
- **Flashcards:** Spaced Repetition System (SRS) with mastery scoring.

### 3.6 Study Planner & Revision Engine
- **Planner:** Timetable creation, goal setting, and AI-recommended schedules based on weak areas.
- **Revision Engine:** Generates 1-day, 3-day, 1-week, and crash plans based on user performance.

## 4. User Flows
### 4.1 New Student Onboarding Flow
1. User signs up via Google / Email.
2. User selects grade, subjects, and upcoming exam dates.
3. User lands on Home Dashboard displaying a personalized 0-day study plan.

### 4.2 PDF Upload & Study Flow
1. User uploads a PDF (e.g., "Biology Chapter 4").
2. Backend triggers background job: OCR -> Text Extraction -> Chunking -> Vector Embeddings -> AI Generation (Summary, Flashcards).
3. User receives notification: "Biology Chapter 4 Processing Complete".
4. User opens PDF Reader, highlights a complex paragraph, and clicks "AI Explain".
5. User takes an auto-generated Quiz on the PDF.

### 4.3 Revision Flow
1. User requests a "3-Day Revision Plan" for Physics.
2. AI analyzes past quiz accuracy in Physics.
3. AI generates a day-by-day task list with links to specific flashcards and topics to re-read.
