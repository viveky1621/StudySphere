import { Router } from 'express';
import { createChat, getChats, sendMessage } from '../controllers/chatController';
import { authenticate } from '../middleware/auth';

const router = Router();

router.use(authenticate); // Require valid JWT for all chat routes

router.post('/', createChat);
router.get('/', getChats);
router.post('/:chatId/messages', sendMessage);

export default router;
