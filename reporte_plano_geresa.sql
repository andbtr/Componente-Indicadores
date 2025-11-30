WITH
q1 AS (
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
    AND hvb >= 2
),

q2 AS (
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
    AND hepatitis_a >= 1
),

q3 AS (
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
  AND dpt = 1
),

q4 AS (
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
  AND hvb = 1
),

q5 AS (
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
  AND hvb = 1
),

q6 AS (
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
  AND hvb = 1
),

q7 AS (
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
  AND hvb = 1
),

q8 AS (
WITH cred AS (
    SELECT
        ed.patient_id,
        ed.diagnosis_coded,
        ed.date_created
    FROM encounter_diagnosis ed
    WHERE ed.diagnosis_coded IN (
        (SELECT concept_id FROM concept WHERE uuid = 'f61fe526-773a-43ea-907b-465a028db69d'), -- CRED <1 año
        (SELECT concept_id FROM concept WHERE uuid = '534dd14a-f8b5-41ad-a660-0bfcab9132a7')  -- CRED 1–4 años
    )
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

edad AS (
    SELECT
        c.patient_id,
        c.date_created,
        TIMESTAMPDIFF(MONTH, p.birthdate, c.date_created) AS edad_meses
    FROM cred c
    JOIN person p ON p.person_id = c.patient_id
    WHERE TIMESTAMPDIFF(MONTH, p.birthdate, c.date_created) BETWEEN 1 AND 35
),

conteos AS (
    SELECT
        patient_id,
        COUNT(*) AS total_controles,
        MIN(edad_meses) AS edad_min,
        MAX(edad_meses) AS edad_max
    FROM edad
    GROUP BY patient_id
),

expected AS (
    SELECT
        patient_id,
        total_controles,
        edad_min,
        edad_max,

        -- Controles esperados según edad
        CASE
            WHEN edad_min < 12 THEN edad_max - edad_min + 1
            WHEN edad_min < 24 THEN CEIL((edad_max - 12 + 1) / 2)
            WHEN edad_min < 36 THEN CEIL((edad_max - 24 + 1) / 3)
        END AS controles_esperados
    FROM conteos
)

SELECT
    COUNT(*) AS ninos_con_cred_completo
FROM expected
WHERE total_controles >= controles_esperados
),

q9 AS (
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
  AND graham = 1
),

q10 AS (
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
      )
),

q11 AS (
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
    )
),

q12 AS (
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
    AND YEAR(ed.date_created) = YEAR(NOW())
),

q13 AS (
WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        '2cc4a9b5-7b1c-4fbc-ba67-8a5c5584162a',
        '319df75b-920a-401c-a799-8075bbcccced',
        '6abc8da0-3f8e-4f36-933c-eecf79c07f6e',
        '4fc6f7e0-9134-4e12-a974-646675edc436',
        'edb311d0-ee19-410e-ab5d-fa0a5da7f81b'
    )
)

SELECT
    COUNT(*) AS casos_fapa_aguda
FROM encounter_diagnosis ed
JOIN cie10_concepts c ON c.concept_id = ed.diagnosis_coded
JOIN person p ON p.person_id = ed.patient_id
WHERE
    -- Menores de 5 años
    TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) < 5
    -- Solo año actual
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q14 AS (
WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        'f96bf9b0-177e-4435-a6a7-e86f577464e1',
        'cfa9d0dd-119e-4cdd-8d1a-7caff722ab06',
        '391aee5b-67d7-4d40-8b01-0d5739cb0bbd',
        '054c172f-5b66-4360-8c8d-9b53f70609ce'
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
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q15 AS (
WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        '6f48eaa6-0815-4073-9225-eb017bc2edd8',
        'edf39746-93f1-4404-8473-5a33561b3798',
        'aee3d4c1-cc61-4da1-af0c-b8c9fefd1757',
        'a2e28752-3f63-4d8e-ae0d-9e0093182620',
        'e0ad9c7f-2c1b-4d07-a1c3-4092a73723df',
        '53a593e5-9c8c-4c7b-af33-9ff1cdb2707d'
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
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q16 AS (
WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        'a593d173-0521-45c6-9b33-4b68682a5172',
        'f895ef4f-9b7f-4a0a-85d9-809b8b624b36',
        '9f6c9fb8-9e89-40e7-8bec-71ab4ed609e1'
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
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q17 AS (
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
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q18 AS (
WITH
  cie10_concepts AS (
    SELECT
      concept_id
    FROM
      concept
    WHERE
      UUID IN (
        'b8c84da2-dcb0-4162-8192-58cc2295314a',
        '82d7b779-c9ce-4a9a-a322-7acff05a5026',
        '6ae7ab99-66da-436b-a7da-630f42a43b20',
        'eaa4ba00-28fe-4e97-9277-0ad0572b043f',
        '3886e1ef-7ea6-48ad-8fda-f0452332652c',
        'df5ba71b-c3ee-4e30-9f76-6fd8b378cb35'
      )
  )
SELECT
  COUNT(*) AS casos_indicador
FROM
  encounter_diagnosis ed
  JOIN cie10_concepts c ON c.concept_id = ed.diagnosis_coded
  JOIN person p ON p.person_id = ed.patient_id
WHERE
  -- Menores de 5 años
  TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) < 5
  -- Solo año actual
  AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q19 AS (
WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        'e7a1bb61-4711-49cc-9ee7-10fae1182cac'
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
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q20 AS (
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
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q21 AS (
WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        '2355a2aa-8c81-43c1-949a-177c6ba9cd6c',
        'c2af07da-d066-4933-a728-616b8217d95a',
        'c219af0e-2aaf-4362-b9e3-847822e2107d',
        'c4b295fa-60b5-461a-8c13-357a0110c74d',
        'ad6cde09-5a79-4762-b1d5-1336050b895a',
        '6aadfc49-b182-4778-9bbc-2d7206794e97',
        '75a9f94d-eb40-47c9-87bf-9c8478a92037',
        'c8849cfa-21d6-482b-999c-3b0d6894310f',
        'f060294d-0b41-44fe-89f2-dcfd64a95c63',
        'c55dc51e-8f07-4fc9-8b7c-edba12995ced',
        '3607dc60-cd52-4d4f-9547-a671b32cfa5f',
        '71d6fdc3-290a-4c1c-b29d-a7f7895ede5e',
        '38f68124-ff17-45c4-91ea-3c24caf8ee53',
        '01fe6119-00ac-40e2-bbf6-f39d806d141b',
        'a5d83e66-32c0-40ce-a63f-ed7e03aa8f90'
    )
)

SELECT
    COUNT(*) AS casos_neumonia_grave
FROM encounter_diagnosis ed
JOIN cie10_concepts c ON c.concept_id = ed.diagnosis_coded
JOIN person p ON p.person_id = ed.patient_id
WHERE
    -- Menor de 2 meses (norma)
	TIMESTAMPDIFF(DAY, p.birthdate, ed.date_created) < 60
    -- Año actual
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q22 AS (
WITH cie10_concepts AS (
    SELECT DISTINCT concept_id
    FROM concept
    WHERE uuid IN (
        '2355a2aa-8c81-43c1-949a-177c6ba9cd6c',
        'c2af07da-d066-4933-a728-616b8217d95a',
        'c219af0e-2aaf-4362-b9e3-847822e2107d',
        'c4b295fa-60b5-461a-8c13-357a0110c74d',
        'ad6cde09-5a79-4762-b1d5-1336050b895a',
        '6aadfc49-b182-4778-9bbc-2d7206794e97',
        '75a9f94d-eb40-47c9-87bf-9c8478a92037',
        'c8849cfa-21d6-482b-999c-3b0d6894310f',
        'f060294d-0b41-44fe-89f2-dcfd64a95c63',
        'c55dc51e-8f07-4fc9-8b7c-edba12995ced',
        '3607dc60-cd52-4d4f-9547-a671b32cfa5f',
        '71d6fdc3-290a-4c1c-b29d-a7f7895ede5e',
        '38f68124-ff17-45c4-91ea-3c24caf8ee53',
        '01fe6119-00ac-40e2-bbf6-f39d806d141b',
        'a5d83e66-32c0-40ce-a63f-ed7e03aa8f90'
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
    -- Edad >= 2 meses
    TIMESTAMPDIFF(MONTH, p.birthdate, ed.date_created) >= 2
    -- Edad < 4 años
    AND TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) < 4
    -- Solo año actual
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q23 AS (
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
        'b8c84da2-dcb0-4162-8192-58cc2295314a',
        '82d7b779-c9ce-4a9a-a322-7acff05a5026',
        '409192fb-8da6-42dd-8774-b1904ea50b69',
        'e185241f-640d-4853-8e14-a191eb9820af',
        '6ae7ab99-66da-436b-a7da-630f42a43b20',
        'eaa4ba00-28fe-4e97-9277-0ad0572b043f',
        '3886e1ef-7ea6-48ad-8fda-f0452332652c',
        'c4558e15-1f35-47eb-808d-621f288171be',
        '35d177dc-cb94-48ef-9a46-a5956222bbba',
        'df5ba71b-c3ee-4e30-9f76-6fd8b378cb35',
        '9483673a-2bcf-4895-ac1e-e8a8f63d390b',
        'd43c2e9e-b39a-41bf-aa20-923e411cd445',
        '1e8f7940-d923-4f13-b235-a95515162f73',
        '664d0975-3e14-46ff-87f8-1f06b58d08ae',
        '9defa929-d070-49fc-b6fe-90f29ee9bc99',
        'd246873b-6b00-4418-ade3-a4f03a1086c6',
        '51efad59-7148-4d0b-a3d3-d05f11a77556',
        '72f0953d-ab8c-49e7-a1ce-30038ac8416e',
        'e7a1bb61-4711-49cc-9ee7-10fae1182cac',
        '60aa9b83-042b-49ee-95d9-d37a5465946a'
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
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q24 AS (
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
        'b8c84da2-dcb0-4162-8192-58cc2295314a',
        '82d7b779-c9ce-4a9a-a322-7acff05a5026',
        '409192fb-8da6-42dd-8774-b1904ea50b69',
        'e185241f-640d-4853-8e14-a191eb9820af',
        '6ae7ab99-66da-436b-a7da-630f42a43b20',
        'eaa4ba00-28fe-4e97-9277-0ad0572b043f',
        '3886e1ef-7ea6-48ad-8fda-f0452332652c',
        'c4558e15-1f35-47eb-808d-621f288171be',
        '35d177dc-cb94-48ef-9a46-a5956222bbba',
        'df5ba71b-c3ee-4e30-9f76-6fd8b378cb35',
        '9483673a-2bcf-4895-ac1e-e8a8f63d390b',
        'd43c2e9e-b39a-41bf-aa20-923e411cd445',
        '1e8f7940-d923-4f13-b235-a95515162f73',
        '664d0975-3e14-46ff-87f8-1f06b58d08ae',
        '9defa929-d070-49fc-b6fe-90f29ee9bc99',
        'd246873b-6b00-4418-ade3-a4f03a1086c6',
        '51efad59-7148-4d0b-a3d3-d05f11a77556',
        '72f0953d-ab8c-49e7-a1ce-30038ac8416e',
        'e7a1bb61-4711-49cc-9ee7-10fae1182cac',
        '60aa9b83-042b-49ee-95d9-d37a5465946a',
        '44973cc2-2759-40a8-82a5-fa0b975569ba',
        'db30e191-f010-48b1-bb45-d65268210a6c',
        '7ed0041f-79d1-454f-840b-2ededb73bffe'
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
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q25 AS (
WITH cie10_concepts AS (
    SELECT concept_id
    FROM concept
    WHERE uuid IN (
        '0ba9efc1-bcff-431b-a46e-d1939486267e',
        '516dfe8c-8e07-490a-8845-7c5f9d7f0a9a',
        '34640087-f579-4dd9-b4fc-b075e83c2da8',
        '80bb35cd-3d30-40be-ba25-54667a00a979',
        '3d355b5a-fee3-40ba-8b8b-aaa4307c1c27',
        '57f9d475-4e23-42f5-8f93-4c68dee6fe4e',
        '06d26345-7dfe-40a9-a21b-779a6fcd8728',
        '67fdd2dc-6bef-4f37-bb52-4892556e8a75',
        'e239955c-90b0-4efa-94c2-bc849b6880c3',
        'b1a0344e-28c1-4862-a331-e90fc848fe43',
        '4d5fe639-f492-44a0-bc4a-dbdf5d691614',
        '6b50eced-5b5c-4ef4-8cd8-f006aa8c443d'
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
    -- Año actual
    AND YEAR(ed.date_created) = YEAR(CURDATE())
),

q26 AS (
WITH cie10_concepts AS (
    SELECT DISTINCT concept_id
    FROM concept
    WHERE uuid IN (
        '2a043692-05a1-408a-b68f-2f4020321343',
        'a750e8cd-d814-4314-ba61-4623bf7b69a5',
        '20b7a0d6-99e8-46b6-9732-c25663600413',
        '43cb6995-1221-4e36-a93f-0e9b75e948b2',
        'cb82f587-00fa-4446-a12b-da358b9f6ddc',
        '2732d6b2-e7c3-4c9b-a138-78d112109416',
        'e6304721-9c47-4561-8514-b7a86c981887',
        'e7d9fe27-38a9-4752-b0cc-229e9d744919',
        'e3e43314-a199-4447-8dda-f95d1e3a2c3f',
        '90cbd27f-bfb3-492b-a7ef-a218c2d75f17',
        '70f37bcf-fad4-4afc-91b2-c444bb2989ae',
        '6664abab-d8ad-474f-b197-604324c96078',
        'fa6802a5-78b5-46e6-8974-ebcbf33225ae',
        'b8115646-0172-48d1-a9a6-84a5061e6ddd',
        '97b2618b-4546-42f3-90f0-1819fda9d90d',
        'de301bf5-b82b-45b7-892b-48870923e959',
        'f4fa71ee-b05f-44e2-9161-ca58996095d2',
        'e8205428-e661-4a99-b3ae-9601ba389568'
    )
)

SELECT
    COUNT(*) AS casos_parasitosis
FROM encounter_diagnosis ed
JOIN cie10_concepts c
    ON c.concept_id = ed.diagnosis_coded
JOIN person p
    ON p.person_id = ed.patient_id
WHERE
    -- Edad >= 1 año
    TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) >= 1
    -- Edad < 5 años
    AND TIMESTAMPDIFF(YEAR, p.birthdate, ed.date_created) < 5
    -- Solo año actual
    AND YEAR(ed.date_created) = YEAR(CURDATE())
)

SELECT
    q1.ninos_completamente_vacunados AS `3325401`,
    q2.ninos_completamente_vacunados AS `3325402`,
    q3.ninos_vacunados_completos AS `3325403`,
    q4.rn_vacunados_completos AS `3325404`,
    q5.rn_vacunados_completos AS `3325405`,
    q6.rn_vacunados_completos AS `3325406`,
    q7.rn_vacunados_completos AS `3325509`,
    q8.ninos_con_cred_completo AS `3325510`,
    q9.ninos_con_examenes_completos AS `3325511`,
    q10.ninos_suplementados AS `3325513`,
    q11.ninos_con_dosaje_valido AS `3325607`,
    q12.casos_ira_no_complicada AS `3331101`,
    q13.casos_fapa_aguda AS `3331102`,
    q14.casos_indicador AS `3331103`,
    q15.casos_indicador AS `3331104`,
    q16.casos_indicador AS `3331105`,
    q17.casos_indicador AS `3331201`,
    q18.casos_indicador AS `3331203`,
    q19.casos_indicador AS `3331204`,
    q20.casos_indicador AS `3331301`,
    q21.casos_neumonia_grave AS `3331302`,
    q22.casos_indicador AS `3331305`,
    q23.casos_indicador AS `3331401`,
    q24.casos_indicador AS `3331402`,
    q25.casos_indicador AS `3331502`,
    q26.casos_parasitosis AS `3341401`
FROM q1 CROSS JOIN q2 CROSS JOIN q3 CROSS JOIN q4 CROSS JOIN q5 CROSS JOIN q6 CROSS JOIN q7 CROSS JOIN q8 CROSS JOIN q9 CROSS JOIN q10 CROSS JOIN q11 CROSS JOIN q12 CROSS JOIN q13 CROSS JOIN q14 CROSS JOIN q15 CROSS JOIN q16 CROSS JOIN q17 CROSS JOIN q18 CROSS JOIN q19 CROSS JOIN q20 CROSS JOIN q21 CROSS JOIN q22 CROSS JOIN q23 CROSS JOIN q24 CROSS JOIN q25 CROSS JOIN q26;