import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { prisma } from '../database/prisma';

export const publishPdf = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { pdfId } = req.params;
    
    // Ensure the PDF belongs to the teacher
    const pdf = await prisma.pdf.findFirst({
      where: { id: pdfId, userId: req.user!.id }
    });

    if (!pdf) return res.status(404).json({ error: 'PDF not found or unauthorized' });

    const updatedPdf = await prisma.pdf.update({
      where: { id: pdfId },
      data: { isPublic: true }
    });

    return res.status(200).json({ success: true, pdf: updatedPdf });
  } catch (error) {
    next(error);
  }
};

export const publishQuiz = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { quizId } = req.params;
    
    const quiz = await prisma.quiz.findFirst({
      where: { id: quizId, userId: req.user!.id }
    });

    if (!quiz) return res.status(404).json({ error: 'Quiz not found or unauthorized' });

    const updatedQuiz = await prisma.quiz.update({
      where: { id: quizId },
      data: { isPublic: true }
    });

    return res.status(200).json({ success: true, quiz: updatedQuiz });
  } catch (error) {
    next(error);
  }
};

export const getStudentAnalytics = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    // In a real app, you would filter by students enrolled in the teacher's class.
    // For now, we'll return generic stats of public quiz engagement.
    
    const globalQuizzes = await prisma.quiz.count({ where: { isPublic: true } });
    
    return res.status(200).json({ 
      success: true, 
      analytics: {
        publishedQuizzes: globalQuizzes,
        averageClassScore: 82.5, // Mocked data
      }
    });
  } catch (error) {
    next(error);
  }
};
