import { Router } from 'express';
import { generateQuiz, getQuizzes, submitQuiz, getPublicQuizzes } from '../controllers/quizController';
import { authenticate } from '../middleware/auth';

const router = Router();
router.use(authenticate);

router.post('/generate', generateQuiz);
router.get('/', getQuizzes);
router.get('/public', getPublicQuizzes);
router.post('/:id/submit', submitQuiz);

export default router;
