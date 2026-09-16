# Postman Collection - API Health Aggregator

## Files

- `api-health-aggregator.postman_collection.json` - Main collection with all endpoints
- `api-health-aggregator.postman_environment.json` - Environment variables

## Setup

1. Import both files into Postman
2. Select the **API Health Aggregator - Local** environment
3. Ensure the Ballerina service is running on `localhost:9090`

## Variables

| Variable   | Description             | Auto-set                 |
| ---------- | ----------------------- | ------------------------ |
| `baseUrl`  | `http://localhost:9090` | Pre-configured           |
| `jwtToken` | JWT auth token          | Set after login          |
| `userId`   | Current user UUID       | Set after register/login |
| `apiId`    | Current API UUID        | Set after create         |

## Test Flow

Run requests in order:

1. **Root > Health Check** - Verify service is running
2. **User Management > Register User** - Create test user
3. **User Management > Login User** - Get JWT token (auto-saves to `jwtToken`)
4. **API Management > Create API** - Create test API (auto-saves to `apiId`)
5. **API Management > Get All APIs** - List all APIs
6. **API Management > Get API by ID** - Fetch specific API
7. **API Management > Update API** - Modify API details
8. **API Management > Delete API** - Remove API
9. **User Management > Delete User** - Clean up test user

## Auth

All `/api/*` endpoints require JWT Bearer token. The collection is configured with bearer auth using `{{jwtToken}}` variable. Login automatically populates this variable.

## Auto-populated Variables

Test scripts in each request automatically save:

- `userId` from Register/Login responses
- `jwtToken` from Login response
- `apiId` from Create API response
