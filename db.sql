CREATE DATABASE vulnerable_db;

USE vulnerable_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL
);

INSERT INTO users (username, password) VALUES ('admin', 'admin123');
INSERT INTO users (username, password) VALUES ('user1', 'user123');
INSERT INTO users (username, password) VALUES ('user2', 'user123');
INSERT INTO users (username, password) VALUES ('user3', 'user123');
