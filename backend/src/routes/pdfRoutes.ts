import { Router } from 'express';
import multer from 'multer';
import { uploadPdf, getPdfs, getPublicPdfs, bookmarkPdf, recordDownload } from '../controllers/pdfController';
import { authenticate } from '../middleware/auth';

const router = Router();

// Store file in memory but limit to 10MB to prevent DoS
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

router.use(authenticate); // Require valid JWT for all PDF routes

router.post('/upload', upload.single('file'), uploadPdf);
router.get('/', getPdfs);
router.get('/public', getPublicPdfs);
router.post('/:id/bookmark', bookmarkPdf);
router.post('/:id/download', recordDownload);

export default router;
