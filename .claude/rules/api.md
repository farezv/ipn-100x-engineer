---
paths: app/api/**/*.ts
---

# API Route Standards

- All API routes must validate query parameters before use
- Return proper HTTP status codes (400 for bad request, 404 for not found, 500 for server error)
- Include descriptive error messages in response body
- Use TypeScript interfaces for request/response types
- Log errors to console in development mode
