# Usa a imagem oficial do Emscripten
FROM emscripten/emsdk:latest

# Define o diretório de trabalho interno
WORKDIR /src

# Instala dependências necessárias para compilar o Verilator
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    perl \
    python3 \
    make \
    autoconf \
    g++ \
    flex \
    bison \
    ccache \
    libgoogle-perftools-dev \
    numactl \
    perl-doc \
    libfl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y verilator

CMD ["/bin/bash"]
