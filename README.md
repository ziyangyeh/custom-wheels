# spconv-cumm-wheels

Precompiled `.whl` wheels for `cumm` and `spconv` optimized for **CUDA 13.x** and **RTX 5090** (Blackwell, `sm_120`) architecture, solving the C++17 compilation compatibility issue without modifying any source code.

## 为什么需要这个仓库？
* **CUDA 13.x 的 C++17 强制要求**：CUDA 13.x 包含的 `libcu++` 强制要求至少使用 C++17 标准，而 `cumm` / `spconv` 官方的编译配置在 Linux 上硬编码了 `-std=c++14`，直接编译会报错失败。
* **运行时 JIT 编译缓慢**：官方默认推荐的 `editable` 模式在首次导入包时会触发 JIT 即时编译，耗时较长（编译 800+ 文件大约需要数分钟）。
* **二进制分发（Wheels）**：在此预编译为二进制 Wheels 后，用户安装即可直接加载 `.so` 库，**无需运行时编译，无需安装构建工具，即装即用**。

## 编译及构建流程

如果需要为其他 Python 版本、CUDA 版本或 GPU 算力重新编译 Wheels：

1. **激活您的虚拟环境**（脚本会使用当前环境下的包及 Python 路径）：
   ```bash
   source /path/to/your/.venv/bin/activate
   ```
2. **运行构建脚本**：
   ```bash
   ./build_wheels.sh
   ```
   *该脚本会自动下载官方源码，利用内置的 `bin_wrapper` 编译器包装器将 `-std=c++14` 在编译期透明拦截并升级为 `-std=c++17`，最后将打包好的 `.whl` 输出至 `dist/` 文件夹下。*

## 托管与安装指南

### 1. 免费托管到 GitHub Releases
1. 在 GitHub 上新建一个仓库（例如命名为 `spconv-cumm-wheels`）。
2. 在该 GitHub 仓库的 **Releases** 页面发布一个版本（如 `v0.8.2-v2.3.8`）。
3. 将本仓库 `dist/` 目录下构建好的 `.whl` 二进制文件作为 Release 资源上传。

### 2. 在项目中使用

在项目的 `pyproject.toml` 中，直接使用 GitHub Release 上传的附件直链作为依赖源。例如：

```toml
[tool.uv.sources]
cumm-cu132 = { url = "https://github.com/你的用户名/spconv-cumm-wheels/releases/download/v0.8.2-v2.3.8/cumm_cu132-0.8.2-cp312-cp312-linux_x86_64.whl" }
spconv-cu132 = { url = "https://github.com/你的用户名/spconv-cumm-wheels/releases/download/v0.8.2-v2.3.8/spconv_cu132-2.3.8-cp312-cp312-linux_x86_64.whl" }
```

执行 `uv sync` 后即可一键秒级安装成功，运行代码时无需任何编译器配置。
