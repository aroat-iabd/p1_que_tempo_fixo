-- 1. PREGUNTA 1: Temperatura media por ano
SELECT "Ano", 
    ROUND(AVG("Temp. media (ºC)")::numeric, 2) AS temp_media_sql
FROM meteo_alvedro
GROUP BY "Ano"
ORDER BY "Ano";

-- 2. PREGUNTA 2: Precipitación media por mes
SELECT "Mes", 
    ROUND(AVG("Precipitación (mm)")::numeric, 2) AS precip_media_sql
FROM meteo_alvedro
GROUP BY "Mes"
ORDER BY "Mes";

-- 3. PREGUNTA NOVA: Días de choiva forte (>= 20 mm) e máxima precipitación por ano
SELECT "Ano", 
    COUNT(*) AS dias_choiva_forte, 
    MAX("Precipitación (mm)") AS max_precip_dia_mm
FROM meteo_alvedro
WHERE "Precipitación (mm)" >= 20.0
GROUP BY "Ano"
ORDER BY "Ano";