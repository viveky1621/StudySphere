import { AuthRequest } from '../middleware/auth';
import { Response, NextFunction } from 'express';
import { prisma } from '../database/prisma';
import { processPdfPipeline } from '../ai/ragPipeline';
import { ragQueue } from '../ai/queue';

export const uploadPdf = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file uploaded' });
    }

    if (!req.user || !req.user.id) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const { originalname, buffer } = req.file;
    const { title: bodyTitle, categoryId, branchId, subjectId, semester, thumbnailUrl } = req.body;
    const title = bodyTitle || originalname;

    // 1. In a production app, we would upload the buffer to AWS S3 here
    // const s3Url = await uploadToS3(buffer, originalname);
    const fileUrl = 'https://mock-s3-bucket.s3.amazonaws.com/' + originalname;

    // 2. Create the PDF record in the database
    const pdfRecord = await prisma.pdf.create({
      data: {
        title,
        fileUrl,
        userId: req.user.id,
        tags: ['uploaded'],
        summary: 'Processing...', // Placeholder while RAG pipeline runs
        categoryId,
        branchId,
        subjectId,
        semester: semester ? parseInt(semester) : null,
        thumbnailUrl
      },
    });

    // 3. Trigger the RAG Pipeline via BullMQ
    await ragQueue.add('process-pdf', {
      pdfId: pdfRecord.id,
      fileBufferArray: buffer,
    }, { removeOnComplete: true });

    return res.status(202).json({
      success: true,
      message: 'PDF uploaded successfully and is being processed.',
      pdf: pdfRecord,
    });
  } catch (error) {
    next(error);
  }
};

export const getPdfs = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { categoryId, branchId, subjectId, semester } = req.query;
    
    let whereClause: any = {};
    if (categoryId) whereClause.categoryId = String(categoryId);
    if (branchId) whereClause.branchId = String(branchId);
    if (subjectId) whereClause.subjectId = String(subjectId);
    if (semester) whereClause.semester = parseInt(String(semester));

    const pdfs = await prisma.pdf.findMany({
      where: whereClause,
      include: {
        category: true,
        branch: true,
        subject: true
      },
      orderBy: { createdAt: 'desc' }
    });
    return res.status(200).json({ success: true, pdfs });
  } catch (error) {
    next(error);
  }
};

export const bookmarkPdf = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user || !req.user.id) return res.status(401).json({ error: 'Unauthorized' });
    const { id } = req.params; // pdfId
    const bookmark = await prisma.bookmark.create({
      data: {
        userId: req.user.id,
        pdfId: id,
      }
    });
    return res.status(201).json({ success: true, bookmark });
  } catch (error) {
    next(error);
  }
};

export const recordDownload = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user || !req.user.id) return res.status(401).json({ error: 'Unauthorized' });
    const { id } = req.params; // pdfId
    
    const download = await prisma.download.create({
      data: {
        userId: req.user.id,
        pdfId: id,
      }
    });

    await prisma.pdf.update({
      where: { id },
      data: { downloadCount: { increment: 1 } }
    });

    return res.status(201).json({ success: true, download });
  } catch (error) {
    next(error);
  }
};

export const getPublicPdfs = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const pdfs = await prisma.pdf.findMany({
      where: { isPublic: true },
      include: { user: { select: { name: true, role: true } } },
      orderBy: { createdAt: 'desc' }
    });
    return res.status(200).json({ success: true, pdfs });
  } catch (error) {
    next(error);
  }
};
