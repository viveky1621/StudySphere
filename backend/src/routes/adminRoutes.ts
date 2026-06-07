import { Router } from 'express';
import { getPlatformStats, getAllUsers, upgradeUserSubscription } from '../controllers/adminController';
import { authenticate, requireRole } from '../middleware/auth';

const router = Router();

// Protect all admin routes
router.use(authenticate);
router.use(requireRole(['ADMIN']));

router.get('/stats', getPlatformStats);
router.get('/users', getAllUsers);
router.post('/users/:userId/upgrade', upgradeUserSubscription);

export default router;
