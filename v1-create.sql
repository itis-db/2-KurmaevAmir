/**
 @author
*/
DROP TABLE IF EXISTS gender;
CREATE TABLE gender
(
    id    SERIAL PRIMARY KEY,
    value VARCHAR(6) UNIQUE
);

DROP TABLE IF EXISTS human;
CREATE TABLE human
(
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(255),
    surname      VARCHAR(255),
    patronymic   VARCHAR(255),
    age          INT2,
    gender_id    INT REFERENCES gender (id),
    email        VARCHAR(255) UNIQUE,
    phone_number VARCHAR(15)
);

DROP TABLE IF EXISTS company;
CREATE TABLE company
(
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(255),
    address VARCHAR(255),
    INN     VARCHAR(12),
    BIC     VARCHAR(9),
    KPP     VARCHAR(100)
);

DROP TABLE IF EXISTS client;
CREATE TABLE client
(
    id              SERIAL PRIMARY KEY,
    company_id    INT REFERENCES company (id),
    start_DATE_work DATE,
    method_address  VARCHAR(255) UNIQUE,
    user_id         INT REFERENCES human (id)
);

DROP TABLE IF EXISTS manager;
CREATE TABLE manager
(
    id                   SERIAL PRIMARY KEY,
    administrator_access BOOLEAN,
    password             VARCHAR(255),
    login                VARCHAR(255) UNIQUE
);

DROP TABLE IF EXISTS managerclient;
CREATE TABLE managerClient
(
    manager_id INT REFERENCES manager (id),
    client_id  INT REFERENCES client (id),
    PRIMARY KEY (manager_id, client_id)
)
