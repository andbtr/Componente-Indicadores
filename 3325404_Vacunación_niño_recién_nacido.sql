WITH vaccine_concepts AS (
    SELECT DISTINCT concept_id
    FROM concept
    WHERE uuid IN (
        '50cc572c-8ac5-4a4d-a6fa-82258f5ed4f0',  -- BCG
        '0a687fc4-a5eb-415c-88c7-4b1fe8291488'   -- HVB
    )
),

-- Diagnósticos registrados (tratando vacunas como diagnósticos por ahora)
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

-- RN 0–29 días al momento del diagnóstico
rn AS (
    SELECT
        d.patient_id,
        d.diagnosis_coded
    FROM diagnos d
    JOIN person p ON p.person_id = d.patient_id
    WHERE TIMESTAMPDIFF(DAY, p.birthdate, d.date_created) BETWEEN 0 AND 29
),

-- Pivotear: 1 si tiene cada vacuna
pivot AS (
    SELECT
        patient_id,
        MAX(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid = '50cc572c-8ac5-4a4d-a6fa-82258f5ed4f0') THEN 1 END) AS bcg,
        MAX(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid = '0a687fc4-a5eb-415c-88c7-4b1fe8291488') THEN 1 END) AS hvb
    FROM rn
    GROUP BY patient_id
)

SELECT
    COUNT(*) AS rn_vacunados_completos
FROM pivot
WHERE bcg = 1
  AND hvb = 1;