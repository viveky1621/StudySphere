import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { prisma } from '../database/prisma';
import { OAuth2Client } from 'google-auth-library';

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Validation Schemas
const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8, 'Password must be at least 8 characters long'),
  name: z.string().min(2, 'Name is required'),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1, 'Password is required'),
});

const generateToken = (userId: string, role: string) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined in environment variables');
  }
  return jwt.sign({ id: userId, role }, process.env.JWT_SECRET, {
    expiresIn: '7d',
  });
};

export const register = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsedData = registerSchema.parse(req.body);

    const existingUser = await prisma.user.findUnique({
      where: { email: parsedData.email },
    });

    if (existingUser) {
      return res.status(400).json({ success: false, error: 'Email is already in use' });
    }

    const salt = await bcrypt.genSalt(12);
    const passwordHash = await bcrypt.hash(parsedData.password, salt);

    const user = await prisma.user.create({
      data: {
        email: parsedData.email,
        name: parsedData.name,
        passwordHash,
      },
    });

    const token = generateToken(user.id, user.role);

    return res.status(201).json({
      success: true,
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      },
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, error: error.errors });
    }
    next(error);
  }
};

export const login = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsedData = loginSchema.parse(req.body);

    const user = await prisma.user.findUnique({
      where: { email: parsedData.email },
    });

    if (!user || !user.passwordHash) {
      return res.status(401).json({ success: false, error: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(parsedData.password, user.passwordHash);

    if (!isMatch) {
      return res.status(401).json({ success: false, error: 'Invalid credentials' });
    }

    const token = generateToken(user.id, user.role);

    return res.status(200).json({
      success: true,
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        xpPoints: user.xpPoints,
        studyStreak: user.studyStreak,
        subscription: user.subscription,
      },
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, error: error.errors });
    }
    next(error);
  }
};

const googleLoginSchema = z.object({
  idToken: z.string().min(1, 'idToken is required'),
});

export const googleLogin = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsedData = googleLoginSchema.parse(req.body);

    const ticket = await client.verifyIdToken({
      idToken: parsedData.idToken,
      // audience: process.env.GOOGLE_CLIENT_ID, // Automatically checked if client is initialized with it
    });
    
    const payload = ticket.getPayload();
    if (!payload || !payload.email) {
      return res.status(401).json({ success: false, error: 'Invalid Google Token' });
    }

    const { email, name } = payload;

    let user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      // Create new user for google sign-in with dummy password since they use OAuth
      const salt = await bcrypt.genSalt(12);
      const randomPassword = Math.random().toString(36).slice(-8) + Math.random().toString(36).slice(-8);
      const passwordHash = await bcrypt.hash(randomPassword, salt);

      user = await prisma.user.create({
        data: {
          email,
          name: name || 'Google User',
          passwordHash,
          googleId: payload.sub,
        },
      });
    } else if (!user.googleId) {
      // Update existing user with googleId if it was missing
      user = await prisma.user.update({
        where: { id: user.id },
        data: { googleId: payload.sub }
      });
    }

    const token = generateToken(user.id, user.role);

    return res.status(200).json({
      success: true,
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        xpPoints: user.xpPoints,
        studyStreak: user.studyStreak,
        subscription: user.subscription,
      },
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, error: error.errors });
    }
    return res.status(401).json({ success: false, error: 'Google authentication failed' });
  }
};

export const guestLogin = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const salt = await bcrypt.genSalt(12);
    const randomPassword = Math.random().toString(36).slice(-8) + Math.random().toString(36).slice(-8);
    const passwordHash = await bcrypt.hash(randomPassword, salt);
    const guestEmail = `guest_${Date.now()}_${Math.random().toString(36).substring(2, 8)}@studysphere.ai`;

    const user = await prisma.user.create({
      data: {
        email: guestEmail,
        name: 'Guest User',
        passwordHash,
        role: 'STUDENT',
        subscription: 'FREE',
      },
    });

    const token = generateToken(user.id, user.role);

    return res.status(200).json({
      success: true,
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        xpPoints: user.xpPoints,
        studyStreak: user.studyStreak,
        subscription: user.subscription,
      },
    });
  } catch (error) {
    next(error);
  }
};
