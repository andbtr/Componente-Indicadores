WITH vaccine_concepts AS (
    SELECT DISTINCT concept_id
    FROM concept
    WHERE uuid IN (
        'b471be68-b180-44f5-820b-ec963df9d698',  -- Influenza
        '4b7bf93a-f557-47c1-aca0-6164899fd9d7',  -- Antiamarílica
        '4cdc926e-9f01-43b2-a304-857dfd32fd0d',  -- OPV (polio oral)
        'b0e9611e-7d75-4299-a86e-adc656cd2784'   -- DPT
    )
),

diagnos AS (
    SELECT
        ed.patient_id,
        ed.diagnosis_coded,
        ed.date_created
    FROM encounter_diagnosis ed
    JOIN vaccine_concepts vc
        ON vc.concept_id = ed.diagnosis_coded
    WHERE YEAR(ed.date_created) = YEAR(CURDATE())
),

rango_edad AS (
    SELECT
        d.patient_id,
        d.diagnosis_coded
    FROM diagnos d
    JOIN person p ON p.person_id = d.patient_id
    WHERE
        TIMESTAMPDIFF(YEAR, p.birthdate, d.date_created) >= 4
        AND TIMESTAMPDIFF(YEAR, p.birthdate, d.date_created) < 5
),

pivot AS (
    SELECT
        patient_id,
        MAX(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='b471be68-b180-44f5-820b-ec963df9d698') THEN 1 END) AS influenza,
        MAX(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='4b7bf93a-f557-47c1-aca0-6164899fd9d7') THEN 1 END) AS antiamarilica,
        MAX(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='4cdc926e-9f01-43b2-a304-857dfd32fd0d') THEN 1 END) AS opv,
        MAX(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='b0e9611e-7d75-4299-a86e-adc656cd2784') THEN 1 END) AS dpt
    FROM rango_edad
    GROUP BY patient_id
)

SELECT
    COUNT(*) AS ninos_vacunados_completos
FROM pivot
WHERE influenza = 1
  AND antiamarilica = 1
  AND opv = 1
  AND dpt = 1;
