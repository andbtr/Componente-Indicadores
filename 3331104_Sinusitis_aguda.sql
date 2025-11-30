WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        '6f48eaa6-0815-4073-9225-eb017bc2edd8',
        'edf39746-93f1-4404-8473-5a33561b3798',
        'aee3d4c1-cc61-4da1-af0c-b8c9fefd1757',
        'a2e28752-3f63-4d8e-ae0d-9e0093182620',
        'e0ad9c7f-2c1b-4d07-a1c3-4092a73723df',
        '53a593e5-9c8c-4c7b-af33-9ff1cdb2707d'
    )
)

SELECT
    COUNT(*) AS casos_indicador
FROM encounter_diagnosis ed
JOIN cie10_concepts c ON c.concept_id = ed.diagnosis_coded
JOIN person p ON p.person_id = ed.patient_id
WHERE
    -- Menores de 5 años
    TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) < 5
    -- Solo año actual
    AND YEAR(ed.date_created) = YEAR(CURDATE());