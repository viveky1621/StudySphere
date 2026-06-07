const BASE_URL = 'http://localhost:3000/api';

let token = '';
let pdfId = '';
let chatId = '';

async function runTests() {
  console.log('--- Starting API Integration Tests ---');
  
  // 1. Auth: Register
  try {
    const res = await fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: 'Tester', email: `test${Date.now()}@example.com`, password: 'password123' })
    });
    const data = await res.json();
    if (data.success && data.token) {
      console.log('✅ Auth: Register successful');
      token = data.token;
    } else {
      console.error('❌ Auth: Register failed', data);
    }
  } catch(e) {
    console.error('❌ Auth: Register error', e.message);
  }

  // 2. PDFs: Generate Dummy PDF upload simulation
  // The actual upload uses multipart/form-data. We can skip the actual file upload and just test retrieval if mock DB doesn't have it.
  // Actually, let's test if we can get PDFs (empty array is fine)
  try {
    const res = await fetch(`${BASE_URL}/pdfs`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const data = await res.json();
    if (data.success) {
      console.log('✅ PDFs: Get PDFs successful. Count:', (data.data || data.pdfs || data.chat || data.flashcards || data.quizzes || data.studyPlans).length);
    } else {
      console.error('❌ PDFs: Get PDFs failed', data);
    }
  } catch(e) {
    console.error('❌ PDFs: Get PDFs error', e.message);
  }

  // 3. Chat: Create Chat
  try {
    const res = await fetch(`${BASE_URL}/chats`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ pdfId: 'dummy-pdf-id', title: 'Test Chat' })
    });
    const data = await res.json();
    if (data.success && (data.data || data.pdfs || data.chat || data.flashcards || data.quizzes || data.studyPlans)) {
      console.log('✅ Chat: Create Chat successful');
      chatId = (data.data || data.pdfs || data.chat || data.flashcards || data.quizzes || data.studyPlans).id;
    } else {
      console.error('❌ Chat: Create Chat failed', data);
    }
  } catch(e) {
    console.error('❌ Chat: Create Chat error', e.message);
  }

  // 4. Chat: Send Message
  if (chatId) {
    try {
      const res = await fetch(`${BASE_URL}/chats/${chatId}/messages`, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ content: 'Hello AI' })
      });
      const data = await res.json();
      if (data.success) {
        console.log('✅ Chat: Send Message successful');
      } else {
        console.error('❌ Chat: Send Message failed', data);
      }
    } catch(e) {
      console.error('❌ Chat: Send Message error', e.message);
    }
  }

  // 5. Flashcards: Generate
  try {
    const res = await fetch(`${BASE_URL}/flashcards/generate`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ pdfId: 'dummy-pdf-id', pageRange: '1-5', count: 2 })
    });
    const data = await res.json();
    if (data.success) {
      console.log('✅ Flashcards: Generate successful. Count:', (data.data || data.pdfs || data.chat || data.flashcards || data.quizzes || data.studyPlans).length);
    } else {
      console.error('❌ Flashcards: Generate failed', data);
    }
  } catch(e) {
    console.error('❌ Flashcards: Generate error', e.message);
  }

  // 6. Quizzes: Generate
  try {
    const res = await fetch(`${BASE_URL}/quizzes/generate`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ pdfId: 'dummy-pdf-id', difficulty: 'MEDIUM', count: 3 })
    });
    const data = await res.json();
    if (data.success) {
      console.log('✅ Quizzes: Generate successful');
    } else {
      console.error('❌ Quizzes: Generate failed', data);
    }
  } catch(e) {
    console.error('❌ Quizzes: Generate error', e.message);
  }

  // 7. Study Plans: Generate One Day Batting
  try {
    const res = await fetch(`${BASE_URL}/study-plans/one-day-batting`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ subject: 'Physics', topics: ['Kinematics', 'Dynamics'], examDate: new Date(Date.now() + 86400000).toISOString() })
    });
    const data = await res.json();
    if (data.success) {
      console.log('✅ Study Plans: Generate successful');
    } else {
      console.error('❌ Study Plans: Generate failed', data);
    }
  } catch(e) {
    console.error('❌ Study Plans: Generate error', e.message);
  }

  console.log('--- API Tests Complete ---');
}

runTests();
