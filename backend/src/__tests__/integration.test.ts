import request from 'supertest';
import jwt from 'jsonwebtoken';
import app from '../app';
import { prisma } from '../database/prisma';

// Helper to sign mock JWTs for tests
const signMockToken = (userId: string, role: string) => {
  return jwt.sign({ id: userId, role }, process.env.JWT_SECRET || 'secret', {
    expiresIn: '1h',
  });
};

describe('StudySphere AI E2E Integration Suite', () => {
  let studentToken: string;
  let studentId: string;
  let pdfId: string;
  let chatId: string;
  let quizId: string;
  let flashcardId: string;

  const testEmail = `student_${Date.now()}@studysphere.ai`;
  const testPassword = 'SecurePassword123!';

  beforeAll(async () => {
    // Clear mock database state between runs if necessary,
    // though the server boots fresh in tests.
  });

  describe('1. Authentication Flow', () => {
    it('should register a new student user successfully', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send({
          email: testEmail,
          password: testPassword,
          name: 'Vivek Student',
        });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.token).toBeDefined();
      expect(res.body.user.email).toBe(testEmail);
      expect(res.body.user.role).toBe('STUDENT');
      
      studentId = res.body.user.id;
    });

    it('should log in the newly registered student', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({
          email: testEmail,
          password: testPassword,
        });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.token).toBeDefined();
      expect(res.body.user.id).toBe(studentId);

      studentToken = res.body.token;
    });

    it('should block login with invalid password', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({
          email: testEmail,
          password: 'WrongPassword!',
        });

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error).toBe('Invalid credentials');
    });
  });

  describe('2. PDF Document Upload & RAG Processing Flow', () => {
    it('should upload a mock PDF file and trigger RAG pipeline', async () => {
      // Simulate file upload with supertest
      const mockPdfBuffer = Buffer.from('PDF_HEADER\nMock PDF text contents containing physics formulas and notes...');
      
      const res = await request(app)
        .post('/api/pdfs/upload')
        .set('Authorization', `Bearer ${studentToken}`)
        .attach('file', mockPdfBuffer, 'physics_notes.pdf')
        .field('title', 'Physics Chapter 1');

      expect(res.status).toBe(202);
      expect(res.body.success).toBe(true);
      expect(res.body.pdf.title).toBe('Physics Chapter 1');
      expect(res.body.pdf.userId).toBe(studentId);
      expect(res.body.pdf.summary).toBe('Processing...');

      pdfId = res.body.pdf.id;

      // Allow a brief delay for async processPdfPipeline execution in Javascript
      await new Promise(resolve => setTimeout(resolve, 300));

      // Query database to ensure processing succeeded
      const processedPdf = await prisma.pdf.findUnique({ where: { id: pdfId } });
      expect(processedPdf).toBeDefined();
      expect(processedPdf!.summary).toBe('Automatically generated summary of the document...');
      expect(processedPdf!.tags).toContain('processed');
    });

    it('should fetch the list of uploaded PDFs for the user', async () => {
      const res = await request(app)
        .get('/api/pdfs')
        .set('Authorization', `Bearer ${studentToken}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.pdfs.length).toBeGreaterThanOrEqual(1);
      expect(res.body.pdfs[0].id).toBe(pdfId);
    });
  });

  describe('3. RAG Chat Session Flow', () => {
    it('should create a new chat session', async () => {
      const res = await request(app)
        .post('/api/chats')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({ title: 'AI Physics Tutor Session' });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.chat.title).toBe('AI Physics Tutor Session');
      
      chatId = res.body.chat.id;
    });

    it('should send a query and get a RAG context-aware response', async () => {
      const res = await request(app)
        .post(`/api/chats/${chatId}/messages`)
        .set('Authorization', `Bearer ${studentToken}`)
        .send({
          content: 'Can you explain the main physics formulas in this PDF?',
          pdfId: pdfId,
        });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message.role).toBe('assistant');
      expect(res.body.message.content).toContain('mock AI response');
      expect(res.body.message.content).toContain('Can you explain');
    });
  });

  describe('4. Quiz & Spaced-Repetition Flashcard Flows', () => {
    it('should generate a quiz on the uploaded PDF topic', async () => {
      const res = await request(app)
        .post('/api/quizzes/generate')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({
          pdfId: pdfId,
          topic: 'Classical Mechanics',
          questionCount: 3,
        });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.quiz.title).toBe('Classical Mechanics Quiz');
      expect(res.body.quiz.questions.length).toBe(3);

      quizId = res.body.quiz.id;
    });

    it('should submit a score and update user XP and study streak', async () => {
      const res = await request(app)
        .post(`/api/quizzes/${quizId}/submit`)
        .set('Authorization', `Bearer ${studentToken}`)
        .send({ score: 100 });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.quiz.score).toBe(100);
      expect(res.body.xpEarned).toBe(50);
    });

    it('should generate flashcards for active study', async () => {
      const res = await request(app)
        .post('/api/flashcards/generate')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({
          pdfId: pdfId,
          topic: 'Classical Mechanics',
        });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.flashcards.length).toBeGreaterThan(0);

      flashcardId = res.body.flashcards[0].id;
    });

    it('should review a flashcard and advance its nextReview date via spaced repetition', async () => {
      const res = await request(app)
        .post(`/api/flashcards/${flashcardId}/review`)
        .set('Authorization', `Bearer ${studentToken}`)
        .send({ quality: 4 }); // 0-5 SuperMemo scale

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.flashcard.repetition).toBe(1);
      expect(res.body.flashcard.interval).toBe(1);
      expect(new Date(res.body.flashcard.nextReview).getTime()).toBeGreaterThan(Date.now());
    });
  });

  describe('5. AI Study Planner & Revision Flows', () => {
    it('should generate a 1-day batting/crash study plan', async () => {
      const res = await request(app)
        .post('/api/study-plans/one-day-batting')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({
          subject: 'Quantum Physics',
          pdfId: pdfId,
        });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.plan.title).toBe('One Day Batting: Quantum Physics');
      expect(res.body.plan.tasks.length).toBeGreaterThan(0);
      expect(res.body.note.title).toContain('Exam-Ready Notes');
    });
  });

  describe('6. Role-Based Access Control (RBAC) Admin & Teacher Routes', () => {
    it('should block students from viewing platform stats', async () => {
      const res = await request(app)
        .get('/api/admin/stats')
        .set('Authorization', `Bearer ${studentToken}`);

      expect(res.status).toBe(403);
      expect(res.body.error).toContain('Forbidden');
    });

    it('should allow ADMIN users to view stats', async () => {
      const adminToken = signMockToken('admin_user_id', 'ADMIN');
      const res = await request(app)
        .get('/api/admin/stats')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.stats.totalUsers).toBeDefined();
    });

    it('should allow TEACHER users to get student analytics', async () => {
      const teacherToken = signMockToken('teacher_user_id', 'TEACHER');
      const res = await request(app)
        .get('/api/teacher/analytics')
        .set('Authorization', `Bearer ${teacherToken}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.analytics.averageClassScore).toBeDefined();
    });
  });
});
