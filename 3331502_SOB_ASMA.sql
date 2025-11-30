WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        '0ba9efc1-bcff-431b-a46e-d1939486267e',
        '516dfe8c-8e07-490a-8845-7c5f9d7f0a9a',
        '34640087-f579-4dd9-b4fc-b075e83c2da8',
        '80bb35cd-3d30-40be-ba25-54667a00a979',
        '3d355b5a-fee3-40ba-8b8b-aaa4307c1c27',
        '57f9d475-4e23-42f5-8f93-4c68dee6fe4e',
        '06d26345-7dfe-40a9-a21b-779a6fcd8728',
        '67fdd2dc-6bef-4f37-bb52-4892556e8a75',
        'e239955c-90b0-4efa-94c2-bc849b6880c3',
        'b1a0344e-28c1-4862-a331-e90fc848fe43',
        '4d5fe639-f492-44a0-bc4a-dbdf5d691614',
        '6b50eced-5b5c-4ef4-8cd8-f006aa8c443d'
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
    -- Menores de 5 años
    TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) < 5
    -- Año actual
    AND YEAR(ed.date_created) = YEAR(CURDATE());
