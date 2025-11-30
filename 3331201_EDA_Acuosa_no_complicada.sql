WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        '78df0a98-81db-45d0-b98f-67e83acde3de',
        '8a3f12ba-2326-4f86-a44c-854dfb9f73f8',
        '3074f277-0772-4a22-9f12-b700fc54f965',
        'e66dfcb3-e5ac-4797-806f-a2c14400834c',
        '04dc10a4-c3ec-412b-ac5f-9b9699df3d21',
        '7648a8d8-2713-47a8-9e98-73d3eac9608a',
        '92174f02-e951-437d-9717-b260aa608c99',
        '409192fb-8da6-42dd-8774-b1904ea50b69',
        'e185241f-640d-4853-8e14-a191eb9820af',
        'c4558e15-1f35-47eb-808d-621f288171be',
        '35d177dc-cb94-48ef-9a46-a5956222bbba',
        '9483673a-2bcf-4895-ac1e-e8a8f63d390b',
        'd43c2e9e-b39a-41bf-aa20-923e411cd445',
        '1e8f7940-d923-4f13-b235-a95515162f73',
        '664d0975-3e14-46ff-87f8-1f06b58d08ae',
        '9defa929-d070-49fc-b6fe-90f29ee9bc99',
        'd246873b-6b00-4418-ade3-a4f03a1086c6',
        '51efad59-7148-4d0b-a3d3-d05f11a77556',
        '72f0953d-ab8c-49e7-a1ce-30038ac8416e'
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
