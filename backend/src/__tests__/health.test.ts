import request from 'supertest';
import app from '../app';

describe('System Health Check API', () => {
  it('should return 200 OK and status ok on /health', async () => {
    const response = await request(app).get('/health');
    
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('status', 'ok');
    expect(response.body).toHaveProperty('timestamp');
  });

  it('should return 404 for an unknown route', async () => {
    const response = await request(app).get('/api/this-route-does-not-exist');
    
    expect(response.status).toBe(404);
  });
});
