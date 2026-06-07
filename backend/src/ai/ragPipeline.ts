import { prisma } from '../database/prisma';

/**
 * Mocks the OpenAI Text Embedding API
 * In production, this would call `https://api.openai.com/v1/embeddings`
 */
async function generateEmbeddings(text: string): Promise<number[]> {
  // Returns a mock 1536-dimensional vector for `text-embedding-3-small`
  return Array(1536).fill(0).map(() => Math.random());
}

/**
 * Very basic token chunker.
 * In production, use LangChain's RecursiveCharacterTextSplitter
 */
function chunkText(text: string, chunkSize: number = 1000): string[] {
  const chunks: string[] = [];
  let index = 0;
  while (index < text.length) {
    chunks.push(text.slice(index, index + chunkSize));
    index += chunkSize;
  }
  return chunks;
}

export async function processPdfPipeline(pdfId: string, fileBuffer: Buffer) {
  console.log(`[RAG Pipeline] Starting processing for PDF: ${pdfId}`);
  
  try {
    // 1. Extract Text from PDF Buffer
    // In production, use `pdf-parse` or AWS Textract
    const extractedText = `Mock extracted text from PDF... This would be the actual text parsed from the binary buffer of the uploaded file. It contains important educational context that needs to be chunked and embedded for the AI Tutor.`;
    
    // 2. Chunk the text
    const chunks = chunkText(extractedText, 500);
    console.log(`[RAG Pipeline] Extracted and split into ${chunks.length} chunks`);

    // 3. Generate embeddings and store in PostgreSQL (pgvector)
    for (const chunk of chunks) {
      const embedding = await generateEmbeddings(chunk);
      
      // pgvector requires raw SQL for inserting vector types via Prisma
      // formatted as '[0.1, 0.2, ...]'
      const vectorString = `[${embedding.join(',')}]`;
      
      await prisma.$executeRaw`
        INSERT INTO "DocumentChunk" ("id", "pdfId", "content", "embedding")
        VALUES (gen_random_uuid(), ${pdfId}, ${chunk}, ${vectorString}::vector)
      `;
    }

    // 4. Update the PDF record to show processing is complete
    await prisma.pdf.update({
      where: { id: pdfId },
      data: {
        summary: 'Automatically generated summary of the document...',
        tags: { push: 'processed' }
      }
    });

    console.log(`[RAG Pipeline] Successfully processed PDF: ${pdfId}`);
  } catch (error) {
    console.error(`[RAG Pipeline] Error processing PDF ${pdfId}:`, error);
    
    await prisma.pdf.update({
      where: { id: pdfId },
      data: { summary: 'Error processing document.' }
    });
  }
}
