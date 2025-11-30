WITH cred AS (
    SELECT
        ed.patient_id,
        ed.diagnosis_coded,
        ed.date_created
    FROM encounter_diagnosis ed
    WHERE ed.diagnosis_coded IN (
        (SELECT concept_id FROM concept WHERE uuid = 'f61fe526-773a-43ea-907b-465a028db69d'), -- CRED <1 año
        (SELECT concept_id FROM concept WHERE uuid = '534dd14a-f8b5-41ad-a660-0bfcab9132a7')  -- CRED 1–4 años
    )
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

edad AS (
    SELECT
        c.patient_id,
        c.date_created,
        TIMESTAMPDIFF(MONTH, p.birthdate, c.date_created) AS edad_meses
    FROM cred c
    JOIN person p ON p.person_id = c.patient_id
    WHERE TIMESTAMPDIFF(MONTH, p.birthdate, c.date_created) BETWEEN 1 AND 35
),

conteos AS (
    SELECT
        patient_id,
        COUNT(*) AS total_controles,
        MIN(edad_meses) AS edad_min,
        MAX(edad_meses) AS edad_max
    FROM edad
    GROUP BY patient_id
),

expected AS (
    SELECT
        patient_id,
        total_controles,
        edad_min,
        edad_max,

        -- Controles esperados según edad
        CASE
            WHEN edad_min < 12 THEN edad_max - edad_min + 1
            WHEN edad_min < 24 THEN CEIL((edad_max - 12 + 1) / 2)
            WHEN edad_min < 36 THEN CEIL((edad_max - 24 + 1) / 3)
        END AS controles_esperados
    FROM conteos
)

SELECT
    COUNT(*) AS ninos_con_cred_completo
FROM expected
WHERE total_controles >= controles_esperados;
