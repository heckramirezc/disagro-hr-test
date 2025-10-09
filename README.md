# Prueba Técnica: Flujo ETL y API de (Pageviews de Wikipedia)

## 🚀 Resumen del Proyecto

Este proyecto es la resolución de una prueba técnica para el puesto de Desarrollador(a) Full Stack en DISAGRO. El objetivo principal es construir un **flujo ETL (Extract, Transform, Load)** robusto en Python, que procese datos públicos de BigQuery (Wikipedia Pageviews), almacene los resultados en una base de datos relacional y exponga una **API RESTful** para consultas de negocio.

Además, he incorporado una **aplicación frontend multi-plataforma desarrollada en Flutter**, demostrando la integración completa de la solución y mi capacidad para construir aplicaciones de extremo a extremo (Full Stack) que cumplen con los requisitos funcionales y de presentación.

El desarrollo, seguimiento y gestión de tareas de este proyecto fueron realizados utilizando [**GitHub Issues y GitHub Projects**](https://github.com/users/heckramirezc/projects/1) dentro de este repositorio, lo que refleja un enfoque organizado y transparente en el proceso de desarrollo.

## 🛠️ Tecnologías Utilizadas y Justificación Estratégica

La elección de las tecnologías ha sido cuidadosamente considerada para cumplir con los requisitos de la prueba, optimizar el tiempo de desarrollo (aprovechando mi experiencia) y demostrar la versatilidad de un perfil Full Stack alineado con las menciones tecnológicas de la descripción del puesto.

*   **1. Extracción (E) y Transformación (T):**
    *   **Tecnología:** `Python` con `pandas` y la librería `google-cloud-bigquery`.
    *   **Justificación:** Requisito explícito de la prueba. Python es la herramienta ideal para el procesamiento y manipulación de datos a gran escala gracias a su ecosistema robusto (especialmente `pandas`) y su integración nativa con BigQuery.

*   **2. Carga (L) y Almacenamiento de Datos:**
    *   **Tecnología:** `PostgreSQL` (ejecutado en Docker)
    *   **Justificación:** PostgreSQL es una base de datos relacional altamente robusta, escalable y con excelente soporte para modelos de datos complejos (como el modelo estrella solicitado). Es una elección moderna y profesional que se integra bien con el ecosistema de Google Cloud Platform (GCP) a través de servicios como Cloud SQL, ofreciendo una ruta clara a producción. Mi experiencia con otras bases de datos SQL facilita su implementación y gestión.

*   **3. API de Datos:**
    *   **Tecnología:** `Node.js` con el framework `NestJS` (TypeScript).
    *   **Justificación:** Aunque la prueba permitía "lenguaje a tu elección", opté por NestJS para la API debido a mi sólida experiencia en Node.js y TypeScript, y la mención de NestJS en la entrevista. Esto me permite construir una API de alta calidad de manera eficiente, aprovechando su diseño modular y fuertemente tipado. Además, NestJS ofrece una excelente escalabilidad para operaciones I/O-bound (como servir datos de la base de datos) y se alinea directamente con las tecnologías de la empresa.

*   **4. Frontend (Visualización de Datos):**
    *   **Tecnología:** `Flutter` (para Web y Móvil).
    *   **Justificación:** Aunque no explícitamente requerido en el documento, se mencionó el frontend en la entrevista. Aprovechando mi experiencia en Flutter y la versatilidad de la plataforma, construí un frontend multi-plataforma. Esto demuestra mi capacidad Full Stack, mi dominio de Flutter (mencionado como de interés en DISAGRO), y cómo integrar la solución completa. La versión web está desplegada en **Firebase Hosting**, mostrando mi familiaridad con el ecosistema de Google.

---

## 🧑‍💻 Autor

*   **Hector Ramírez**
*   heckramirezc@aol.com
*   https://www.linkedin.com/in/heckramirez/
*   http://github.com/heckramirezc/gummybears

---
