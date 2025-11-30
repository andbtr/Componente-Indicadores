WITH cie10_concepts AS (
    SELECT DISTINCT concept_id
    FROM concept
    WHERE uuid IN (
        '2a043692-05a1-408a-b68f-2f4020321343',
        'a750e8cd-d814-4314-ba61-4623bf7b69a5',
        '20b7a0d6-99e8-46b6-9732-c25663600413',
        '43cb6995-1221-4e36-a93f-0e9b75e948b2',
        'cb82f587-00fa-4446-a12b-da358b9f6ddc',
        '2732d6b2-e7c3-4c9b-a138-78d112109416',
        'e6304721-9c47-4561-8514-b7a86c981887',
        'e7d9fe27-38a9-4752-b0cc-229e9d744919',
        'e3e43314-a199-4447-8dda-f95d1e3a2c3f',
        '90cbd27f-bfb3-492b-a7ef-a218c2d75f17',
        '70f37bcf-fad4-4afc-91b2-c444bb2989ae',
        '6664abab-d8ad-474f-b197-604324c96078',
        'fa6802a5-78b5-46e6-8974-ebcbf33225ae',
        'b8115646-0172-48d1-a9a6-84a5061e6ddd',
        '97b2618b-4546-42f3-90f0-1819fda9d90d',
        'de301bf5-b82b-45b7-892b-48870923e959',
        'f4fa71ee-b05f-44e2-9161-ca58996095d2',
        'e8205428-e661-4a99-b3ae-9601ba389568'
    )
)

SELECT
    COUNT(*) AS casos_parasitosis
FROM encounter_diagnosis ed
JOIN cie10_concepts c
    ON c.concept_id = ed.diagnosis_coded
JOIN person p
    ON p.person_id = ed.patient_id
WHERE
    -- Edad >= 1 año
    TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) >= 1
    -- Edad < 5 años
    AND TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) < 5
    -- Solo año actual
    AND YEAR(ed.date_created) = YEAR(CURDATE());
