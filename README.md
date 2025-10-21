# Prueba Técnica: Flujo ETL y API de (Pageviews de Wikipedia)

## 🚀 Resumen del Proyecto

Este proyecto es la resolución de una prueba técnica para el puesto de Desarrollador(a) Full Stack en DISAGRO. El objetivo principal es construir un **flujo ETL (Extract, Transform, Load)** robusto en Python, que procese datos públicos de BigQuery (Wikipedia Pageviews), almacene los resultados en una base de datos relacional y exponga una **API RESTful** para consultas de negocio.

Además, he incorporado una **aplicación frontend multi-plataforma desarrollada en Flutter**, demostrando la integración completa de la solución y mi capacidad para construir aplicaciones de extremo a extremo (Full Stack) que cumplen con los requisitos funcionales y de presentación.

El desarrollo, seguimiento y gestión de tareas de este proyecto fueron realizados utilizando [**GitHub Issues y GitHub Projects**](https://github.com/users/heckramirezc/projects/1) dentro de este repositorio, lo que refleja un enfoque organizado y transparente en el proceso de desarrollo.

## 🛠️ Stack Tecnológico

| **Componente**    | **Tecnología**                | **Propósito**                                                | Justificación                                                |
| ----------------- | ----------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Orquestación**  | Docker Compose                | Definición y gestión del entorno de tres servicios.          | Requisito explícito de la prueba.                            |
| **Base de Datos** | PostgreSQL 17 + Docker        | Almacenamiento de datos y soporte para Vistas Materializadas. | PostgreSQL tiene excelente soporte para modelos de datos complejos (como el modelo estrella solicitado). |
| **Capa de Datos** | Python 3.11, Pandas, Psycopg2 | **E**xtracción (BigQuery), **T**ransformación (Cálculo de métricas), **L**oad (UPSERT a PostgreSQL). | Requisito explícito de la prueba.                            |
| **API Backend**   | NestJS (Node.js/TypeScript)   | Exposición de *endpoints* de consulta, paginación y documentación (Swagger/Redoc). | Aunque la prueba permitía "lenguaje a tu elección", opté por NestJS para la API debido a mi sólida experiencia en Node.js y TypeScript, y la mención de NestJS en la entrevista. |
| **Cloud**         | Google BigQuery (Fuente)      | Fuente de datos públicos de Wikipedia Pageviews.             | Requisito explícito de la prueba.                            |
| Frontend          | Flutter(PENDIENTE)            | Visualización de datos / Orquestación de ETL                 | Aunque no explícitamente requerido en el documento, se mencionó el frontend en la llamada. Aprovechando mi experiencia en Flutter y la versatilidad de la plataforma, construí un frontend multi-plataforma. La versión web está desplegada en **Firebase Hosting**, mostrando mi familiaridad con el ecosistema de Google. |



## ✨ Funcionalidades Implementadas

### **1. Flujo ETL (Python en contenedor Docker - Cloud Run para producción):**

*   **Extracción de BigQuery:**
    *   Conexión parametrizada a `bigquery-public-data.wikipedia.pageviews_2024`.
    *   Extracción de datos por rango de fechas e idiomas específicos.
    *   Filtrado inicial para limitar el volumen de datos y acotar al tráfico humano (decisión documentada en el código ETL).
    *   Recuperación de campos mínimos: fecha (agregada a día), wiki/idioma, título, vistas.
*   **Transformación:**
    *   Normalización de títulos a un formato consistente (sin espacios/diacríticos).
    *   Unificación del tráfico de escritorio y móvil (`en` y `en.m` se combinan para un `views_total` unificado por idioma).
    *   Exclusión de títulos no representativos de contenido (criterios documentados en el ETL).
    *   Cálculo de métricas derivadas: `views_total` (suma de plataformas), `avg_views_7d`, `avg_views_28d`, `variations` y `trend_score` (basado en z-score).
*   **Carga en PostgreSQL:**
    *   Diseño de un modelo estrella (`dim_page`, `fact_pageviews_daily`) para datos analíticos.
    *   Creación de la tabla `etl_jobs` para registrar el estado de cada ejecución del ETL desde el frontend.
    *   Lógica de inserción/actualización de datos en las tablas de la base de datos.
    *   Refresco de vistas materializadas post-carga.

### **2. API de Datos (NestJS en contenedor Docker - Cloud Run para producción):**

*   **Endpoints RESTful:**

    La API proporciona tres *endpoints* para consultar los datos optimizados.

    | **Ruta**                   | **Descripción**                                              | **Optimización**                                         |
    | -------------------------- | ------------------------------------------------------------ | -------------------------------------------------------- |
    | **GET /api/page/top**      | Retorna el ranking de las páginas más vistas por día e idioma. Soporta paginación (`limit`, `offset`). | Consulta `mv_top_n_daily_by_language`.                   |
    | **GET /api/page/trending** | Retorna las páginas cuyo `trend_score` excede el umbral de `2.0`. Soporta paginación. | Consulta `mv_trending_daily`.                            |
    | **GET /api/page/:title**   | Retorna la serie histórica diaria de vistas y métricas (7d, 28d, trend) para una página específica en un rango de fechas. | Consulta `fact_pageviews_daily` filtrando por `page_id`. |

    

*   **Formato de Respuesta:**

    *   JSON consistente con `items`, `page`, `page_size`, `total`, `params`.

*   **Documentación Interactiva:**

    La documentación está disponible automáticamente después de iniciar el servicio `api`:

    - **Swagger UI:** `http://localhost:3000/api-docs`
    - **Redoc (Vista Amigable):** `http://localhost:3000/`

    

    La API proporciona endpoints para la orquestación desde el frontend del ETL:

    *   `POST /api/etl/start`: Inicia un nuevo trabajo ETL (invoca Cloud Run del ETL asíncronamente).
    *   `GET /api/etl/status/{jobId}`: Permite consultar el estado actual de un trabajo ETL específico.

### **3. Pruebas:**

*   El proyecto incluye pruebas unitarias y de integración para asegurar la confiabilidad del código.

| **Área** | **Tecnología**     | **Cobertura**                                                |
| -------- | ------------------ | ------------------------------------------------------------ |
| **ETL**  | `pytest`           | Pruebas para las funciones de transformación de datos (normalización, métricas). |
| **API**  | `jest` / Supertest | Pruebas unitarias para servicios y pruebas de integración para los controladores de la API (`GET /top`,`GET /trending`, `GET /page/:title`) validando estatus HTTP, estructura JSON y lógica de paginación. |

---

## 🚀 Configuración del Entorno y Ejecución

El proyecto está diseñado para ejecutarse completamente con `docker compose`.

### 1.1. Prerrequisitos

Asegúrate de tener instalados:

- **Docker** y **Docker Compose** (o Docker Desktop).
- **Node.js y Python** (opcional, solo para desarrollo local fuera de Docker).

### 1.2. Configuración de Credenciales

Este proyecto requiere acceso a Google BigQuery y credenciales de base de datos.

1. **Credenciales de Google BigQuery:**

   - Crea una cuenta de servicio de Google Cloud con el rol de **Lector de datos de BigQuery** (o permisos equivalentes).
   - Descarga el archivo JSON de la clave de servicio.
   - Copia el contenido del archivo JSON en **`api/bigquery_key.json`**.
   - Este archivo es montado en el contenedor ETL a través del `docker-compose.yml`.

2. **Variables de Entorno (.env):**

   - En la raiz del proyecto se encuentra el archivo **`.env`**.
   - Se encontará la siguiente configuración para desarrollo.

   ```
   # --- PostgreSQL Configuration ---
   DB_HOST=postgres
   DB_PORT=5432
   DB_NAME=disagro_db
   DB_USER=disagro_user
   DB_PASSWORD=your_secure_password
   DB_SSL_MODE=disable # Usar 'require' en producción
   
   # --- API Configuration ---
   PORT=3000
   CORS_ORIGIN=http://localhost:3000,http://localhost:3001 # Origen del frontend
   
   # --- BigQuery Configuration---
   # El ID del proyecto donde se ejecuta la consulta de BigQuery.
   BIGQUERY_PROJECT_ID=disagro-hr-test 
   ```

### 1.3. Instrucciones de Ejecución

1. Instalación de paquetes (API):

   En terminal ejecuta **`cd api/`** para ir al directorio de la API y proceder a instlar los paquetes. IMPORTANTES: sin estar presentes los paquetes el contenedor de API puede presentar inconvenientes de lanzamiento. 

   ```
   npm install
   ```

2. Construir y Lanzar Contenedores (DB, ETL, API):

   Construye las imágenes y levanta los servicios.

   ```
   docker-compose up
   ```

3. Los contenedores ETL y API son directamente dependientes del contenedor DB, por lo que no iniciarán hasta que el estado de DB sea saludable:

   El servicio postgres ejecutará automáticamente el DDL para crear todas las tablas, índices y vistas materializadas (ubicados en el volumen ./db/ddl).

4. Sobre contenedor ETL:

   El servicio etl está configurado como un job que se ejecuta y detiene automáticamente. Asegúrate de que los servicios postgres y api estén levantados.

   *Nota: El ETL registrará su progreso en la tabla `etl_jobs` de PostgreSQL.*

---

## ✅ Ejecución de Pruebas Automatizadas

El proyecto incluye dos conjuntos de pruebas fundamentales:

### 1. Pruebas del API (NestJS / TypeScript)

Estas pruebas incluyen tanto **Pruebas Unitarias** (para la lógica de negocio en los Servicios) como **Pruebas de Integración** (para la capa HTTP de los Controladores, verificando rutas, DTOs y validación).



| **Comando**                                                 | **Descripción**                                              |
| ----------------------------------------------------------- | ------------------------------------------------------------ |
| `docker exec -it disagro_hr_api npm run test`               | Ejecuta todas las pruebas unitarias y de integración del API. |
| `docker exec -it disagro_hr_api npm run test -- --verbose`  | **Muestra el detalle completo** de la ejecución, incluyendo cada prueba individual que pasa o falla. |
| `docker exec -it disagro_hr_api npm run test -- --coverage` | Genera un informe detallado de la **cobertura** del código por pruebas. |

### 2. Pruebas del ETL (Python / Pytest)

Estas son **Pruebas Unitarias** centradas en la lógica de transformación (`T`) del ETL, asegurando que las funciones de manipulación de datos (`pandas`) y cálculo de métricas (como el `trend_score`) sean correctas.

| **Comando**                                                  | **Descripción**                                              |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `docker compose run --rm -v "$(pwd)/tests:/app/tests" etl pytest tests/etl/` | Ejecuta todas las pruebas del módulo ETL de Python.          |
| `docker compose run --rm -v "$(pwd)/tests:/app/tests" etl pytest -v tests/etl/` | **Muestra el detalle completo** (`-v` de verbose) de la ejecución de Pytest, listando el nombre de cada prueba. |





---



## 💡 Decisiones de Diseño y Justificaciones Clave

1.  **Inclusión de `language` en `dim_page` y `fact_pageviews_daily`:**
    *   El requisito de la prueba indica que `dim_page` debe incluir `idioma`, y que se deben implementar índices para acelerar consultas por `lang`. Para cumplir estrictamente con el primer punto, `language` se incluye en `dim_page`.
    *   Simultáneamente, para optimizar el rendimiento de las consultas analíticas sobre los datos de pageviews (en `fact_pageviews_daily`) y permitir una indexación eficiente por `language` sin costosos `JOIN`s a la tabla de dimensión en cada consulta (especialmente para los endpoints de la API), se ha decidido **desnormalizar** la columna `language` incluyéndola también directamente en `fact_pageviews_daily`. 
2.  **Umbral del `trend_score` para Títulos en Tendencia (`>= 2.0`):**
    *   Para la funcionalidad de identificar títulos en tendencia, se ha establecido un umbral de `trend_score` de `2.0`. Este valor fue elegido para capturar solo los aumentos en vistas que son **claramente fuera de lo común y verdaderamente significativos** para una página en particular. El objetivo es que la funcionalidad de tendencia resalte aquellos temas de interés alto y repentino, brindando a los usuarios una visión más limpia y relevante de lo que realmente está destacando en Wikipedia, minimizando el "ruido".
3.  **Uso de `RANK()` en `mv_top_n_daily_by_language`:**
    *   Se utilizó la función de ventana `RANK()` para calcular el ranking diario por idioma. `RANK()` es la función apropiada para clasificaciones donde los elementos empatados (páginas con el mismo número de vistas) deben compartir la misma posición.
4.  **Tabla `etl_jobs`:**
    *   Aunque no es un requisito explícito de la prueba, se ha incluido la tabla `etl_jobs`. Esta tabla sirve para **registrar y rastrear el estado de cada ejecución del proceso ETL**, permitiendo que el frontend orqueste y monitoree estas tareas asíncronas en el backend.
5.  **Justificación de la Estrategia de Extracción (BigQuery):**
    - Se optó por utilizar una única query con el filtro de rango FORMAT_TIMESTAMP(...) BETWEEN start_date AND end_date para cubrir la ventana de extracción en lugar de un bucle de consulta diario.
    - Razón de la Decisión (Optimización): BigQuery es un motor optimizado para grandes scans. Ejecutar una sola consulta, incluso si abarca múltiples días, es significativamente más eficiente que ejecutar un bucle en Python que realiza una consulta por día. Esto minimiza el overhead de la latencia de red y la inicialización de jobs, reduciendo el tiempo total de ejecución (TTD) de la fase de Extracción (E).
6.  **Justificación de la Función de Filtrado de Fechas:**
    - Se eligió la función FORMAT_TIMESTAMP de BigQuery en lugar de funciones de manipulación de strings (SUBSTR) para aplicar los filtros de fecha.
    - Razón de la Decisión (Robustez y Partición): Con esto se asegura que el filtro:
      - Maneje correctamente el tipo de dato TIMESTAMP de la columna datehour.
7.  **Justificación de la Fase de Transformación (T):**
    - **Agregaciones Analíticas por Plataforma**
      - Todos los cálculos analíticos (Promedios Móviles, Variaciones y Z-Score) se realizaron mediante la función df.groupby(['language', 'title', 'platform_type']) en Pandas.
      - Razón de la Decisión: La extracción segmenta las vistas por tipo de plataforma (mobile o desktop). Para tener métricas derivadas precisas y granulares (como la tendencia de la versión móvil vs. la de escritorio).
    - **Métrica "Variaciones" (Crecimiento Porcentual Diario)**
      - Para cumplir con el requisito de "variaciones", se implementó la métrica Crecimiento Porcentual Diario (variations).
      - Razón de la Decisión: Esta métrica es fundamental en la analítica de negocio porque ofrece una señal inmediata de volatilidad a corto plazo, comparando las vistas de hoy contra el día anterior.
    - **Normalización de Títulos (Diacríticos)**
      - Se añadió un paso de limpieza que utiliza el módulo unicodedata para la columna title, convirtiéndola en normalized_title (sin acentos, en minúsculas y con espacios reemplazados por guiones bajos).
      - Razón de la Decisión (Integridad de la Clave): Esto es crucial para la extracción del idioma español (es) y la construcción de la dimensión dim_page. Una normalización incompleta (que deja acentos) provocaría que el mismo concepto (p. ej., "Página de Prueba" vs. "Pagina de Prueba") genere dos claves dimensionales (page_id) diferentes, lo cual es un fallo de integridad en el modelo estrella.
8.  **Justificación de ventana de 7 días:** 
    - Debido a las restricciones de memoria del entorno de ejecución local, la prueba de la fase de Transformación (T) se ejecutó con una ventana de 7 días de datos históricos. Esta ventana es suficiente para demostrar la funcionalidad de las métricas de avg_views_7d y el correcto funcionamiento del groupby en los cálculos rolling y el Z-Score. Para cargas de producción completas (30+ días), se requeriría un runtime con mayor asignación de RAM



---

**📚 Documentación Adicional**

\*   ***Colección de Postman:*** 

​	Se ha proporcionado una colección de postman con ejemplos de solicitudes para los endpoints de la API, facilitando su exploración y prueba en  `api/docs`.



---

## 🧑‍💻 Autor

*   **Hector Ramírez**
*   heckramirezc@aol.com
*   https://www.linkedin.com/in/heckramirez/
*   http://github.com/heckramirezc

---
