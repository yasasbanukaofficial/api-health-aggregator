#### File Structure

```
api-health-aggregator/
│
├── Ballerina.toml
├── Dependencies.toml
├── Config.toml
├── README.md
│
├── main.bal
├── types.bal
├── errors.bal
├── service.bal
│
├── modules/
│   ├── api/
│   │   ├── api.bal
│   │   ├── types.bal
│   │   ├── repository.bal
│   │   └── tests/
│   │       └── api_test.bal
│   │
│   ├── health/
│   │   ├── health.bal
│   │   ├── types.bal
│   │   ├── repository.bal
│   │   └── tests/
│   │       └── health_test.bal
│   │
│   └── user/
│       ├── user.bal
│       ├── types.bal
│       ├── repository.bal
│       └── tests/
│           └── user_test.bal
│
├── tests/
│   └── service_test.bal
│
└── db-setup/
    └── init.sql
```
