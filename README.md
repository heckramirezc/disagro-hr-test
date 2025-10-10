# Prueba Técnica: Flujo ETL y API de (Pageviews de Wikipedia)

## 🚀 Resumen del Proyecto

Este proyecto es la resolución de una prueba técnica para el puesto de Desarrollador(a) Full Stack en DISAGRO. El objetivo principal es construir un **flujo ETL (Extract, Transform, Load)** robusto en Python, que procese datos públicos de BigQuery (Wikipedia Pageviews), almacene los resultados en una base de datos relacional y exponga una **API RESTful** para consultas de negocio.

Además, he incorporado una **aplicación frontend multi-plataforma desarrollada en Flutter**, demostrando la integración completa de la solución y mi capacidad para construir aplicaciones de extremo a extremo (Full Stack) que cumplen con los requisitos funcionales y de presentación.

El desarrollo, seguimiento y gestión de tareas de este proyecto fueron realizados utilizando [**GitHub Issues y GitHub Projects**](https://github.com/users/heckramirezc/projects/1) dentro de este repositorio, lo que refleja un enfoque organizado y transparente en el proceso de desarrollo.

## 🛠️ Tecnologías Utilizadas y Justificación Estratégica

La elección de las tecnologías ha sido cuidadosamente considerada para cumplir con los requisitos de la prueba, optimizar el tiempo de desarrollo (aprovechando mi experiencia) y demostrar la versatilidad de un perfil Full Stack alineado con las menciones tecnológicas de la descripción del puesto.

*   **1. Extracción (E) y Transformación (T):**
    *   **Tecnología:** `Python` con `pandas` y la librería `google-cloud-bigquery`.
    *   **Justificación:** Requisito explícito de la prueba.

*   **2. Carga (L) y Almacenamiento de Datos:**
    *   **Tecnología:** `PostgreSQL` (ejecutado en Docker)
    *   **Justificación:** PostgreSQL es una base de datos relacional altamente robusta, escalable y con excelente soporte para modelos de datos complejos (como el modelo estrella solicitado).

*   **3. API de Datos:**
    *   **Tecnología:** `Node.js` con el framework `NestJS` (TypeScript).
    *   **Justificación:** Aunque la prueba permitía "lenguaje a tu elección", opté por NestJS para la API debido a mi sólida experiencia en Node.js y TypeScript, y la mención de NestJS en la entrevista.

*   **4. Frontend (Visualización de Datos):**
    *   **Tecnología:** `Flutter` (para Web y Móvil).
    *   **Justificación:** Aunque no explícitamente requerido en el documento, se mencionó el frontend en la llamada. Aprovechando mi experiencia en Flutter y la versatilidad de la plataforma, construí un frontend multi-plataforma. La versión web está desplegada en **Firebase Hosting**, mostrando mi familiaridad con el ecosistema de Google.

## ✨ Funcionalidades Implementadas

### **1. Flujo ETL (Python en Cloud Function/Cloud Run):**

*   **Carga en PostgreSQL:**
    *   Diseño de un modelo estrella (`dim_page`, `fact_pageviews_daily`) para datos analíticos.
    *   Creación de la tabla `etl_jobs` para registrar el estado de cada ejecución del ETL desde el frontend.
    *   Lógica de inserción/actualización de datos en las tablas de la base de datos.
    *   Refresco de vistas materializadas post-carga.

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

---

## 🧑‍💻 Autor

*   **Hector Ramírez**
*   heckramirezc@aol.com
*   https://www.linkedin.com/in/heckramirez/
*   http://github.com/heckramirezc/gummybears

---
