import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { prisma } from '../database/prisma';

export const getPlatformStats = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    // Only accessible by ADMIN
    const userCount = await prisma.user.count();
    const pdfCount = await prisma.pdf.count();
    const quizCount = await prisma.quiz.count();
    const premiumCount = await prisma.user.count({ where: { subscription: 'PREMIUM' } });

    return res.status(200).json({
      success: true,
      stats: {
        totalUsers: userCount,
        premiumUsers: premiumCount,
        totalPdfsUploaded: pdfCount,
        totalQuizzesGenerated: quizCount,
      }
    });
  } catch (error) {
    next(error);
  }
};

export const getAllUsers = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const users = await prisma.user.findMany({
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        subscription: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' }
    });

    return res.status(200).json({ success: true, users });
  } catch (error) {
    next(error);
  }
};

export const upgradeUserSubscription = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { userId } = req.params;
    
    const user = await prisma.user.update({
      where: { id: userId },
      data: { subscription: 'PREMIUM' },
      select: { id: true, name: true, subscription: true }
    });

    return res.status(200).json({ success: true, user });
  } catch (error) {
    next(error);
  }
};
