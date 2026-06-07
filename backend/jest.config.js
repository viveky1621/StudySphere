/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.test.ts'],
  verbose: true,
  clearMocks: true,
  moduleFileExtensions: ['ts', 'js', 'json', 'node'],
  forceExit: true, // Needed if Express server doesn't close cleanly in some tests
};
