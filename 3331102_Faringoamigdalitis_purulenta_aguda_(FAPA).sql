WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        '2cc4a9b5-7b1c-4fbc-ba67-8a5c5584162a',
        '319df75b-920a-401c-a799-8075bbcccced',
        '6abc8da0-3f8e-4f36-933c-eecf79c07f6e',
        '4fc6f7e0-9134-4e12-a974-646675edc436',
        'edb311d0-ee19-410e-ab5d-fa0a5da7f81b'
    )
)

SELECT
    COUNT(*) AS casos_fapa_aguda
FROM encounter_diagnosis ed
JOIN cie10_concepts c ON c.concept_id = ed.diagnosis_coded
JOIN person p ON p.person_id = ed.patient_id
WHERE
    -- Menores de 5 años
    TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) < 5
    -- Solo año actual
    AND YEAR(ed.date_created) = YEAR(CURDATE());