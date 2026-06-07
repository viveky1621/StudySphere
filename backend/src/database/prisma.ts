import { PrismaClient } from '@prisma/client';
import { mockPrisma } from './mockPrisma';

declare global {
  // allow global `var` declarations
  // eslint-disable-next-line no-var
  var prisma: any;
}

const isMock = process.env.MOCK_DATABASE !== 'false';

if (isMock) {
  console.log('🔌 [Database] Running in Standalone In-Memory Mock Database mode.');
}

export const prisma = isMock
  ? (mockPrisma as any)
  : (global.prisma ||
    new PrismaClient({
      log: ['query', 'error', 'warn'],
    }));

if (process.env.NODE_ENV !== 'production' && !isMock) {
  global.prisma = prisma;
}

