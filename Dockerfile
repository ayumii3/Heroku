# Etapa 1: Construção da imagem com as dependências
FROM python:3.10-slim AS builder

# Desabilita o cache do pip para reduzir o tamanho da imagem
ENV PIP_NO_CACHE_DIR=1

# Instala dependências do sistema para construção
RUN apt-get update && \
    apt-get install -y --fix-missing --no-install-recommends git python3-dev gcc \
    && rm -rf /var/lib/apt/lists/ /var/cache/apt/archives/ /tmp/*

# Clona o repositório (garanta que esse comando seja necessário para o seu bot)
RUN git clone https://github.com/coddrago/Heroku /Heroku

# Cria um ambiente virtual Python
RUN python -m venv /venv

# Copia o arquivo requirements.txt e instala as dependências
COPY /Heroku/requirements.txt /Heroku/requirements.txt
RUN /venv/bin/pip install --no-warn-script-location --no-cache-dir -r /Heroku/requirements.txt

# Etapa 2: Imagem final com a aplicação
FROM python:3.10-slim

# Instala pacotes do sistema, como o ffmpeg
RUN apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
    curl libcairo2 git ffmpeg libmagic1 \
    libavcodec-dev libavutil-dev libavformat-dev \
    libswscale-dev libavdevice-dev neofetch wkhtmltopdf gcc python3-dev \
    && rm -rf /var/lib/apt/lists/ /var/cache/apt/archives/ /tmp/*

# Instala o Node.js
RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -y nodejs && \
    rm nodesource_setup.sh

# Configura variáveis de ambiente
ENV DOCKER=true \
    GIT_PYTHON_REFRESH=quiet \
    PIP_NO_CACHE_DIR=1

# Copia os arquivos da etapa de construção
COPY --from=builder /Heroku /Heroku
COPY --from=builder /venv /Heroku/venv

# Define o diretório de trabalho
WORKDIR /Heroku

# Exclui a camada de instalação de dependências se já existir
# Ao usar o Docker, se o requirements.txt não for alterado, as dependências não serão instaladas novamente

# Define o comando de execução do bot
CMD ["/Heroku/venv/bin/python", "-m", "hikka"]