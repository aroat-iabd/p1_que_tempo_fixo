# Pipeline de Datos Meteorolóxicos: Estación de Alvedro (A Coruña)

Desenvolvín este proxecto para construír un pipeline de datos en Python e SQL sobre os rexistros meteorolóxicos da estación de Alvedro. O fluxo cobre desde a extracción, limpeza e análise exploratoria ata a medición de eficiencia e a carga automatizada nunha base de datos PostgreSQL con Docker.

## 1. Descrición do Proxecto e da Estación

O obxectivo é procesar a serie histórica diaria de 5 anos completos (2021-2025) para analizar o comportamento do clima local e garantir a integridade dos datos almacenados.

- Nome da estación: A Coruña / Alvedro (aeroporto)
- Indicativo oficial: 08002
- Coordenadas xeográficas:
    - Latitude: 43,3000°
    - Lonxitude: -8,3833°
- Altitude: 97 m

## 2. Fonte dos Datos e Condicións de Uso

- Fonte de orixe: Meteostat (meteostat.net)
- URL de descarga / API: *https://raw.githubusercontent.com/bigdatawirtz/datasets/main/datasets/meteo_alvedro_2021_2025.csv*
- Condicións de uso: Licenza Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0). Permitido o seu uso para fins académicos e de investigación non comerciais coa debida atribución da orixe.
- Data de descarga: Febreiro de 2026.

## 3. Decisións de Limpeza e Calidade de Datos

Na fase previa á análise (apartado 4.3), realicei un control de calidade para garantir que non existisen anomalias que distorsionasen as métricas.

| Problema atopado | Como o detectei | Decisión / Solución aplicada |
| :--- | :--- | :--- |
| Valores sentinela irrealistas (-9999.0) | Mediante a visualización da gráfica de control de calidade previa á limpeza, onde xurdían picos cara abaixo inviables | Reemplazáronse por nulos (np.nan) e aplicouse unha interpolación liñal sobre a serie temporal. |
| Rexistros duplicados | Executando df.duplicated(subset=['Data']) no DataFrame orixinal. | Elimináronse os duplicados conservando unicamente a primeira ocorrencia (drop_duplicates) |
| Ocos na serie temporal (días faltantes) | Ao comparar o número total de filas da táboa co número de días reais do calendario entre 2021 e 2025 (1826 días) | Reorganizouse o índice xerando un rango continuo diario de 1826 filas e recheáronse os novos ocos de forma liñal |

## 4. Como Executar o Proxecto Paso a Paso

#### Requisitos previos
- WSL con Python 3.10+ instalado.
- Docker e Docker Compose activos na máquina.

### Pasos para a execución:
1. Clonar o repositorio e acceder á carpeta:
```bash
git clone <URL-do-teu-repositorio>
cd p1_que_tempo_fixo
```

2. Crear o ficheiro de variables de contorno (.env):
Copia o ficheiro .env.exemplo na raíz do proxecto coas credenciais da base de datos:
```text
POSTGRES_USER=usuario
POSTGRES_PASSWORD=postgres
POSTGRES_DB=meteo_db
```

3. Levantar o servizo de PostgreSQL con Docker Compose:
```bash
docker compose up -d
```

4. Configurar a contorna virtual e instalar dependencias:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

5. Executar o Jupyter Notebook:

Abre e executa as celas en orde do notebook notebooks/pipeline_meteo.ipynb. As celas encárganse de procesar os datos, medir os tempos de rendemento (%timeit) e enviar a táboa limpa a PostgreSQL.

6. Executar e verificar o script SQL directamente na base de datos:
```bash
docker exec -i postgres-meteo psql -U usuario -d meteo_db -f /sql/consultas.sql
```

## 5. Nota sobre os Resultados das Consultas (Pandas vs SQL)
No apartado 4.7, ao comparar as consultas do ficheiro sql/consultas.sql cos cálculos previos de Pandas, obtivéronse os seguintes resultados

### Pregunta 1 (Temperatura media anual):
O resultado en SQL deu un coincidencia exacta (True) con Pandas, confirmando a integridade do traspaso de datos a PostgreSQL.

### Pregunta 2 (Precipitación mensual):
A proba deu False por un matiz metodolóxico interesante:
- En Pandas (4.4) calculouse a precipitación mensual acumulada media (~106.9 mm para o mes de xaneiro entre os 5 anos).
- En SQL (4.7) a consulta executou AVG("Precipitación (mm)"), o que calcula a media diaria do mes de xaneiro (~3.45 mm/día).
- Verificación: Multiplicando a media diaria de SQL polos 31 días de xaneiro ($3.45 \text{ mm/día} \times 31 \text{ días} = 106.95 \text{ mm}$), comprobouse que a equivalencia matemática é do 100% e a migración é totalmente correcta.

### Pregunta 3 (Pregunta Nova - Eventos Extremos):
Analizáronse os días con choivas torrenciais ($\ge 20 \text{ mm}$) e a precipitación máxima diaria por ano. Identificáronse picos de ata 11 días de choiva intensa nos anos 2022, 2024 e 2025, destacando un máximo histórico de $58.7 \text{ mm}$ nun só día durante o ano 2022.


## 6. Uso da Intelixencia Artificial
Durante o desenvolvemento do proxecto utilizei a asistencia de **Gemini** como ferramenta de apoio técnico nos seguintes puntos:

- Resolución de incidencias: Axuda para diagnosticar o fallo de controladores de PostgreSQL no entorno virtual, definindo a cadea de conexión correcta con `postgresql+psycopg2://`.

- Axuda no deseño da arquitectura con Docker Compose e o ficheiro `.env` para non expor credenciais no código.

- Optimización de scripts SQL:
    - Axuda na lectura automatizada do ficheiro `sql/consultas.sql` dende Python evitando fallos de sintaxe ao separar bloques por comentarios ou puntos e coma.
    - Explicación e axuda para comprender o uso correcto dos métodos de Pandas e a diferencia entre métricas de DataFrames e SQL.
