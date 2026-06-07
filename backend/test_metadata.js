const fetch = require('node-fetch');
const BASE_URL = 'http://localhost:3000/api';

async function run() {
  console.log('Testing Metadata Routes...');
  // 1. Get token
  const res = await fetch(`${BASE_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name: 'Admin', email: `admin${Date.now()}@example.com`, password: 'password123' })
  });
  const data = await res.json();
  const token = data.token;
  
  if (!token) {
    console.error('No token received');
    return;
  }

  // 2. Fetch Categories
  const catRes = await fetch(`${BASE_URL}/metadata/categories`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  const catData = await catRes.json();
  console.log('Categories:', catData);
  
  // 3. Since user role is STUDENT by default, creating a category should fail if we require ADMIN.
  // Actually, wait, let's just test if the endpoints exist.
  console.log('Test complete.');
}
run();
