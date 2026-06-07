import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { prisma } from '../database/prisma';

export const generateFlashcards = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { pdfId, topic } = req.body;
    if (!req.user || !req.user.id) return res.status(401).json({ error: 'Unauthorized' });

    // Mock AI Flashcard Generation
    const mockFlashcards = [
      { front: `What is the core concept of ${topic || 'this text'}?`, back: 'The core concept is...' },
      { front: 'Define the main term used in chapter 1.', back: 'It means...' },
    ];

    const flashcards = await prisma.$transaction(
      mockFlashcards.map(fc => prisma.flashcard.create({
        data: {
          userId: req.user!.id,
          front: fc.front,
          back: fc.back,
        }
      }))
    );

    return res.status(201).json({ success: true, flashcards });
  } catch (error) {
    next(error);
  }
};

export const getDueFlashcards = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user || !req.user.id) return res.status(401).json({ error: 'Unauthorized' });

    // Fetch flashcards where nextReview date is in the past
    const flashcards = await prisma.flashcard.findMany({
      where: { 
        userId: req.user.id,
        nextReview: { lte: new Date() }
      },
      take: 20, // Limit to 20 for this session
    });

    return res.status(200).json({ success: true, flashcards });
  } catch (error) {
    next(error);
  }
};

export const reviewFlashcard = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { quality } = req.body; // 0 to 5 scale (SuperMemo-2)
    if (!req.user || !req.user.id) return res.status(401).json({ error: 'Unauthorized' });

    const card = await prisma.flashcard.findUnique({ where: { id } });
    if (!card) return res.status(404).json({ error: 'Not found' });

    // Simplified SuperMemo-2 Spaced Repetition Algorithm
    let { interval, repetition, easeFactor } = card;

    if (quality >= 3) {
      if (repetition === 0) interval = 1;
      else if (repetition === 1) interval = 6;
      else interval = Math.round(interval * easeFactor);
      
      repetition += 1;
    } else {
      repetition = 0;
      interval = 1;
    }

    easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (easeFactor < 1.3) easeFactor = 1.3;

    const nextReview = new Date();
    nextReview.setDate(nextReview.getDate() + interval);

    const updatedCard = await prisma.flashcard.update({
      where: { id },
      data: { interval, repetition, easeFactor, nextReview },
    });

    return res.status(200).json({ success: true, flashcard: updatedCard });
  } catch (error) {
    next(error);
  }
};
