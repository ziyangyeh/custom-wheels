# custom-wheels

科研常用及自定义编译的 Python Wheels 二进制分发仓库。优化并适配特定 Python、CUDA 及 GPU 架构（如 CUDA 13.x 和 RTX 5090 Blackwell `sm_120`）。

## 为什么需要这个仓库？
* **解决编译与版本兼容问题**：部分库（如 `cumm` / `spconv` / `torch-cluster` 等）由于上游维护滞后，在最新的 Python/PyTorch/CUDA 环境下无法直接安装或直接编译报错（例如 CUDA 13.x 的 `libcu++` 强行要求 C++17，而很多旧库硬编码了 `-std=c++14`）。
* **免去运行时 JIT 编译等待**：一些库使用 JIT 编译，在首次导入时会触发长达数分钟的即时编译。预编译成 Wheels 后可实现即装即用。
* **便捷的多机分发与部署**：通过将构建好的 `.whl` 文件上传至 GitHub Releases，在科研服务器或本地开发机上只需通过 `pip` 或 `uv` 配置直链依赖，即可实现一键秒级安装。

## 支持的 Wheels 列表

| 库名称 | 适配环境 | 优化架构 | 备注说明 |
| :--- | :--- | :--- | :--- |
| **`cumm-cu132`** | Python 3.12, CUDA 13.2 | RTX 5090 (`sm_120`) | 强制 C++17 编译以适配 CUDA 13.x |
| **`spconv-cu132`** | Python 3.12, CUDA 13.2 | RTX 5090 (`sm_120`) | 依赖于 `cumm`，解决 Blackwell 兼容性 |
| **`torch-cluster`** | Python 3.12, PyTorch 2.12.0+cu132 | RTX 5090 (`sm_120`) | PyTorch Geometric 扩展库，采用 Ninja 并行加速编译 |

## 编译及构建流程

如果需要为其他 Python 版本、CUDA 版本或 GPU 算力重新编译 Wheels：

1. **激活您的虚拟环境**（脚本会使用当前环境下的 Python 及已安装的 PyTorch 等包）：
   ```bash
   source /path/to/your/.venv/bin/activate
   ```
2. **运行构建脚本**：
   ```bash
   ./build_wheels.sh
   ```
   *该脚本会自动下载官方源码，应用必要的补丁和环境参数，并输出打包好的 `.whl` 二进制文件至 `dist/` 文件夹下。*

## 托管与安装指南

### 1. 免费托管到 GitHub Releases
1. 在 GitHub 上新建一个仓库，命名为 `custom-wheels`。
2. 在该 GitHub 仓库的 **Releases** 页面发布一个版本（例如 `v0.1.0`）。
3. 将本仓库 `dist/` 目录下构建好的 `.whl` 二进制文件作为 Release 资源上传。

### 2. 在项目中使用

在您项目的 `pyproject.toml` 中，直接使用 GitHub Release 上传的附件直链作为依赖源。例如：

```toml
[tool.uv.sources]
cumm-cu132 = { url = "https://github.com/你的用户名/custom-wheels/releases/download/v0.1.0/cumm_cu132-0.8.2-cp312-cp312-linux_x86_64.whl" }
spconv-cu132 = { url = "https://github.com/你的用户名/custom-wheels/releases/download/v0.1.0/spconv_cu132-2.3.8-cp312-cp312-linux_x86_64.whl" }
torch-cluster = { url = "https://github.com/你的用户名/custom-wheels/releases/download/v0.1.0/torch_cluster-1.6.3-cp312-cp312-linux_x86_64.whl" }
```

执行 `uv sync` 后即可一键秒级安装成功，运行代码时无需任何编译器配置。
