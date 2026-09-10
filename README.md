# Container image source for PHYS-225A

You can obtain a copy of this image by running:
```bash
podman pull ucsb/phys225a:latest
```

### 🛠️  Using the Conda Environments
This image contains multiple specialized Conda environments. To use the tools, you must first identify the environment you need and then activate it.

**1. List available environments:**
```bash
conda env list
```

**2. Activate the environment you need:**
```bash
conda activate hep
```

**3. Deactivate (return to base):**
```bash
conda deactivate
```

> **💡 JupyterLab Tip:** If you are working in a notebook, you can skip the terminal! Simply use the **Kernel** dropdown menu in the top-right corner of your browser to switch between the `hep` or other environments.
