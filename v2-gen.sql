/**
  @author
 */
WITH cte AS (SELECT 'Male' AS value
             UNION ALL
             SELECT 'Female')
INSERT
INTO gender(value)
SELECT value
FROM cte;

WITH RECURSIVE cte AS (SELECT 1 AS i
                       UNION ALL
                       SELECT i + 1
                       FROM cte
                       WHERE i < 100)
INSERT
INTO company (name, address, inn, bic, kpp)
SELECT concat_ws(' ', 'Компания', upper(substring(md5(random()::text), 1, 5))),
       concat_ws(', ',
                 'ул.' || (random() * 100)::int,
                 'д.' || (random() * 50)::int,
                 'г.' || (random() * 1000)::text
       ),
       lpad((i + 100000000000)::text, 12, '0'),
       lpad((i + 100000000)::text, 9, '0'),
       lpad(i::text, 9, '0')
FROM cte;

-- WITH RECURSIVE cte AS (
--     SELECT 1 AS i
--     UNION ALL
--     SELECT i + 1 FROM cte WHERE i < 200
-- )
-- INSERT INTO human(name, surname, patronymic, age, gender_id, email, phone_number)
-- SELECT
--     initcap(substring(md5(random()::text), 1, 7)),
--     initcap(substring(md5(random()::text), 1, 10)),
--     initcap(substring(md5(random()::text), 1, 12)),
--     (random() * 80 + 18)::int,
--     (SELECT id FROM gender ORDER BY random() LIMIT 1),
--     concat_ws('@', substring(md5(random()::text), 1, 8), 'example.com'),
--     concat_ws('', '+7', lpad((random() * 1000000000)::int::text, 10, '0'))
-- FROM cte;

DO $$
    DECLARE
        i INT := 1;
        random_gender INT;
    BEGIN
        WHILE i < 200 LOOP
            SELECT id INTO random_gender
            FROM gender
            ORDER BY random()
            LIMIT 1;

            INSERT INTO human(name, surname, patronymic, age, gender_id, email, phone_number)
            SELECT
                initcap(substring(md5(random()::text), 1, 7)),
                initcap(substring(md5(random()::text), 1, 10)),
                initcap(substring(md5(random()::text), 1, 12)),
                (random() * 80 + 18)::int,
                random_gender,
                concat_ws('@', substring(md5(random()::text), 1, 8), 'example.com'),
                concat_ws('', '+7', lpad((random() * 1000000000)::int::text, 10, '0'));
            i := i + 1;
        END LOOP;
END $$;



WITH RECURSIVE cte AS (SELECT 1 AS i
                       UNION ALL
                       SELECT i + 1
                       FROM cte
                       WHERE i < 50)
INSERT
INTO manager(administrator_access, pASsword, login)
SELECT mod(i, 2) = 0,
       md5(random()::text),
       concat_ws('user', substring(md5(random()::text), 1, 6))
FROM cte;

-- WITH RECURSIVE
--     cte AS (SELECT 1 AS i
--             UNION ALL
--             SELECT i + 1
--             FROM cte
--             WHERE i < 150),
--     inserted_client AS (
--         INSERT INTO client (company_id, start_date_work, method_address, user_id)
--             SELECT (SELECT id FROM company ORDER BY random() LIMIT 1),
--                    NOW() - (mod(i, 100) * interval '1 day'),
--                    'Method address: ' || i,
--                    (SELECT id FROM human ORDER BY random() LIMIT 1)
--             FROM cte
--             RETURNING id AS client_id)
-- INSERT
-- INTO managerclient(manager_id, client_id)
-- SELECT (SELECT id FROM manager ORDER BY random() LIMIT 1),
--        client_id
-- FROM inserted_client;

DO $$
    DECLARE
        i INT := 1;
        random_company_id INT;
        random_user_id INT;
    BEGIN
        WHILE i <= 150 LOOP
                SELECT id INTO random_company_id
                FROM company
                ORDER BY random()
                LIMIT 1;

                SELECT id INTO random_user_id
                FROM human
                ORDER BY random()
                LIMIT 1;

                INSERT INTO client(company_id, start_date_work, method_address, user_id)
                SELECT random_company_id,
                       NOW() - (mod(i, 100) * interval '1 day'),
                       'Method address: ' || gen_random_uuid(),
                       random_user_id;
                i := i + 1;
            END LOOP;
    END $$;

-- WITH RECURSIVE cte AS (
--     SELECT 1 AS i
--     UNION ALL
--     SELECT i + 1
--     FROM cte
--     WHERE i < 150)
-- INSERT INTO client(company_id, start_date_work, method_address, user_id)
-- SELECT (SELECT id FROM company ORDER BY random() LIMIT 1),
--        NOW() - (mod(i, 100) * interval '1 day'),
--        'Method address: ' || i,
--        (SELECT id FROM human ORDER BY random() LIMIT 1)
-- FROM cte;

with managerclient_cte AS (
    SELECT m.id AS manager_id, c.id AS client_id
    FROM manager AS m
    CROSS JOIN client AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM managerclient AS mc
        WHERE mc.manager_id = m.id AND mc.client_id = c.id
    )
)
INSERT INTO managerclient(manager_id, client_id)
SELECT manager_id, client_id FROM managerclient_cte;