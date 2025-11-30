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
  AND YEAR(ed.date_created) = YEAR(CURDATE());