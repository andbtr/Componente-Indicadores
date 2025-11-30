WITH vitA AS (
    SELECT
        ed.patient_id,
        ed.date_created
    FROM encounter_diagnosis ed
    WHERE ed.diagnosis_coded = (
        SELECT concept_id FROM concept WHERE uuid = '6650eee5-a2f8-46c3-9d78-a4b206648efc'
    )
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

edad_valida AS (
    SELECT
        v.patient_id,
        v.date_created,
        TIMESTAMPDIFF(MONTH, p.birthdate, v.date_created) AS edad_meses
    FROM vitA v
    JOIN person p ON p.person_id = v.patient_id
),

conteos AS (
    SELECT
        patient_id,
        COUNT(*) AS dosis_totales,
        MIN(date_created) AS fecha_1,
        MAX(date_created) AS fecha_2,
        MIN(edad_meses) AS edad_min,
        MAX(edad_meses) AS edad_max
    FROM edad_valida
    GROUP BY patient_id
)

SELECT
    COUNT(*) AS ninos_suplementados
FROM conteos
WHERE
      (
        -- Grupo 1: 6–11 meses → requiere 1 dosis
        edad_min >= 6 AND edad_max < 12
        AND dosis_totales >= 1
      )
   OR
      (
        -- Grupo 2: 12–59 meses → 2 dosis separadas ≥ 6 meses
        edad_min >= 12 AND edad_max < 60
        AND dosis_totales >= 2
        AND TIMESTAMPDIFF(MONTH, fecha_1, fecha_2) >= 6
      );