WITH cie10_concepts AS (
    SELECT DISTINCT concept_id
    FROM concept
    WHERE uuid IN (
        '2355a2aa-8c81-43c1-949a-177c6ba9cd6c',
        'c2af07da-d066-4933-a728-616b8217d95a',
        'c219af0e-2aaf-4362-b9e3-847822e2107d',
        'c4b295fa-60b5-461a-8c13-357a0110c74d',
        'ad6cde09-5a79-4762-b1d5-1336050b895a',
        '6aadfc49-b182-4778-9bbc-2d7206794e97',
        '75a9f94d-eb40-47c9-87bf-9c8478a92037',
        'c8849cfa-21d6-482b-999c-3b0d6894310f',
        'f060294d-0b41-44fe-89f2-dcfd64a95c63',
        'c55dc51e-8f07-4fc9-8b7c-edba12995ced',
        '3607dc60-cd52-4d4f-9547-a671b32cfa5f',
        '71d6fdc3-290a-4c1c-b29d-a7f7895ede5e',
        '38f68124-ff17-45c4-91ea-3c24caf8ee53',
        '01fe6119-00ac-40e2-bbf6-f39d806d141b',
        'a5d83e66-32c0-40ce-a63f-ed7e03aa8f90'
    )
)

SELECT
    COUNT(*) AS casos_indicador
FROM encounter_diagnosis ed
JOIN cie10_concepts c
    ON c.concept_id = ed.diagnosis_coded
JOIN person p
    ON p.person_id = ed.patient_id
WHERE
    -- Edad >= 2 meses
    TIMESTAMPDIFF(MONTH, p.birthdate, ed.date_created) >= 2
    -- Edad < 4 años
    AND TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) < 4
    -- Solo año actual
    AND YEAR(ed.date_created) = YEAR(CURDATE());