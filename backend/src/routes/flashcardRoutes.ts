import { Router } from 'express';
import { generateFlashcards, getDueFlashcards, reviewFlashcard } from '../controllers/flashcardController';
import { authenticate } from '../middleware/auth';

const router = Router();
router.use(authenticate);

router.post('/generate', generateFlashcards);
router.get('/review', getDueFlashcards);
router.post('/:id/review', reviewFlashcard);

export default router;
