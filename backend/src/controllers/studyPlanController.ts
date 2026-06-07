import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { prisma } from '../database/prisma';

export const generateOneDayBatting = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { subject, pdfId } = req.body;
    if (!req.user || !req.user.id) return res.status(401).json({ error: 'Unauthorized' });

    console.log(`[AI] Generating 'One Day Batting' revision for ${subject}...`);

    // Mock AI Logic:
    // In production, we'd query vector DB for "high weightage" and "previous years questions"
    // and use an LLM to generate condensed notes and a strict timetable.
    
    const mockTasks = [
      { title: 'Review high-weightage formulas (2 Hours)', isCompleted: false },
      { title: 'Solve Top 10 Previous Year Questions', isCompleted: false },
      { title: 'Read Exam-Ready Condensed Notes', isCompleted: false },
    ];

    const plan = await prisma.studyPlan.create({
      data: {
        userId: req.user.id,
        title: `One Day Batting: ${subject || 'Exam Prep'}`,
        tasks: {
          create: mockTasks,
        }
      },
      include: { tasks: true }
    });

    // We can also create a specific 'Note' containing the condensed material
    const note = await prisma.note.create({
      data: {
        userId: req.user.id,
        title: `Exam-Ready Notes: ${subject}`,
        content: `**HIGH WEIGHTAGE TOPICS**\n1. Concept A\n2. Concept B\n\n**PYQ PATTERNS**\nExpect questions on...`
      }
    });

    return res.status(201).json({ success: true, plan, note });
  } catch (error) {
    next(error);
  }
};

export const getStudyPlans = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user || !req.user.id) return res.status(401).json({ error: 'Unauthorized' });

    const plans = await prisma.studyPlan.findMany({
      where: { userId: req.user.id },
      include: { tasks: true },
      orderBy: { createdAt: 'desc' },
    });

    return res.status(200).json({ success: true, plans });
  } catch (error) {
    next(error);
  }
};
