#!/bin/bash
# Script to compile cumm and spconv wheels for CUDA 13.x compatibility
set -e

# Setup parameters (Update as needed)
CUDA_VERSION="13.2"
CUDA_ARCH_LIST="12.0" # RTX 5090 Blackwell

# 1. Setup temporary compiler wrappers to enforce C++17 (CUDA 13.x libcu++ requirement)
mkdir -p bin_wrapper
cat << 'EOF' > bin_wrapper/g++
#!/bin/bash
args=()
for arg in "$@"; do
    if [ "$arg" = "-std=c++14" ]; then
        args+=("-std=c++17")
    else
        args+=("$arg")
    fi
done
exec /usr/bin/g++ "${args[@]}"
EOF
chmod +x bin_wrapper/g++

cat << 'EOF' > bin_wrapper/gcc
#!/bin/bash
args=()
for arg in "$@"; do
    if [ "$arg" = "-std=c++14" ]; then
        args+=("-std=c++17")
    else
        args+=("$arg")
    fi
done
exec /usr/bin/gcc "${args[@]}"
EOF
chmod +x bin_wrapper/gcc

cat << 'EOF' > bin_wrapper/nvcc
#!/bin/bash
args=()
for arg in "$@"; do
    if [ "$arg" = "-std=c++14" ]; then
        args+=("-std=c++17")
    else
        args+=("$arg")
    fi
done
exec /usr/local/cuda/bin/nvcc "${args[@]}"
EOF
chmod +x bin_wrapper/nvcc

# Get absolute path of bin_wrapper
WRAPPER_PATH="$(cd bin_wrapper && pwd)"

# Detect active virtualenv or ask user to activate it
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Error: Please activate your Python virtual environment (e.g. .venv) first."
    exit 1
fi
VENV_BIN="$VIRTUAL_ENV/bin"

# 2. Add wrappers and virtualenv bin to PATH
export PATH="$WRAPPER_PATH:$VENV_BIN:$PATH"
export CUMM_CUDA_VERSION="$CUDA_VERSION"
export CUMM_CUDA_ARCH_LIST="$CUDA_ARCH_LIST"
export TORCH_CUDA_ARCH_LIST="$CUDA_ARCH_LIST"

# 3. Clone / build cumm
if [ ! -d "cumm" ]; then
    git clone https://github.com/FindDefinition/cumm.git
fi
cd cumm
export CUMM_DISABLE_JIT=1
python setup.py bdist_wheel
cd ..

# Install built cumm wheel so spconv setup can import it
cumm_wheel=$(ls cumm/dist/*.whl)
pip install "$cumm_wheel" --force-reinstall

# 4. Clone / build spconv
if [ ! -d "spconv" ]; then
    git clone https://github.com/traveller59/spconv.git --recursive
fi
cd spconv
export SPCONV_DISABLE_JIT=1
python setup.py bdist_wheel
cd ..

# 5. Clone / build pytorch_cluster
if [ ! -d "pytorch_cluster" ]; then
    git clone https://github.com/rusty1s/pytorch_cluster.git --recursive
fi
cd pytorch_cluster
# Enable Ninja for faster compilation
sed -i "s/use_ninja=False/use_ninja=True/g" setup.py
export FORCE_CUDA=1
python setup.py bdist_wheel
cd ..

# 6. Move built wheels to dist/ directory
mkdir -p dist
mv cumm/dist/*.whl dist/
mv spconv/dist/*.whl dist/
mv pytorch_cluster/dist/*.whl dist/

# Cleanup wrappers
rm -rf bin_wrapper

echo "==========================================="
echo "Wheels built successfully in dist/ directory!"
echo "==========================================="
