WITH vacunas AS (
    SELECT
        ed.patient_id,
        ed.diagnosis_coded,
        ed.date_created
    FROM encounter_diagnosis ed
    WHERE ed.diagnosis_coded IN (
        (SELECT concept_id FROM concept WHERE uuid = '6b0d4dec-22cd-48a4-9d2c-7e2a70cb87c8'),  -- Neumocócica (1)
        (SELECT concept_id FROM concept WHERE uuid = '3e85ca40-2a18-468c-82fd-95fbbacd28ff'),  -- SPR / MMR (2)
        (SELECT concept_id FROM concept WHERE uuid = '4b7bf93a-f557-47c1-aca0-6164899fd9d7'),  -- Antiamarílica (1)
        (SELECT concept_id FROM concept WHERE uuid = '4cdc926e-9f01-43b2-a304-857dfd32fd0d'),  -- OPV / IPV (1)
        (SELECT concept_id FROM concept WHERE uuid = '28e34d9c-a572-4ed7-9d4e-127112c4aeb4'),  -- Influenza (1)
        (SELECT concept_id FROM concept WHERE uuid = 'b0e9611e-7d75-4299-a86e-adc656cd2784'),  -- DPT (1)
        (SELECT concept_id FROM concept WHERE uuid = '08187722-5ab0-48d9-8abf-a59df11fab48'),  -- Varicela (1)
        (SELECT concept_id FROM concept WHERE uuid = '1747b551-37e9-401e-a1d8-573a4a3ed322')   -- Hepatitis A (1)
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
        TIMESTAMPDIFF(MONTH, p.birthdate, v.date_created) >= 12
        AND TIMESTAMPDIFF(MONTH, p.birthdate, v.date_created) < 24
),

conteos AS (
    SELECT
        patient_id,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='6b0d4dec-22cd-48a4-9d2c-7e2a70cb87c8') THEN 1 ELSE 0 END) AS neumococica,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='3e85ca40-2a18-468c-82fd-95fbbacd28ff') THEN 1 ELSE 0 END) AS spr,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='4b7bf93a-f557-47c1-aca0-6164899fd9d7') THEN 1 ELSE 0 END) AS antiamarilica,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='4cdc926e-9f01-43b2-a304-857dfd32fd0d') THEN 1 ELSE 0 END) AS opv_ipv,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='28e34d9c-a572-4ed7-9d4e-127112c4aeb4') THEN 1 ELSE 0 END) AS influenza,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='b0e9611e-7d75-4299-a86e-adc656cd2784') THEN 1 ELSE 0 END) AS dpt,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='08187722-5ab0-48d9-8abf-a59df11fab48') THEN 1 ELSE 0 END) AS varicela,
        SUM(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='1747b551-37e9-401e-a1d8-573a4a3ed322') THEN 1 ELSE 0 END) AS hepatitis_a
    FROM edad_valida
    GROUP BY patient_id
)

SELECT
    COUNT(*) AS ninos_completamente_vacunados
FROM conteos
WHERE
    neumococica >= 1
    AND spr >= 2
    AND antiamarilica >= 1
    AND opv_ipv >= 1
    AND influenza >= 1
    AND dpt >= 1
    AND varicela >= 1
    AND hepatitis_a >= 1;
