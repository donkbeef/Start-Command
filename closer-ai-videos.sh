#!/bin/bash
set -uo pipefail

source /venv/main/bin/activate

WORKSPACE=${WORKSPACE:-/workspace}
COMFYUI_DIR="${WORKSPACE}/ComfyUI"
HF_TOKEN="${HF_TOKEN:-}"

echo "=== ComfyUI запуск ==="

APT_PACKAGES=(
    git-lfs
    wget
)

PIP_PACKAGES=()

NODES=(
   "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/chflame163/ComfyUI_LayerStyle"
    "https://github.com/donkbeef/custom-nodes"
    "https://github.com/PGCRT/CRT-Nodes CRT-Nodes-PGCRT"
    "https://github.com/Jasonzzt/ComfyUI-CacheDiT"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/facok/comfyui-meancache-z"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/ClownsharkBatwing/RES4LYF"
    "https://github.com/chrisgoringe/cg-use-everywhere"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
    "https://github.com/Smirnov75/ComfyUI-mxToolkit"
    "https://github.com/ZhiHui6/zhihui_nodes_comfyui"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/crystian/ComfyUI-Crystools"
    "https://github.com/plugcrypt/CRT-Nodes CRT-Nodes-plugcrypt"
    "https://github.com/EllangoK/ComfyUI-post-processing-nodes"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/kijai/ComfyUI-WanAnimatePreprocess"
    "https://github.com/GACLove/ComfyUI-VFI"
)

LORA_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_T2V_14B_cfg_step_distill_v2_lora_rank256_bf16.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Pusa/Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors"
    "https://huggingface.co/alibaba-pai/Wan2.2-Fun-Reward-LoRAs/resolve/main/Wan2.2-Fun-A14B-InP-low-noise-MPS.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_animate_14B_relight_lora_bf16.safetensors"
)

VAE_MODELS=(
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors"
)

CLIP_VISION_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"
)

TEXT_ENCODER_MODELS=(
    "https://huggingface.co/lehychh/Wan-animate-v2v/resolve/main/clip/umt5_xxl_fp16.safetensors"
)

UPSCALE_MODELS=(
    "https://huggingface.co/lehychh/Wan-animate-v2v/resolve/main/controlnet/Wan21_Uni3C_controlnet_fp16.safetensors"
)

WAN_ANIMATE_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_animate_14B_bf16.safetensors"
)

LORA_MODELS_EXTRA=(
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors"
    "https://huggingface.co/alibaba-pai/Wan2.2-Fun-Reward-LoRAs/resolve/main/Wan2.2-Fun-A14B-InP-low-noise-HPS2.1.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Pusa/Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors"
)

TEXT_ENCODER_FP8=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"
)

VAE_MODELS_NEW=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"
)

CLIP_VISION_NEW=(
    "https://huggingface.co/lehychh/Wan-animate-v2v/resolve/main/clip_vision/clip_vision_h.safetensors"
)

DETECTION_MODELS=(
    "https://huggingface.co/lehychh/Wan-animate-v2v/resolve/main/detection/vitpose_h_wholebody_model.onnx"
    "https://huggingface.co/lehychh/Wan-animate-v2v/resolve/main/detection/vitpose_h_wholebody_data.bin"
    "https://huggingface.co/lehychh/Wan-animate-v2v/resolve/main/detection/yolov10m.onnx", "detection"
)

WORKFLOW_FILES=(
    "https://huggingface.co/lehychh/closer-ai-workflows/resolve/main/workflow_heaven_2.json"
    "https://huggingface.co/lehychh/closer-ai-workflows/resolve/main/lipsyncmode.json"
    "https://huggingface.co/lehychh/closer-ai-workflows/resolve/main/WanAnimate-movement.json"
    "https://huggingface.co/lehychh/closer-ai-workflows/resolve/main/WanAnimate-static.json"
)

function provisioning_start() {
    provisioning_get_apt_packages
    provisioning_clone_comfyui
    provisioning_install_base_reqs
    provisioning_get_nodes
    provisioning_get_models
    provisioning_get_workflows
    provisioning_get_pip_packages
}

function provisioning_get_apt_packages() {
    if [[ ${#APT_PACKAGES[@]} -gt 0 ]]; then
        local SUDO=()
        if [[ "$(id -u)" -ne 0 ]]; then
            SUDO=(sudo)
        fi

        "${SUDO[@]}" apt-get update
        "${SUDO[@]}" apt-get install -y "${APT_PACKAGES[@]}"

        git lfs install || true
    fi
}

function provisioning_clone_comfyui() {
    if [[ ! -d "${COMFYUI_DIR}/.git" ]]; then
        rm -rf "${COMFYUI_DIR}"
        git clone https://github.com/comfyanonymous/ComfyUI.git "${COMFYUI_DIR}"
    fi

    cd "${COMFYUI_DIR}"
    git fetch origin
    git reset --hard origin/master
}

function provisioning_install_base_reqs() {
    cd "${COMFYUI_DIR}"

    if [[ -f requirements.txt ]]; then
        pip install --no-cache-dir -r requirements.txt
    fi
}

function provisioning_get_nodes() {
    echo "=== Устанавливаем custom nodes ==="

    mkdir -p "${COMFYUI_DIR}/custom_nodes"
    cd "${COMFYUI_DIR}/custom_nodes"

    for entry in "${NODES[@]}"; do
        repo="${entry%% *}"
        custom_dir="${entry#* }"

        if [[ "${custom_dir}" == "${repo}" ]]; then
            custom_dir="${repo##*/}"
        fi

        path="./${custom_dir}"

        echo "=== Node: ${custom_dir} ==="

        if [[ -d "${path}/.git" ]]; then
            (cd "${path}" && git pull --ff-only) || echo "WARN: не удалось обновить ${custom_dir}, пропускаю"
        else
            git clone --recursive "${repo}" "${path}" || echo "WARN: не удалось клонировать ${repo}, продолжаю"
        fi

        if [[ -f "${path}/requirements.txt" ]]; then
            pip install --no-cache-dir -r "${path}/requirements.txt" || echo "WARN: requirements failed for ${custom_dir}, продолжаю"
        fi
    done
}

function provisioning_get_pip_packages() {
    if [[ ${#PIP_PACKAGES[@]} -gt 0 ]]; then
        pip install --no-cache-dir "${PIP_PACKAGES[@]}"
    fi
}

function download_files() {
    local dir="$1"
    shift

    mkdir -p "$dir"

    for url in "$@"; do
        echo "=== Downloading to ${dir}: ${url} ==="

        if [[ -n "${HF_TOKEN:-}" && "$url" == *"huggingface.co"* ]]; then
            wget \
                --header="Authorization: Bearer ${HF_TOKEN}" \
                --tries=5 \
                --timeout=60 \
                -c \
                --content-disposition \
                -P "$dir" \
                "$url" || echo "WARN: не удалось скачать ${url}, продолжаю"
        else
            wget \
                --tries=5 \
                --timeout=60 \
                -c \
                --content-disposition \
                -P "$dir" \
                "$url" || echo "WARN: не удалось скачать ${url}, продолжаю"
        fi
    done
}

function provisioning_get_models() {
    echo "=== Загружаем модели ==="

    mkdir -p \
        "${COMFYUI_DIR}/models/diffusion_models" \
        "${COMFYUI_DIR}/models/loras" \
        "${COMFYUI_DIR}/models/vae" \
        "${COMFYUI_DIR}/models/clip_vision" \
        "${COMFYUI_DIR}/models/text_encoders" \
        "${COMFYUI_DIR}/models/upscale_models" \
        "${COMFYUI_DIR}/models/detection"

    download_files "${COMFYUI_DIR}/models/diffusion_models" "${WAN_FP8_MODELS[@]}"
    download_files "${COMFYUI_DIR}/models/diffusion_models" "${WAN_ANIMATE_MODELS[@]}"

    download_files "${COMFYUI_DIR}/models/loras" "${LORA_MODELS[@]}"
    download_files "${COMFYUI_DIR}/models/loras" "${LORA_MODELS_EXTRA[@]}"

    download_files "${COMFYUI_DIR}/models/vae" "${VAE_MODELS[@]}"
    download_files "${COMFYUI_DIR}/models/vae" "${VAE_MODELS_NEW[@]}"

    download_files "${COMFYUI_DIR}/models/clip_vision" "${CLIP_VISION_MODELS[@]}"
    download_files "${COMFYUI_DIR}/models/clip_vision" "${CLIP_VISION_NEW[@]}"

    download_files "${COMFYUI_DIR}/models/text_encoders" "${TEXT_ENCODER_MODELS[@]}"
    download_files "${COMFYUI_DIR}/models/text_encoders" "${TEXT_ENCODER_FP8[@]}"

    download_files "${COMFYUI_DIR}/models/controlnet" "${UPSCALE_MODELS[@]}"

    download_files "${COMFYUI_DIR}/models/detection" "${DETECTION_MODELS[@]}"

    echo "=== Загрузка моделей завершена ==="
}

function provisioning_get_workflows() {
    echo "=== Загружаем workflow / рабочие процессы ==="

    local workflows_dir="${COMFYUI_DIR}/user/default/workflows"
    mkdir -p "${workflows_dir}"

    download_files "${workflows_dir}" "${WORKFLOW_FILES[@]}"

    echo "=== Workflow загружены в ${workflows_dir} ==="
}

if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi

if [[ ! -f "${COMFYUI_DIR}/main.py" ]]; then
    echo "ERROR: ComfyUI не установлен: ${COMFYUI_DIR}/main.py не найден"
    exit 1
fi

echo "=== Запускаем ComfyUI (порт 8188) ==="
cd "${COMFYUI_DIR}"
nohup /venv/main/bin/python main.py --listen 0.0.0.0 --port 8188 --enable-cors-header > /var/log/comfyui.log 2>&1 &
disown

# === ФИКС: надёжное удаление /.provisioning ===
echo "=== Снимаем блокировку provisioning для ComfyUI ==="
PROVISIONING_REMOVED=false
for attempt in 1 2 3; do
    if [[ ! -f /.provisioning ]]; then
        echo "/.provisioning уже не существует"
        PROVISIONING_REMOVED=true
        break
    fi
    if rm -f /.provisioning 2>/dev/null; then
        echo "/.provisioning удалён (без sudo)"
        PROVISIONING_REMOVED=true
        break
    fi
    if sudo rm -f /.provisioning 2>/dev/null; then
        echo "/.provisioning удалён (sudo)"
        PROVISIONING_REMOVED=true
        break
    fi
    echo "WARN: попытка ${attempt} не удалась, жду 2 секунды..."
    sleep 2
done

if [[ "${PROVISIONING_REMOVED}" == "false" ]]; then
    echo "ERROR: не удалось удалить /.provisioning после 3 попыток!"
    echo "Попробуй вручную: sudo rm -f /.provisioning"
fi

echo "=== Provisioning завершён, ComfyUI запущен ==="
