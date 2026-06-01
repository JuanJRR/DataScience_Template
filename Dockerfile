# ── Etapa 1: builder ─────────────────────────────────────────────────────────
# Instala y compila todas las dependencias Python.
# Esta capa NO se incluye en la imagen final de producción.
FROM nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04 AS builder

# Versión de Python: fijada para reproducibilidad científica
ARG PYTHON_VERSION=3.12

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    # uv: no crear entornos virtuales dentro del builder (instalamos en /opt/venv)
    UV_NO_CACHE=1 \
    UV_SYSTEM_PYTHON=0 \
    UV_PROJECT_ENVIRONMENT=/opt/venv

# Instalar dependencias mínimas del sistema para compilar extensiones C/C++
RUN apt-get update && apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv \
    build-essential \
    # Necesario para compilar extensiones con soporte CUDA (ej: custom ops)
    ninja-build \
    cmake \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar uv (gestor de paquetes ultrarrápido, reemplaza pip en velocidad)
# https://github.com/astral-sh/uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Crear entorno virtual aislado
RUN python${PYTHON_VERSION} -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# ── Instalar PyTorch con wheel CUDA explícito ─────────────────────────────────
# CRÍTICO: instalar PyTorch ANTES del resto de deps para que uv use la versión
# correcta al resolver el grafo. Sin esto, pip puede instalar la CPU wheel.
ARG TORCH_VERSION=2.12.0
# ARG TORCH_CUDA_INDEX=https://download.pytorch.org/whl/cu124

RUN uv pip install \
    torch==${TORCH_VERSION}+cu124 \
    torchvision \
    torchaudio
    # --index-url ${TORCH_CUDA_INDEX}

# ── Copiar solo los archivos de dependencias (optimiza caché de capas) ─────────
WORKDIR /build
COPY pyproject.toml .
# Si tienes uv.lock o requirements.lock, cópialo aquí:
# COPY uv.lock .

# Instalar dependencias del proyecto (sin código fuente)
# --no-install-project: evita instalar el paquete en sí, solo sus deps
RUN uv pip install --no-cache-dir ".[dev]"

# =============================================================================
# ── Etapa 2: development ─────────────────────────────────────────────────────
# Imagen completa con herramientas de desarrollo: JupyterLab, TensorBoard, etc.
# Esta es la imagen que usa el devcontainer de VSCode.
# =============================================================================
FROM nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04 AS development

ARG PYTHON_VERSION=3.12
ARG USERNAME=researcher
ARG USER_UID=1000
ARG USER_GID=1000

# ── Variables de entorno ──────────────────────────────────────────────────────
ENV TZ=America/Sao_Paulo \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app/src \
    PATH="/opt/venv/bin:$PATH" \
    # ── Rendimiento CUDA ──
    # Permite que el allocator de PyTorch reutilice memoria fragmentada.
    # En la RTX 4090 con 16 GB VRAM, esto reduce los OOM en batches grandes.
    PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True,max_split_size_mb:512" \
    # Deshabilitar TF32 para mayor precisión numérica (activar si priorizas velocidad)
    # TORCH_ALLOW_TF32_CUBLAS_OVERRIDE=1 \
    # Silenciar logs irrelevantes de TF/CUDA
    TF_CPP_MIN_LOG_LEVEL=3 \
    CUDA_DEVICE_ORDER=PCI_BUS_ID \
    # NCCL: configuración para entrenamiento distribuido futuro
    NCCL_DEBUG=WARN \
    NCCL_IB_DISABLE=1 \
    # OpenCV headless no necesita display
    DISPLAY="" \
    # NumPy: aprovechar todos los threads del i9-14900HX (32 lógicos)
    OMP_NUM_THREADS=16 \
    MKL_NUM_THREADS=16

# ── Dependencias del sistema ──────────────────────────────────────────────────
# Agrupadas por categoría y con comentarios para auditabilidad
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Python
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv \
    # Compilación (necesario para algunas extensiones en runtime)
    build-essential \
    ninja-build \
    # Multimedia / OpenCV / señales de audio
    ffmpeg \
    libsm6 \
    libxext6 \
    libgl1 \
    libglib2.0-0 \
    libsndfile1 \
    libportaudio2 \
    # HDF5 (para datasets grandes: medical imaging, audio)
    libhdf5-dev \
    # Hardware / USB (ISAC y dispositivos de captura)
    usbutils \
    # Utilidades de red y sistema
    iproute2 \
    curl \
    wget \
    git \
    git-lfs \
    # Herramientas de profiling GPU
    nvtop \
    # Editor de texto mínimo para debugging en contenedor
    nano \
    && rm -rf /var/lib/apt/lists/*

# ── Crear usuario no-root ─────────────────────────────────────────────────────
# SEGURIDAD: nunca ejecutar como root en producción.
# En devcontainer se puede sobreescribir con remoteUser si se necesita USB.
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && apt-get update \
    && apt-get install -y --no-install-recommends sudo \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && rm -rf /var/lib/apt/lists/*

# ── Copiar entorno virtual compilado desde el builder ─────────────────────────
COPY --from=builder /opt/venv /opt/venv

# ── Instalar herramientas de desarrollo adicionales ───────────────────────────
# Estas NO van al builder (son solo para desarrollo interactivo)
RUN uv pip install --no-cache-dir \
    jupyterlab>=4.3 \
    jupyterlab-git \
    ipywidgets \
    tensorboard>=2.19 \
    # Profiling GPU dentro de notebooks
    torch-tb-profiler \
    # # MLOps (opcionales, comentar si no se usan)
    # mlflow>=2.20 \
    # dvc ya está en pyproject.toml [dev]
    # Herramientas de análisis de rendimiento
    py-spy \
    memory-profiler

WORKDIR /app

# ── Copiar código fuente ──────────────────────────────────────────────────────
# Va al final para no invalidar el caché de dependencias
COPY --chown=${USERNAME}:${USERNAME} . .

# ── Script de inicio ──────────────────────────────────────────────────────────
COPY --chown=${USERNAME}:${USERNAME} scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER ${USERNAME}

EXPOSE 8888 6006 5000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]

# =============================================================================
# ── Etapa 3: production ──────────────────────────────────────────────────────
# Imagen mínima para inferencia. Sin Jupyter, sin herramientas de dev.
# Usar cuda-runtime en lugar de devel para reducir ~3 GB de tamaño.
# =============================================================================
FROM nvidia/cuda:13.0.2-runtime-ubuntu24.04 AS production

ARG PYTHON_VERSION=3.12
ARG USERNAME=researcher
ARG USER_UID=1000
ARG USER_GID=1000

ENV TZ=America/Sao_Paulo \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app/src \
    PATH="/opt/venv/bin:$PATH" \
    PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True" \
    TF_CPP_MIN_LOG_LEVEL=3 \
    CUDA_DEVICE_ORDER=PCI_BUS_ID \
    OMP_NUM_THREADS=8

RUN apt-get update && apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libsndfile1 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}

# Solo el entorno virtual compilado, sin herramientas de dev
COPY --from=builder /opt/venv /opt/venv

WORKDIR /app
COPY --chown=${USERNAME}:${USERNAME} src/ ./src/

USER ${USERNAME}

# Healthcheck: verifica que la GPU es accesible al iniciar el contenedor
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD python -c "import torch; assert torch.cuda.is_available(), 'GPU no disponible'; print('GPU OK:', torch.cuda.get_device_name(0))"

CMD ["python", "-m", "src.inference"]