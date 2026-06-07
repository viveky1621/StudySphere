import { Router } from 'express';
import { publishPdf, publishQuiz, getStudentAnalytics } from '../controllers/teacherController';
import { authenticate, requireRole } from '../middleware/auth';

const router = Router();

// Protect all teacher routes
router.use(authenticate);
router.use(requireRole(['TEACHER', 'ADMIN']));

router.post('/pdfs/:pdfId/publish', publishPdf);
router.post('/quizzes/:quizId/publish', publishQuiz);
router.get('/analytics', getStudentAnalytics);

export default router;
