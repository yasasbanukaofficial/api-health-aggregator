CREATE TABLE api_health_aggregator.api (
    -- CHAR means fixed-length characters
    api_id CHAR(36) PRIMARY KEY,
    -- VARCHAR means variable-length characters
    api_name VARCHAR(100) NOT NULL,
    api_url VARCHAR(100) NOT NULL,
    created_time DATE
);

CREATE TABLE api_health_aggregator.users (
    user_id CHAR(36) PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    created_time DATE
);

INSERT INTO api_health_aggregator.api
    (api_id, api_name, api_Url, created_time)
VALUES
    ('550e8400-e29b-41d4-a716-446655440000',
     'Payment API',
     'https://api.example.com/payment',
     '2026-09-01'),

    ('6ba7b810-9dad-41d1-80b4-00c04fd430c8',
     'User API',
     'https://api.example.com/users',
     '2026-09-02'),

    ('7c9e6679-7425-40de-944b-e07fc1f90ae7',
     'Authentication API',
     'https://api.example.com/auth',
     '2026-09-03'),

    ('8f14e45f-ea2a-41d4-9b1b-2c8f1d6a1234',
     'Notification API',
     'https://api.example.com/notifications',
     '2026-09-04'),

    ('9a3d5f72-1b6c-4e89-8d23-7f4a9c0b5678',
     'Order API',
     'https://api.example.com/orders',
     '2026-09-05');


INSERT INTO api_health_aggregator.users
    (user_id, user_name, email, phone_number, created_time)
VALUES
    ('550e8400-e29b-41d4-a716-446655440001',
     'Yasas',
     'yasas@example.com',
     '+94771234567',
     '2026-09-01'),

    ('6ba7b810-9dad-41d1-80b4-00c04fd430c9',
     'Kamal',
     'kamal@example.com',
     '+94772345678',
     '2026-09-02'),

    ('7c9e6679-7425-40de-944b-e07fc1f90ae8',
     'Nimal',
     'nimal@example.com',
     '+94773456789',
     '2026-09-03'),

    ('8f14e45f-ea2a-41d4-9b1b-2c8f1d6a1235',
     'Amal',
     'amal@example.com',
     '+94774567890',
     '2026-09-04'),

    ('9a3d5f72-1b6c-4e89-8d23-7f4a9c0b5679',
     'Saman',
     'saman@example.com',
     '+94775678901',
     '2026-09-05');