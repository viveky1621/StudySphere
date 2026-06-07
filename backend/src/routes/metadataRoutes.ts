import { Router } from 'express';
import { getCategories, createCategory, getBranches, createBranch, getSubjects, createSubject } from '../controllers/metadataController';
import { authenticate, requireRole } from '../middleware/auth';

const router = Router();

// Publicly readable by authenticated users
router.use(authenticate);

router.get('/categories', getCategories);
router.get('/branches', getBranches);
router.get('/subjects', getSubjects);

// Only admins can create metadata
router.use(requireRole(['ADMIN']));

router.post('/categories', createCategory);
router.post('/branches', createBranch);
router.post('/subjects', createSubject);

export default router;
