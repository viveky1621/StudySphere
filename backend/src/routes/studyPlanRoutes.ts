import { Router } from 'express';
import { generateOneDayBatting, getStudyPlans } from '../controllers/studyPlanController';
import { authenticate } from '../middleware/auth';

const router = Router();
router.use(authenticate);

router.post('/one-day-batting', generateOneDayBatting);
router.get('/', getStudyPlans);

export default router;
