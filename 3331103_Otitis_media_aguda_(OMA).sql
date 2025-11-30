WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        'f96bf9b0-177e-4435-a6a7-e86f577464e1',
        'cfa9d0dd-119e-4cdd-8d1a-7caff722ab06',
        '391aee5b-67d7-4d40-8b01-0d5739cb0bbd',
        '054c172f-5b66-4360-8c8d-9b53f70609ce'
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