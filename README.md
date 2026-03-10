# Data Science Template

## Resumen del Proyecto

Este proyecto es una plantilla de arquitectura de ciencia de datos de alto rendimiento, optimizada para la reproducibilidad, la aceleración por hardware y la colaboración eficiente. Proporciona un entorno preconfigurado con `NVIDIA CUDA 12.8` y una gestión de dependencias moderna mediante `pyproject.toml`

## Características Clave

* **Entorno de Alto Rendimiento:** Basado en `Ubuntu 24.04` con soporte nativo para GPUs NVIDIA y capacidades de cómputo, utilidad y video.
* **Gestión de Dependencias Moderna:** Control centralizado de librerías de producción y desarrollo (como ruff, pytest y dvc) en un solo manifiesto.
* **Optimización para Deep Learning:** Configuración de memoria compartida (shm_size: 4gb) y límites de memoria relajados (12GB) para entrenamientos pesados.
* **Calidad de Código Automatizada:** Integración de Ruff para linting rápido compatible con NumPy 2.x.
* **Experiencia "One-Click":** Configuración de Dev Containers que instala automáticamente extensiones críticas de VS Code (Python, Jupyter, Pylance, DVC, Tensorboard).

-----

## Estructura del Proyecto

El repositorio sigue una organización profesional para separar la infraestructura del código científico:

```
/DATASCIENCE_TEMPLATE
├── .devcontainer/       # Configuración de VS Code (extensiones y runtime) 
├── data/                # Almacenamiento de datasets (gestionado por DVC)
├── notebooks/           # Experimentación y prototipado en Jupyter
├── src/                 # Código fuente (añadido automáticamente al PYTHONPATH) 
├── tests/               # Pruebas unitarias con Pytest
├── docker-compose.yml   # Orquestación de servicios, GPU y volúmenes 
├── Dockerfile           # Receta de la imagen base (CUDA + Dependencias) 
├── pyproject.toml       # Dependencias (Pandas, PyTorch, Scikit-Learn, etc.) 
└── .env                 # Variables de entorno (Cargadas automáticamente)
```
-----

## Primeros Pasos 👣

### Requisitos

  * Docker y Docker Compose.
  * NVIDIA Container Toolkit (para soporte de GPU).
  * VS Code con la extensión [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Instrucciones

1.  **Clona el repositorio:** `git clone https://github.com/JuanJRR/DataScience_Template.git`
2.  **Configura el entorno:** Crea un archivo `.env` basado en tus necesidades (el contenedor lo cargará automáticamente).
3. Abre en VS Code: Haz clic en `Reopen in Container` cuando aparezca la notificación.
4. Listo para trabajar: El sistema instalará automáticamente las dependencias del sistema y de Python en el contenedor.

### Uso Común

  * **Jupyter Lab/Notebooks:** Accede vía puerto 8888 (mapeado en el host).
  * **Tensorboard:** Visualiza tus entrenamientos en el puerto 6006.
  * **Ejecutar Pruebas:** Simplemente corre pytest en la terminal integrada.
  * **Linting:** Ruff se ejecutará automáticamente según las reglas definidas (target Python 3.12).

-----
### Licencia

Este proyecto está bajo la Licencia GNU GENERAL PUBLIC Version 2 (indicada en el archivo LICENSE).

----
## Contribuciones 🤝

Agradecemos las contribuciones. Por favor, sigue los siguientes pasos:

1.  Haz un `fork` del repositorio.
2.  Crea una rama (`git checkout -b feature/nueva-caracteristica`).
3.  Realiza tus cambios y haz `commit` (`git commit -m 'feat: agrega nueva caracteristica'`).
4.  Empuja la rama (`git push origin feature/nueva-caracteristica`).
5.  Abre un Pull Request.
