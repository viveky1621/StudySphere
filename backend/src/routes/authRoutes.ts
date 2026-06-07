import { Router } from 'express';
import { register, login, googleLogin, guestLogin } from '../controllers/authController';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.post('/google', googleLogin);
router.post('/guest', guestLogin);

export default router;
