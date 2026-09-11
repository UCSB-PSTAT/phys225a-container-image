FROM registry.cloud.college.ucsb.edu/ucsb/scipy-base:latest

MAINTAINER LSIT Systems <lsitops@lsit.ucsb.edu>

USER root

ENV FINDINGZ_MG5=/opt/conda/envs/hep/MG5_aMC/bin/mg5_aMC \
    FINDINGZ_PYTHIA8_DIR=/opt/conda/envs/hep \
    FINDINGZ_DELPHES_DIR=/opt/conda/envs/hep/bin \
    FINDINGZ_CARD_ROOT=/opt/conda/envs/hep \
    FINDINGZ_CATALOG_PATH=/home/jovyan/course-materials/config/course_catalog.yaml \
    FINDINGZ_VARIABLES_PATH=/home/jovyan/course-materials/config/analysis_variables.yaml \
    FINDINGZ_RUN_ROOT=/home/jovyan/findingz-runs

RUN mamba install -y -c conda-forge --freeze-installed\
    jupyterthemes jupyter-server-proxy &&\
    mamba create -n hep -y -c conda-forge -c hep-forge\
    delphes\
    mg5amcnlo\
    mg5amcnlo-pythia8-interface\
    pythia8\
    root\
    scikit-hep\
    streamlit &&\
    mamba run -n hep pip install --no-cache-dir 'findingz[hep] @ git+https://github.com/prateekagrawal/findingz.git' &&\
    mamba clean -afy &&\
    /usr/local/bin/fix-permissions "${CONDA_DIR}" || true

COPY extra_config.py /tmp/

RUN cat /tmp/extra_config.py >> /etc/jupyter/jupyter_server_config.py &&\
    curl -O https://streamlit.io/images/brand/streamlit-mark-color.svg --output-dir /opt &&\
    echo "source \${CONDA_DIR}/etc/profile.d/conda.sh" >> /etc/bash.bashrc &&\
    echo "delphes_path = /opt/conda/envs/hep/bin/" >> /opt/conda/envs/hep/MG5_aMC/input/mg5_configuration.txt &&\
    echo "1000 = nevents" >> /opt/conda/envs/hep/MG5_aMC/Template/LO/Cards/run_card.dat &&\
    jupyter server extension enable --sys-prefix jupyter_server_proxy

USER $NB_USER
