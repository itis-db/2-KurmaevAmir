/**
  @author
 */
BEGIN;
--changing relationship between human and gender
ALTER TABLE human DROP CONSTRAINT human_gender_id_fkey;
ALTER TABLE gender DROP CONSTRAINT gender_pkey;

ALTER TABLE gender ADD PRIMARY KEY (value);
ALTER TABLE human ALTER COLUMN gender_id TYPE varchar(6) USING (gender_id::varchar);
ALTER TABLE human RENAME COLUMN gender_id TO gender_value;

UPDATE human
SET gender_value = g.value
FROM gender AS g
WHERE g.id = gender_value::int;
ALTER TABLE gender DROP COLUMN id;

ALTER TABLE human ADD CONSTRAINT human_gender_value_fkey FOREIGN KEY (gender_value) REFERENCES gender(value);

--changing relationships between company and client
ALTER TABLE client DROP CONSTRAINT client_company_id_fkey;
ALTER TABLE company DROP CONSTRAINT company_pkey;

ALTER TABLE company ADD PRIMARY KEY (inn);
ALTER TABLE client ALTER COLUMN company_id TYPE varchar(12) USING (company_id::varchar);
ALTER TABLE client RENAME COLUMN company_id TO company_inn;

UPDATE client
SET company_inn = com.inn
FROM company AS com
WHERE com.id = company_inn::int;
ALTER TABLE company DROP COLUMN id;

ALTER TABLE client ADD CONSTRAINT client_company_inn_fkey FOREIGN KEY (company_inn) REFERENCES company(inn);

--changing relationship between client and human
ALTER TABLE client DROP CONSTRAINT client_user_id_fkey;
ALTER TABLE human DROP CONSTRAINT parent;
ALTER TABLE human DROP CONSTRAINT human_pkey;

ALTER TABLE human ADD PRIMARY KEY (email);
ALTER TABLE human ALTER COLUMN parent TYPE VARCHAR(255) USING (parent::varchar);
ALTER TABLE client ALTER COLUMN user_id TYPE varchar(255) USING (user_id::varchar);
ALTER TABLE client RENAME COLUMN user_id TO user_email;

UPDATE client
SET user_email = h.email
FROM human AS h
WHERE h.id = user_email::int;

UPDATE human
SET parent = email
WHERE id = parent::int;
ALTER TABLE human DROP COLUMN id;

ALTER TABLE client ADD CONSTRAINT client_user_email_fkey FOREIGN KEY (user_email) REFERENCES human(email);
ALTER TABLE human ADD CONSTRAINT parent FOREIGN KEY (parent) REFERENCES human(email);

--changing relationship between manager and managerclient
ALTER TABLE managerclient DROP CONSTRAINT managerclient_manager_id_fkey;
ALTER TABLE manager DROP CONSTRAINT manager_pkey;

ALTER TABLE manager ADD PRIMARY KEY (login);
ALTER TABLE managerclient ALTER COLUMN manager_id TYPE VARCHAR(255) USING (manager_id::varchar);
ALTER TABLE managerclient RENAME COLUMN manager_id TO manager_login;

UPDATE managerclient
SET manager_login = m.login
FROM manager AS m
WHERE m.id = manager_login::int;
ALTER TABLE manager DROP COLUMN id;

ALTER TABLE managerclient ADD CONSTRAINT managerclient_manager_login_fkey FOREIGN KEY (manager_login) REFERENCES manager(login);

--changing relationship between client and managerclient
ALTER TABLE managerclient DROP CONSTRAINT managerclient_client_id_fkey;
ALTER TABLE client DROP CONSTRAINT client_pkey;

ALTER TABLE client ADD COLUMN barcode VARCHAR(20) UNIQUE;
WITH barcode_cte AS (
    SELECT c.id, lpad(floor(random() * 1000000000)::text, 9, '0') AS new_barcode
    FROM client AS c
    LEFT JOIN client AS c2 ON c2.barcode = lpad(floor(random() * 1000000000)::text, 9, '0')
    WHERE c.barcode IS NULL
)
UPDATE client AS c
SET barcode = cte.new_barcode
FROM barcode_cte AS cte
WHERE c.id = cte.id
AND NOT EXISTS(SELECT 1 FROM client WHERE c.barcode = cte.new_barcode);

ALTER TABLE client ADD PRIMARY KEY (barcode);
ALTER TABLE managerclient ALTER COLUMN client_id TYPE VARCHAR(20) USING (client_id::varchar);
ALTER TABLE managerclient RENAME COLUMN client_id TO client_barcode;

UPDATE managerclient
SET client_barcode = c.barcode
FROM client AS c
WHERE c.id = client_barcode::int;
ALTER TABLE client DROP COLUMN id;

ALTER TABLE managerclient ADD CONSTRAINT managerclient_client_barcode_fkey FOREIGN KEY (client_barcode) REFERENCES client(barcode);
COMMIT;

--rollback
BEGIN;
--rollback relationship between human and gender
ALTER TABLE human DROP CONSTRAINT human_gender_value_fkey;
ALTER TABLE gender DROP CONSTRAINT gender_pkey;

ALTER TABLE gender ADD COLUMN id SERIAL PRIMARY KEY;

UPDATE human
SET gender_value = g.id::varchar
FROM gender AS g
WHERE g.value = gender_value;

ALTER TABLE human ALTER COLUMN gender_value TYPE int USING(gender_value::int);
ALTER TABLE human RENAME COLUMN gender_value TO gender_id;
ALTER TABLE human ADD CONSTRAINT human_gender_id_fkey FOREIGN KEY (gender_id) REFERENCES gender(id);

--rollback relationships between company and client
ALTER TABLE client DROP CONSTRAINT client_company_inn_fkey;
ALTER TABLE company DROP CONSTRAINT company_pkey;

ALTER TABLE company ADD COLUMN id SERIAL PRIMARY KEY;

UPDATE client
SET company_inn = com.id::varchar
FROM company AS com
WHERE com.inn = client.company_inn;

ALTER TABLE client ALTER COLUMN company_inn TYPE int USING(company_inn::int);
ALTER TABLE client RENAME COLUMN company_inn TO company_id;
ALTER TABLE client ADD CONSTRAINT client_company_id_fkey FOREIGN KEY (company_id) REFERENCES company(id);

--rollback relationships between human and human, client
ALTER TABLE human DROP CONSTRAINT parent;
ALTER TABLE client DROP CONSTRAINT client_user_email_fkey;
ALTER TABLE human DROP CONSTRAINT human_pkey;

ALTER TABLE human ADD COLUMN id SERIAL PRIMARY KEY;

UPDATE human
SET parent = id::varchar
WHERE parent = email;

UPDATE client
SET user_email = h.id::varchar
FROM human AS h
WHERE h.email = user_email;

ALTER TABLE human ALTER COLUMN parent TYPE int USING(parent::int);
ALTER TABLE client ALTER COLUMN user_email TYPE int USING(user_email::int);
ALTER TABLE client RENAME COLUMN user_email TO user_id;
ALTER TABLE human ADD CONSTRAINT parent FOREIGN KEY (parent) REFERENCES human(id);
ALTER TABLE client ADD CONSTRAINT client_user_id_fkey FOREIGN KEY (user_id) REFERENCES human(id);

--rollback relationships between manager and managerclient
ALTER TABLE managerclient DROP CONSTRAINT managerclient_manager_login_fkey;
ALTER TABLE manager DROP CONSTRAINT manager_pkey;

ALTER TABLE manager ADD COLUMN id SERIAL PRIMARY KEY;

UPDATE managerclient
SET manager_login = m.id
FROM manager AS m
WHERE m.login = manager_login;

ALTER TABLE managerclient ALTER COLUMN manager_login TYPE int USING(managerclient.manager_login::int);
ALTER TABLE managerclient RENAME COLUMN manager_login TO manager_id;
ALTER TABLE managerclient ADD CONSTRAINT managerclient_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES manager(id);

--rollback relationships between client and managerclient
ALTER TABLE managerclient DROP CONSTRAINT managerclient_client_barcode_fkey;
ALTER TABLE client DROP CONSTRAINT client_pkey;

ALTER TABLE client ADD COLUMN id SERIAL PRIMARY KEY;

UPDATE managerclient
SET client_barcode = c.id
FROM client AS c
WHERE c.barcode = client_barcode;

ALTER TABLE managerclient ALTER COLUMN client_barcode TYPE int USING(managerclient.client_barcode::int);
ALTER TABLE managerclient RENAME COLUMN client_barcode TO client_id;
ALTER TABLE managerclient ADD CONSTRAINT managerclient_client_id_fkey FOREIGN KEY (client_id) REFERENCES client(id);

ALTER TABLE client DROP COLUMN barcode;
COMMIT;