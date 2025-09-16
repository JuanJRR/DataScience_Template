# Data Science Template 🚀

## Resumen del Proyecto

Este proyecto es una plantilla de arquitectura de proyectos de ciencia de datos optimizada para la reproducibilidad y la colaboración. El objetivo principal es proporcionar una estructura de archivos estándar, un entorno de desarrollo reproducible con **Dev Containers** y una gestión de dependencias moderna con `pyproject.toml`.

## Características Clave

  * **Entorno Reproducible**: Utiliza Docker y Dev Containers para asegurar que el entorno de desarrollo sea idéntico para todos los colaboradores.
  * **Gestión de Dependencias Moderna**: Las dependencias se gestionan con `pyproject.toml`, separando las librerías de producción de las de desarrollo.
  * **Versionado de Datos**: Integración con **DVC (Data Version Control)** para la gestión y versionado de grandes archivos de datos y modelos.
  * **Organización de Código**: Una estructura de directorios clara que separa el código fuente, los notebooks y los datos.
  * **Automatización de CI/CD**: Flujos de trabajo de GitHub Actions para pruebas automatizadas y gestión de dependencias con Dependabot.

-----

## Estructura del Proyecto

El repositorio sigue una estructura de directorios estándar para proyectos de ciencia de datos.

```
/DATASCIENCE_TEMPLATE
├── .devcontainer/         # Configuración del entorno de desarrollo (devcontainer)
├── .github/               # Workflows de GitHub Actions
├── data/                  # Almacena los datos del proyecto
├── notebooks/             # Cuadernos de Jupyter para la exploración y prototipado
├── src/                   # Código fuente de producción del proyecto
├── tests/                 # Pruebas unitarias para el código
├── .gitignore             # Archivos y directorios a ignorar por Git
├── docker-compose.yml     # Orquestación de servicios Docker
├── pyproject.toml         # Configuración de dependencias y herramientas
├── README.md              # Este archivo
└── dvc.yaml               # Archivo de configuración de DVC
```

-----

## Primeros Pasos 👣

### Requisitos

  * Docker
  * Visual Studio Code
  * La extensión [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) para VS Code.

### Instrucciones

1.  **Clona el repositorio**: `git clone https://github.com/tu_usuario/tu_proyecto.git`
2.  **Abre el proyecto en VS Code**: En la barra lateral, haz clic en **"Reopen in Container"** o utiliza la paleta de comandos (`Ctrl+Shift+P`) y busca "Dev Containers: Reopen in Container".
3.  **Listo para trabajar**: VS Code construirá el contenedor, instalará las dependencias y abrirá el entorno de desarrollo. Tu terminal estará lista y configurada dentro del contenedor.

### Uso

  * **Iniciar Jupyter Lab**: `jupyter lab --ip=0.0.0.0 --allow-root --port=8888 --no-browser`
  * **Ejecutar pruebas**: `pytest`

-----

## Contribuciones 🤝

Agradecemos las contribuciones. Por favor, sigue los siguientes pasos:

1.  Haz un `fork` del repositorio.
2.  Crea una rama (`git checkout -b feature/nueva-caracteristica`).
3.  Realiza tus cambios y haz `commit` (`git commit -m 'feat: agrega nueva caracteristica'`).
4.  Empuja la rama (`git push origin feature/nueva-caracteristica`).
5.  Abre un Pull Request.

-----

## Licencia 📄

Este proyecto está bajo la Licencia GNU GENERAL PUBLIC Version 2. Consulta el archivo `LICENSE` para más detalles.