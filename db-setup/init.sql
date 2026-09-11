CREATE TABLE api_health_aggregator.api (
    -- CHAR means fixed-length characters
    api_id CHAR(36) PRIMARY KEY,
    -- VARCHAR means variable-length characters
    api_name VARCHAR(100) NOT NULL,
    api_url VARCHAR(100) NOT NULL,
    user_id CHAR(36) NOT NULL REFERENCES user(user_id) ON DELETE CASCADE,
    created_time DATETIME
);

CREATE TABLE api_health_aggregator.user (
    user_id CHAR(36) PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_time DATETIME
);

INSERT INTO api_health_aggregator.app_user
    (user_id, user_name, email, phone_number, password, created_time)
VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Yasas', 'yasas@example.com', '+94771234567', 'password123', '2026-09-01 09:00:00'),
    ('6ba7b810-9dad-41d1-80b4-00c04fd430c9', 'Kamal', 'kamal@example.com', '+94772345678', 'password456', '2026-09-02 10:15:00'),
    ('7c9e6679-7425-40de-944b-e07fc1f90ae8', 'Nimal', 'nimal@example.com', '+94773456789', 'password789', '2026-09-03 11:30:00'),
    ('8f14e45f-ea2a-41d4-9b1b-2c8f1d6a1235', 'Amal',  'amal@example.com',  '+94774567890', 'password012', '2026-09-04 12:45:00'),
    ('9a3d5f72-1b6c-4e89-8d23-7f4a9c0b5679', 'Saman', 'saman@example.com', '+94775678901', 'password345', '2026-09-05 14:00:00');

INSERT INTO api_health_aggregator.api
    (api_id, api_name, api_url, user_id, created_time)
VALUES
    ('550e8400-e29b-41d4-a716-446655440000', 'Payment API',        'https://api.example.com/payment',       '550e8400-e29b-41d4-a716-446655440001', '2026-09-01 09:05:00'),
    ('6ba7b810-9dad-41d1-80b4-00c04fd430c8', 'User API',           'https://api.example.com/users',         '6ba7b810-9dad-41d1-80b4-00c04fd430c9', '2026-09-02 10:20:00'),
    ('7c9e6679-7425-40de-944b-e07fc1f90ae7', 'Authentication API', 'https://api.example.com/auth',          '7c9e6679-7425-40de-944b-e07fc1f90ae8', '2026-09-03 11:35:00'),
    ('8f14e45f-ea2a-41d4-9b1b-2c8f1d6a1234', 'Notification API',   'https://api.example.com/notifications', '8f14e45f-ea2a-41d4-9b1b-2c8f1d6a1235', '2026-09-04 12:50:00'),
    ('9a3d5f72-1b6c-4e89-8d23-7f4a9c0b5678', 'Order API',          'https://api.example.com/orders',        '9a3d5f72-1b6c-4e89-8d23-7f4a9c0b5679', '2026-09-05 14:05:00');