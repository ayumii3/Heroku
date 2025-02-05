# -------------------------------
# Etapa de construção
FROM python:3.10-slim AS builder

# Instalar pacotes necessários para o build
RUN apt-get update && \
    apt-get install -y --fix-missing --no-install-recommends git python3-dev gcc curl \
    && rm -rf /var/lib/apt/lists/*

# Clonar o repositório
RUN git clone https://github.com/ayumii3/Heroku.git /Heroku

# Criar ambiente virtual
RUN python -m venv /venv

# Instalar as dependências
RUN /venv/bin/pip install --no-cache-dir -r /Heroku/requirements.txt

# -------------------------------
# Etapa de execução
FROM python:3.10-slim

# Instalar pacotes necessários para rodar o app
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl libcairo2 ffmpeg \
    libmagic1 libavcodec-dev libavutil-dev libavformat-dev \
    libswscale-dev libavdevice-dev neofetch wkhtmltopdf gcc python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js
RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -y nodejs && \
    rm nodesource_setup.sh

# Definir variáveis de ambiente
ENV DOCKER=true \
    GIT_PYTHON_REFRESH=quiet \
    PIP_NO_CACHE_DIR=1

# Copiar a aplicação e o ambiente virtual do estágio de build
COPY --from=builder /Heroku /Heroku
COPY --from=builder /venv /Heroku/venv

# Definir diretório de trabalho
WORKDIR /Heroku

# Expor a porta (se necessário)
EXPOSE 8080

# Definir o comando para rodar o bot
CMD ["/Heroku/venv/bin/python", "-m", "hikka"]