WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        'a593d173-0521-45c6-9b33-4b68682a5172',
        'f895ef4f-9b7f-4a0a-85d9-809b8b624b36',
        '9f6c9fb8-9e89-40e7-8bec-71ab4ed609e1'
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