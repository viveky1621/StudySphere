import { Worker, Job } from 'bullmq';
import { processPdfPipeline } from './ai/ragPipeline';
import dotenv from 'dotenv';

dotenv.config();

const redisConnection = {
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379', 10),
  password: process.env.REDIS_PASSWORD || undefined,
  tls: process.env.REDIS_TLS === 'true' ? {} : undefined,
};

console.log('🚀 Starting BullMQ RAG Worker...');

const worker = new Worker('rag-pipeline', async (job: Job) => {
  const { pdfId, fileBufferArray } = job.data;
  
  // Convert array back to Buffer (JSON serialization turns Buffer to an object `{ type: "Buffer", data: [...] }`)
  const buffer = Buffer.from(fileBufferArray.data || fileBufferArray);
  
  await processPdfPipeline(pdfId, buffer);
}, {
  connection: redisConnection,
  concurrency: 5,
});

worker.on('completed', (job) => {
  console.log(`✅ Job completed successfully: ${job.id}`);
});

worker.on('failed', (job, err) => {
  console.error(`❌ Job failed: ${job?.id} with error: ${err.message}`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM signal received: closing worker');
  await worker.close();
  console.log('Worker closed');
});
