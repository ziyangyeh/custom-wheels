# custom-wheels

A repository for precompiled and custom-built Python wheels tailored for research and scientific computing. These wheels are optimized for specific Python, PyTorch, CUDA, and GPU architectures (such as CUDA 13.2 and RTX 5090 Blackwell `sm_120`).

## Why this repository?
* **Resolve Compilation & Compatibility Issues**: Some packages (e.g., `cumm`, `spconv`, and `torch-cluster`) are not updated frequently by their upstream authors, leading to compile/install errors in newer environments (e.g., CUDA 13.x's `libcu++` strictly requires C++17, whereas many older packages hardcode `-std=c++14`).
* **Eliminate Runtime JIT Compile Overhead**: Certain libraries default to editable/source installations that trigger a JIT compilation upon the first import. Precompiling these libraries into wheels allows instant loading.
* **Easy Distribution**: Distribute built wheel binaries across multiple research servers/workstations easily using direct URL links to GitHub Release assets with package managers like `pip` or `uv`.

## Supported Wheels

| Package | Environment | Target Arch | Notes / Workarounds |
| :--- | :--- | :--- | :--- |
| **`cumm-cu132`** | Python 3.12, CUDA 13.2 | RTX 5090 (`sm_120`) | Compiles using a wrapper to enforce C++17 compatibility |
| **`spconv-cu132`** | Python 3.12, CUDA 13.2 | RTX 5090 (`sm_120`) | Depends on `cumm`; resolves Blackwell GPU compatibility |
| **`torch-cluster`** | Python 3.12, PyTorch 2.12.0+cu132 | RTX 5090 (`sm_120`) | PyG extension; compiled using Ninja parallel build for speed |

## Build Instructions

If you need to rebuild the wheels for a different Python version, CUDA version, or GPU architecture:

1. **Activate your virtual environment** (the build script automatically uses the Python and PyTorch path in your active environment):
   ```bash
   source /path/to/your/.venv/bin/activate
   ```
2. **Run the build script**:
   ```bash
   ./build_wheels.sh
   ```
   *This script will clone the upstream repositories, apply necessary environment/compilation options, and output the packaged `.whl` files to the `dist/` directory.*

## Hosting & Installation Guide

### 1. Hosting on GitHub Releases
1. Create a repository on GitHub named `custom-wheels`.
2. Draft a new release (e.g., `v0.8.2-v2.3.8`) on the repository's **Releases** page.
3. Upload the `.whl` binaries from the `dist/` directory as release assets.

### 2. Integration in Your Project

In your project's `pyproject.toml`, specify the direct URLs of the uploaded wheel assets under `[tool.uv.sources]`. For example:

```toml
[tool.uv.sources]
cumm-cu132 = { url = "https://github.com/your-username/custom-wheels/releases/download/v0.8.2-v2.3.8/cumm_cu132-0.8.2-cp312-cp312-linux_x86_64.whl" }
spconv-cu132 = { url = "https://github.com/your-username/custom-wheels/releases/download/v0.8.2-v2.3.8/spconv_cu132-2.3.8-cp312-cp312-linux_x86_64.whl" }
torch-cluster = { url = "https://github.com/your-username/custom-wheels/releases/download/v0.8.2-v2.3.8/torch_cluster-1.6.3-cp312-cp312-linux_x86_64.whl" }
```

After configuring, run `uv sync` to install all custom wheels in seconds without configuring compiler settings.
