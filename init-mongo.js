// MongoDB initialization script for FEPA microservices

// Switch to admin database
db = db.getSiblingDB('admin');

// Authenticate
db.auth('fepa', 'fepa123');

// Create databases for each microservice
print('Creating MongoDB databases...');

// Auth Service Database
db = db.getSiblingDB('fepa_auth');
db.createCollection('users');
db.createCollection('refresh_tokens');
print('✅ fepa_auth database created');

// Notification Service Database
db = db.getSiblingDB('fepa_notification');
db.createCollection('notifications');
print('✅ fepa_notification database created');

// Subscription Service Database
db = db.getSiblingDB('fepa_subscription');
db.createCollection('plans');
db.createCollection('subscriptions');
print('✅ fepa_subscription database created');

print('✅ All MongoDB databases created successfully!');
