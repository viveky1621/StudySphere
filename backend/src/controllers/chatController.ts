import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { prisma } from '../database/prisma';

export const createChat = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { title } = req.body;
    
    if (!req.user || !req.user.id) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const chat = await prisma.chat.create({
      data: {
        title: title || 'New Conversation',
        userId: req.user.id,
      },
    });

    return res.status(201).json({ success: true, chat });
  } catch (error) {
    next(error);
  }
};

export const getChats = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user || !req.user.id) return res.status(401).json({ success: false, error: 'Unauthorized' });

    const chats = await prisma.chat.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' },
      include: {
        messages: {
          take: 1,
          orderBy: { createdAt: 'desc' }
        }
      }
    });

    return res.status(200).json({ success: true, chats });
  } catch (error) {
    next(error);
  }
};

export const sendMessage = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { chatId } = req.params;
    const { content, pdfId } = req.body;

    if (!req.user || !req.user.id) return res.status(401).json({ success: false, error: 'Unauthorized' });

    // 1. Save user's message
    await prisma.message.create({
      data: {
        chatId,
        role: 'user',
        content,
      }
    });

    let contextText = '';

    // 2. Perform RAG (Retrieval-Augmented Generation) if a PDF context is provided
    if (pdfId) {
      // Mock embedding the user's query
      const queryEmbedding = Array(1536).fill(0).map(() => Math.random());
      const vectorString = `[${queryEmbedding.join(',')}]`;

      // Perform Cosine Similarity Search (<=> operator in pgvector)
      // Retrieves top 3 most relevant chunks
      const relevantChunks: any[] = await prisma.$queryRaw`
        SELECT content, 1 - (embedding <=> ${vectorString}::vector) as similarity
        FROM "DocumentChunk"
        WHERE "pdfId" = ${pdfId}
        ORDER BY embedding <=> ${vectorString}::vector
        LIMIT 3
      `;

      if (relevantChunks && relevantChunks.length > 0) {
        contextText = relevantChunks.map(c => c.content).join('\n\n');
      }
    }

    // 3. Construct LLM Prompt
    const prompt = `
      You are an expert AI Tutor. Use the following context to answer the user's query.
      Context: ${contextText}
      
      User Query: ${content}
    `;

    console.log('[AI Tutor] Generating response using prompt:', prompt);

    // 4. Call OpenAI API (Mocked here)
    const mockAiResponse = `This is a mock AI response based on the PDF context. The actual implementation would send the prompt to OpenAI/Gemini and stream the response back. You asked: "${content}".`;

    // 5. Save AI's response
    const assistantMessage = await prisma.message.create({
      data: {
        chatId,
        role: 'assistant',
        content: mockAiResponse,
      }
    });

    return res.status(200).json({
      success: true,
      message: assistantMessage,
    });
  } catch (error) {
    next(error);
  }
};
