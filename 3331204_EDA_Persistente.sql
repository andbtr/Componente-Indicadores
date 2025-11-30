WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        'e7a1bb61-4711-49cc-9ee7-10fae1182cac'
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