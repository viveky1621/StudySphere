import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { prisma } from '../database/prisma';

export const generateQuiz = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { pdfId, topic, questionCount = 5 } = req.body;
    if (!req.user || !req.user.id) return res.status(401).json({ error: 'Unauthorized' });

    // Mock AI Quiz Generation
    // In production, query the PDF chunks and ask LLM to generate `questionCount` MCQs in JSON format.
    const mockQuestions = Array(questionCount).fill(0).map((_, i) => ({
      prompt: `Mock Question ${i + 1} regarding ${topic || 'this document'}?`,
      options: ['Option A', 'Option B', 'Option C', 'Option D'],
      answer: 'Option A',
      explanation: 'Because it is the mock answer.',
    }));

    const quiz = await prisma.quiz.create({
      data: {
        userId: req.user.id,
        title: `${topic || 'Document'} Quiz`,
        topic: topic || 'General',
        questions: {
          create: mockQuestions,
        }
      },
      include: { questions: true }
    });

    return res.status(201).json({ success: true, quiz });
  } catch (error) {
    next(error);
  }
};

export const getQuizzes = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user || !req.user.id) return res.status(401).json({ error: 'Unauthorized' });
    const quizzes = await prisma.quiz.findMany({
      where: { userId: req.user.id },
      include: { _count: { select: { questions: true } } },
      orderBy: { createdAt: 'desc' },
    });
    return res.status(200).json({ success: true, quizzes });
  } catch (error) {
    next(error);
  }
};

export const getPublicQuizzes = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const quizzes = await prisma.quiz.findMany({
      where: { isPublic: true },
      include: { 
        user: { select: { name: true, role: true } },
        _count: { select: { questions: true } }
      },
      orderBy: { createdAt: 'desc' },
    });
    return res.status(200).json({ success: true, quizzes });
  } catch (error) {
    next(error);
  }
};

export const submitQuiz = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { score } = req.body; // e.g., percentage or correct count
    if (!req.user || !req.user.id) return res.status(401).json({ error: 'Unauthorized' });

    const quiz = await prisma.quiz.update({
      where: { id },
      data: { score },
    });

    // Update User XP
    await prisma.user.update({
      where: { id: req.user.id },
      data: {
        xpPoints: { increment: 50 },
        studyStreak: { increment: 1 },
      }
    });

    return res.status(200).json({ success: true, quiz, xpEarned: 50 });
  } catch (error) {
    next(error);
  }
};
