FROM ubuntu:18.04

LABEL maintainer="egibson"
ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# 1. Install Python 3.8 and tools
# -----------------------------

RUN apt-get update && apt-get install -y \
    software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    python3.8 \
    python3.8-dev \
    python3.8-distutils \
    python3-pip \
    wget \
    git \
    curl \
    unzip \
    ca-certificates \
    libgl1 \
    && apt-get clean

# -----------------------------
# 2. Fix pip installation for Python 3.8
# -----------------------------

# 1. Download get-pip.py
RUN wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py

# 2. Install pip for Python 3.8
RUN python3.8 /tmp/get-pip.py

# 3. Symlink python and pip
RUN ln -sf /usr/bin/python3.8 /usr/local/bin/python && \
    ln -sf /usr/bin/python3.8 /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip

# -----------------------------
# 3. Install SynthSeg dependencies (CPU)
# -----------------------------

RUN python -m pip install \
    keras==2.3.1 \
    numpy==1.19.5 \
    nibabel==3.2.2 \
    matplotlib==3.3.4 \
    tensorflow==2.2.0 \
    protobuf==3.20.*

# -----------------------------
# 4. Clone SynthSeg and install
# -----------------------------

RUN git clone https://github.com/BBillot/SynthSeg.git /opt/SynthSeg


# -----------------------------
# 5. Copy pre-downloaded models into the container
# -----------------------------

COPY models/ /opt/SynthSeg/models/

# -----------------------------
# 7. ENTRYPOINT
# -----------------------------

WORKDIR /
ENTRYPOINT ["python", "/opt/SynthSeg/scripts/commands/SynthSeg_predict.py"]
  
