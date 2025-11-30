WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        '608a5958-7c4c-42db-8a1c-094761a70f26',
        'd55a179d-86fb-4b72-8808-824d28288ead',
        '1b19caf0-4bd3-4d0c-9277-cd6c9be636bb',
        '1b719d74-8318-4350-b2ba-bc301cd62a7d',
        'b4bb0bc8-4eb8-4bb9-b8f3-983bd97dbcdb',
        'e65af4e3-be05-4ac7-b703-fef24c2a4230',
        'ae96015f-3a89-484c-bccd-5309b26bdcdb',
        'e01f5787-6897-4447-9879-9eaad59e6d35'
    )
)

SELECT
    COUNT(*) AS casos_ira_no_complicada
FROM encounter_diagnosis ed
JOIN cie10_concepts c ON c.concept_id = ed.diagnosis_coded
JOIN person p ON p.person_id = ed.patient_id
WHERE
    TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) < 5
    AND YEAR(ed.date_created) = YEAR(NOW());
