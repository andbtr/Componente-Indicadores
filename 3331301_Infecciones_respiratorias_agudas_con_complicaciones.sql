WITH cie10_concepts AS (
    SELECT DISTINCT concept_id
    FROM concept
    WHERE uuid IN (
        'f30df1bc-738e-4438-9d59-9b7dcd021f47',
        '34b39f56-c410-45d8-b0f6-54fd9910093f',
        'd7dcec13-890f-4b9e-8a06-e6fa990088c6',
        'c150c769-e77c-48f7-8932-6344d40ec10f',
        '67fcd928-8b8e-4ebe-a087-81e764e1ed86',
        'bbcea9ec-d290-49cb-b041-69082da9aeb5',
        'c5ffc632-38ae-4910-8c76-f08d33f79071',
        '9b4a18a1-dfb1-4617-b987-52c4670fff13',
        '75152f13-109b-4583-8f45-98e5fa350f50',
        'ace0cb21-a695-4112-be0c-1d65ace6fc53',
        '58f21bf2-0795-44c2-9fe4-496561c85c0e',
        'c025ec0e-b872-4432-8d7d-f516b4ad923b',
        '76341e81-42d9-452f-a2b0-33cd41b73cdc',
        'e23aeb89-e75b-45a4-9dba-416ac72a287d',
        'c4ac4d1b-d21a-472f-aa27-3695be26e32d',
        '6f08ab7c-87cb-42f7-bd09-b18cc6744ff8',
        '8615a006-8339-433c-b39d-6027d49ce6cb',
        'bc440380-d477-4efa-8e53-1e33ab98f522',
        '48187a53-d0ad-4b71-8fcd-0a9e3c1d082a',
        'd8c672f4-24cf-4dbc-baa0-ae00d699a430',
        'c8139c49-c9d9-4092-89ed-56786196691e'
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
    -- Solo año actual
    AND YEAR(ed.date_created) = YEAR(CURDATE());