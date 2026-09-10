FROM registry.cloud.college.ucsb.edu/ucsb/scipy-base:latest

MAINTAINER LSIT Systems <lsitops@lsit.ucsb.edu>

USER root

RUN mamba install -y -c conda-forge\
    jupyterthemes jupyter-server-proxy&&\
    mamba create -n hep -y -c conda-forge -c hep-forge\
    delphes\
    mg5amcnlo\
    mg5amcnlo-pythia8-interface\
    pythia8\
    root\
    scikit-hep\
    streamlit &&\
    mamba clean -afy &&\
    /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

COPY extra_config.py /tmp/

RUN cat /tmp/extra_config.py >> /etc/jupyter/jupyter_server_config.py &&\
    curl -O https://streamlit.io/images/brand/streamlit-mark-color.svg --output-dir /opt

RUN jupyter server extension enable --sys-prefix jupyter_server_proxy


USER $NB_USER
