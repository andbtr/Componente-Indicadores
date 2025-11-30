WITH hemoglobina AS (
    SELECT
        ed.patient_id,
        ed.diagnosis_coded,
        ed.date_created
    FROM encounter_diagnosis ed
    WHERE ed.diagnosis_coded IN (
        (SELECT concept_id FROM concept WHERE uuid = '3968fe52-ca22-4b26-83c5-edd90518c9ca'),  -- Hemoglobina (85018)
        (SELECT concept_id FROM concept WHERE uuid = 'd1f01f5b-bb2f-46aa-9b62-f1fe009708f6')   -- Hemoglobina (85018.01)
    )
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

edad_valida AS (
    SELECT
        h.patient_id,
        h.date_created,
        TIMESTAMPDIFF(MONTH, p.birthdate, h.date_created) AS edad_meses
    FROM hemoglobina h
    JOIN person p ON p.person_id = h.patient_id
),

conteos AS (
    SELECT
        patient_id,
        COUNT(*) AS total_examenes,
        MIN(date_created) AS fecha_1,
        MAX(date_created) AS fecha_2,
        MIN(edad_meses) AS edad_min,
        MAX(edad_meses) AS edad_max
    FROM edad_valida
    GROUP BY patient_id
)

SELECT
    COUNT(*) AS ninos_con_dosaje_valido
FROM conteos
WHERE
    (
        -- < 12 meses → requiere 1 examen
        edad_min < 12
        AND total_examenes >= 1
    )
    OR
    (
        -- 12–23 meses → requiere 2 exámenes separados >= 6 meses
        edad_min >= 12 AND edad_max < 24
        AND total_examenes >= 2
        AND TIMESTAMPDIFF(MONTH, fecha_1, fecha_2) >= 6
    )
    OR
    (
        -- 24–35 meses → requiere 1 examen en el año
        edad_min >= 24 AND edad_max < 36
        AND total_examenes >= 1
    );
