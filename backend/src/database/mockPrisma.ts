import crypto from 'crypto';

// In-Memory Database Stores
const users: any[] = [];
const pdfs: any[] = [];
const documentChunks: any[] = [];
const notes: any[] = [];
const quizzes: any[] = [];
const questions: any[] = [];
const flashcards: any[] = [];
const chats: any[] = [];
const messages: any[] = [];
const studyPlans: any[] = [];
const tasks: any[] = [];
const categories: any[] = [];
const branches: any[] = [];
const subjects: any[] = [];
const bookmarks: any[] = [];
const downloads: any[] = [];

// Cosine Similarity helper for Vector searches
function cosineSimilarity(a: number[], b: number[]): number {
  if (!a || !b || a.length !== b.length) return 0;
  let dotProduct = 0;
  let normA = 0;
  let normB = 0;
  for (let i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  normA = Math.sqrt(normA);
  normB = Math.sqrt(normB);
  if (normA === 0 || normB === 0) return 0;
  return dotProduct / (normA * normB);
}

// Helper to filter objects by query
function filterItems(items: any[], where: any): any[] {
  if (!where) return items;
  return items.filter(item => {
    for (const key of Object.keys(where)) {
      const condition = where[key];
      if (condition && typeof condition === 'object' && !Array.isArray(condition)) {
        // Handle operators like lte, gte, in
        if ('lte' in condition) {
          const limit = condition.lte;
          if (item[key] > limit) return false;
        }
        if ('gte' in condition) {
          const limit = condition.gte;
          if (item[key] < limit) return false;
        }
      } else {
        if (item[key] !== condition) return false;
      }
    }
    return true;
  });
}

// Mock Table Builders
function createModelMock(store: any[], name: string) {
  return {
    async findUnique(args: any) {
      const matched = filterItems(store, args.where);
      return matched.length > 0 ? { ...matched[0] } : null;
    },
    async findFirst(args: any) {
      const matched = filterItems(store, args.where);
      return matched.length > 0 ? { ...matched[0] } : null;
    },
    async findMany(args: any) {
      let results = filterItems(store, args?.where);
      
      // Handle Sorting
      if (args?.orderBy) {
        const orderKey = Object.keys(args.orderBy)[0];
        const direction = args.orderBy[orderKey] === 'desc' ? -1 : 1;
        results.sort((a, b) => {
          if (a[orderKey] < b[orderKey]) return -1 * direction;
          if (a[orderKey] > b[orderKey]) return 1 * direction;
          return 0;
        });
      }

      // Handle Take limit
      if (args?.take !== undefined) {
        results = results.slice(0, args.take);
      }

      // Mock includes (simple mock matching endpoints)
      return results.map(item => {
        const clone = { ...item };
        if (args?.include) {
          if (args.include.questions && name === 'Quiz') {
            clone.questions = questions.filter(q => q.quizId === item.id);
          }
          if (args.include.tasks && name === 'StudyPlan') {
            clone.tasks = tasks.filter(t => t.planId === item.id);
          }
          if (args.include.messages && name === 'Chat') {
            clone.messages = messages.filter(m => m.chatId === item.id);
            if (args.include.messages.take === 1) {
              clone.messages = clone.messages.slice(-1);
            }
          }
          if (args.include.user && item.userId) {
            const u = users.find(x => x.id === item.userId);
            if (u) clone.user = { name: u.name, role: u.role };
          }
        }
        return clone;
      });
    },
    async create(args: any) {
      const id = args.data.id || crypto.randomUUID();
      const now = new Date();
      const newItem: any = {
        id,
        createdAt: now,
        updatedAt: now,
      };

      // Extract nested fields
      const { questions: nestedQuestions, tasks: nestedTasks, ...plainFields } = args.data;

      // Populate plain fields
      for (const key of Object.keys(plainFields)) {
        newItem[key] = plainFields[key];
      }

      // Default model-specific fields
      if (name === 'User') {
        newItem.role = newItem.role || 'STUDENT';
        newItem.subscription = newItem.subscription || 'FREE';
        newItem.xpPoints = newItem.xpPoints || 0;
        newItem.studyStreak = newItem.studyStreak || 0;
      }
      if (name === 'Flashcard') {
        newItem.interval = newItem.interval || 0;
        newItem.repetition = newItem.repetition || 0;
        newItem.easeFactor = newItem.easeFactor || 2.5;
        newItem.nextReview = newItem.nextReview || now;
      }
      if (name === 'Pdf') {
        newItem.isPublic = newItem.isPublic || false;
        newItem.tags = newItem.tags || [];
        newItem.downloadCount = newItem.downloadCount || 0;
      }

      store.push(newItem);

      // Handle Nested Creates
      if (nestedQuestions?.create && name === 'Quiz') {
        for (const q of nestedQuestions.create) {
          questions.push({
            id: crypto.randomUUID(),
            quizId: id,
            ...q,
          });
        }
      }

      if (nestedTasks?.create && name === 'StudyPlan') {
        for (const t of nestedTasks.create) {
          tasks.push({
            id: crypto.randomUUID(),
            planId: id,
            ...t,
          });
        }
      }

      // Return item with standard includes
      const returnedItem = { ...newItem };
      if (name === 'Quiz') {
        returnedItem.questions = questions.filter(q => q.quizId === id);
      }
      if (name === 'StudyPlan') {
        returnedItem.tasks = tasks.filter(t => t.planId === id);
      }
      return returnedItem;
    },
    async update(args: any) {
      const idx = store.findIndex(item => item.id === args.where.id);
      if (idx === -1) throw new Error(`Record to update not found: ${args.where.id}`);

      const item = store[idx];
      const now = new Date();
      
      for (const key of Object.keys(args.data)) {
        const updateVal = args.data[key];
        if (updateVal && typeof updateVal === 'object' && 'increment' in updateVal) {
          item[key] = (item[key] || 0) + updateVal.increment;
        } else if (updateVal && typeof updateVal === 'object' && 'push' in updateVal) {
          item[key] = item[key] || [];
          item[key].push(updateVal.push);
        } else {
          item[key] = updateVal;
        }
      }

      item.updatedAt = now;
      store[idx] = item;
      return { ...item };
    },
    async count(args: any) {
      const matched = filterItems(store, args?.where);
      return matched.length;
    }
  };
}

export const mockPrisma = {
  user: createModelMock(users, 'User'),
  pdf: createModelMock(pdfs, 'Pdf'),
  documentChunk: createModelMock(documentChunks, 'DocumentChunk'),
  note: createModelMock(notes, 'Note'),
  quiz: createModelMock(quizzes, 'Quiz'),
  question: createModelMock(questions, 'Question'),
  flashcard: createModelMock(flashcards, 'Flashcard'),
  chat: createModelMock(chats, 'Chat'),
  message: createModelMock(messages, 'Message'),
  studyPlan: createModelMock(studyPlans, 'StudyPlan'),
  task: createModelMock(tasks, 'Task'),
  category: createModelMock(categories, 'Category'),
  branch: createModelMock(branches, 'Branch'),
  subject: createModelMock(subjects, 'Subject'),
  bookmark: createModelMock(bookmarks, 'Bookmark'),
  download: createModelMock(downloads, 'Download'),

  async $transaction(promises: any[]) {
    // Sequentially resolve all promises/actions in transaction
    const results = [];
    for (const p of promises) {
      results.push(await p);
    }
    return results;
  },

  async $executeRaw(strings: TemplateStringsArray, ...values: any[]) {
    // INSERT INTO "DocumentChunk" ("id", "pdfId", "content", "embedding")
    // Values: [pdfId, chunk, vectorString]
    const pdfId = values[0];
    const content = values[1];
    const vectorString = values[2]; // e.g. "[0.1, 0.2, ...]"

    const embedding = JSON.parse(vectorString);
    const newChunk = {
      id: crypto.randomUUID(),
      pdfId,
      content,
      embedding,
    };

    documentChunks.push(newChunk);
    return 1;
  },

  async $queryRaw(strings: TemplateStringsArray, ...values: any[]) {
    // SELECT content FROM "DocumentChunk" ...
    // values[0]: vectorString, values[1]: pdfId, values[2]: vectorString
    const vectorString = values[0];
    const pdfId = values[1];
    const queryVector = JSON.parse(vectorString);

    const matchChunks = documentChunks.filter(c => c.pdfId === pdfId);
    const scoredChunks = matchChunks.map(c => {
      const sim = cosineSimilarity(c.embedding, queryVector);
      return {
        content: c.content,
        similarity: sim,
      };
    });

    // Sort by similarity descending
    scoredChunks.sort((a, b) => b.similarity - a.similarity);

    // Return top 3
    return scoredChunks.slice(0, 3);
  }
};
