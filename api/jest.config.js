/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: __dirname,
  testEnvironment: 'node',
  transform: {
    '^.+\\.(t|j)s$': 'ts-jest',
  },
  testMatch: [
    '<rootDir>/src/**/*.spec.ts',
    '<rootDir>/test/**/*.e2e-spec.ts',
    '<rootDir>/tests/**/*.spec.ts',
  ],
  collectCoverageFrom: [
    '**/*.(t|j)s',
    '!**/main.ts',
    '!**/*.module.ts',
    '!**/*.e2e-spec.ts',
  ],
  coverageDirectory: '../coverage',
  moduleNameMapper: {
    '^\\.\\.\\/\\.\\.\\/api\\/src\\/(.*)$': '<rootDir>/src/$1',
  },
};
