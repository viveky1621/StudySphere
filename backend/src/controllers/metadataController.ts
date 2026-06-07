import { Request, Response, NextFunction } from 'express';
import { prisma } from '../database/prisma';

// Categories
export const getCategories = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const categories = await prisma.category.findMany();
    return res.status(200).json({ success: true, categories });
  } catch (error) {
    next(error);
  }
};

export const createCategory = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { name, description } = req.body;
    const category = await prisma.category.create({ data: { name, description } });
    return res.status(201).json({ success: true, category });
  } catch (error) {
    next(error);
  }
};

// Branches
export const getBranches = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { categoryId } = req.query;
    const whereClause = categoryId ? { categoryId: String(categoryId) } : {};
    const branches = await prisma.branch.findMany({ where: whereClause });
    return res.status(200).json({ success: true, branches });
  } catch (error) {
    next(error);
  }
};

export const createBranch = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { categoryId, name, description } = req.body;
    const branch = await prisma.branch.create({ data: { categoryId, name, description } });
    return res.status(201).json({ success: true, branch });
  } catch (error) {
    next(error);
  }
};

// Subjects
export const getSubjects = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { branchId } = req.query;
    const whereClause = branchId ? { branchId: String(branchId) } : {};
    const subjects = await prisma.subject.findMany({ where: whereClause });
    return res.status(200).json({ success: true, subjects });
  } catch (error) {
    next(error);
  }
};

export const createSubject = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { branchId, name, description } = req.body;
    const subject = await prisma.subject.create({ data: { branchId, name, description } });
    return res.status(201).json({ success: true, subject });
  } catch (error) {
    next(error);
  }
};
