WITH vacunas AS (
    SELECT
        ed.patient_id,
        ed.diagnosis_coded,
        ed.date_created
    FROM encounter_diagnosis ed
    WHERE ed.diagnosis_coded IN (
        (SELECT concept_id FROM concept WHERE uuid = '380b12ab-609f-43d0-ac6c-2e868db887a1'), -- Pentavalente
        (SELECT concept_id FROM concept WHERE uuid = '6b0d4dec-22cd-48a4-9d2c-7e2a70cb87c8'), -- Neumocócica
        (SELECT concept_id FROM concept WHERE uuid = 'c6346607-9b14-4fca-abc5-de448936a1c0'), -- IPV
        (SELECT concept_id FROM concept WHERE uuid = '8510d9be-d9fc-4bd4-b088-352ee51463e1'), -- Rotavirus
        (SELECT concept_id FROM concept WHERE uuid = '28e34d9c-a572-4ed7-9d4e-127112c4aeb4'), -- Influenza
        (SELECT concept_id FROM concept WHERE uuid = 'b0e9611e-7d75-4299-a86e-adc656cd2784'), -- DTP
        (SELECT concept_id FROM concept WHERE uuid = 'e0921f4a-224a-46b1-899f-ff158f57716c'), -- Hib
        (SELECT concept_id FROM concept WHERE uuid = '0a687fc4-a5eb-415c-88c7-4b1fe8291488')  -- HVB
    )
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

edad_valida AS (
    SELECT
        v.patient_id,
        v.diagnosis_coded
    FROM vacunas v
    JOIN person p ON p.person_id = v.patient_id
    WHERE
        TIMESTAMPDIFF(MONTH, p.birthdate, v.date_created) >= 1
        AND TIMESTAMPDIFF(MONTH, p.birthdate, v.date_created) < 12
),

conteos AS (
    SELECT
        patient_id,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='380b12ab-609f-43d0-ac6c-2e868db887a1') THEN 1 ELSE 0 END) AS pentavalente,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='6b0d4dec-22cd-48a4-9d2c-7e2a70cb87c8') THEN 1 ELSE 0 END) AS neumococica,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='c6346607-9b14-4fca-abc5-de448936a1c0') THEN 1 ELSE 0 END) AS ipv,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='8510d9be-d9fc-4bd4-b088-352ee51463e1') THEN 1 ELSE 0 END) AS rotavirus,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='28e34d9c-a572-4ed7-9d4e-127112c4aeb4') THEN 1 ELSE 0 END) AS influenza,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='b0e9611e-7d75-4299-a86e-adc656cd2784') THEN 1 ELSE 0 END) AS dtp,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='e0921f4a-224a-46b1-899f-ff158f57716c') THEN 1 ELSE 0 END) AS hib,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='0a687fc4-a5eb-415c-88c7-4b1fe8291488') THEN 1 ELSE 0 END) AS hvb
    FROM edad_valida
    GROUP BY patient_id
)

SELECT
    COUNT(*) AS ninos_completamente_vacunados
FROM conteos
WHERE
    pentavalente >= 3
    AND neumococica >= 2
    AND ipv >= 3
    AND rotavirus >= 2
    AND influenza >= 2
    AND dtp >= 2
    AND hib >= 2
    AND hvb >= 2;

