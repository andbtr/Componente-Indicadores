WITH procedimientos AS (
    SELECT
        ed.patient_id,
        ed.diagnosis_coded,
        ed.date_created
    FROM encounter_diagnosis ed
    WHERE ed.diagnosis_coded IN (
        (SELECT concept_id FROM concept WHERE uuid = '1b317b42-cd2c-49cb-a7bd-1b3d4683c5f7'),  -- Examen seriado 87177.01
        (SELECT concept_id FROM concept WHERE uuid = '57bb4ea7-5778-4885-916f-75739c38ef0e')   -- Test de Graham 87178
    )
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

edad_valida AS (
    SELECT
        p.patient_id,
        p.diagnosis_coded,
        TIMESTAMPDIFF(MONTH, per.birthdate, p.date_created) AS edad_meses
    FROM procedimientos p
    JOIN person per ON per.person_id = p.patient_id
    WHERE TIMESTAMPDIFF(MONTH, per.birthdate, p.date_created) BETWEEN 12 AND 35
),

pivot AS (
    SELECT
        patient_id,
        MAX(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='1b317b42-cd2c-49cb-a7bd-1b3d4683c5f7') THEN 1 END) AS examen_seriado,
        MAX(CASE WHEN diagnosis_coded = (SELECT concept_id FROM concept WHERE uuid='57bb4ea7-5778-4885-916f-75739c38ef0e') THEN 1 END) AS graham
    FROM edad_valida
    GROUP BY patient_id
)

SELECT
    COUNT(*) AS ninos_con_examenes_completos
FROM pivot
WHERE examen_seriado = 1
  AND graham = 1;