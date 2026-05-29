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
    "https://github.com/lehych-sol/Zen-Face-Detail"
    "https://github.com/lehych-sol/Camera-Forensic-Realism"
    "https://github.com/lehych-sol/Custom-Nodes-by-lehych"
    "https://github.com/kijai/ComfyUI-PromptRelay"
    "https://github.com/Saganaki22/ComfyUI-FishAudioS2"
    "https://github.com/MONKEYFOREVER2/comfyui-quantum-spectral-nodes"
    "https://github.com/lehych-sol/advanced-denoiser"
    "https://github.com/lehych-sol/Stolen-Nodes"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler"
    "https://github.com/darkamenosa/comfy_nanobanana"
    "https://github.com/chflame163/ComfyUI_LayerStyle"
    "https://github.com/donkbeef/flashVSRnode"
    "https://github.com/lehych-sol/geek-nodes"
    "https://github.com/lehych-sol/custom-nodes"
    "https://github.com/Lightricks/ComfyUI-LTXVideo"
    "https://github.com/PGCRT/CRT-Nodes CRT-Nodes-PGCRT"
    "https://github.com/Jasonzzt/ComfyUI-CacheDiT"
    "https://github.com/thatboymentor/ofmtechclip"
    "https://github.com/scraed/LanPaint"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/facok/comfyui-meancache-z"
    "https://github.com/teskor-hub/comfyui-teskors-utils"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/ClownsharkBatwing/RES4LYF"
    "https://github.com/chrisgoringe/cg-use-everywhere"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
    "https://github.com/Smirnov75/ComfyUI-mxToolkit"
    "https://github.com/TheLustriVA/ComfyUI-Image-Size-Tools"
    "https://github.com/ZhiHui6/zhihui_nodes_comfyui"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/crystian/ComfyUI-Crystools"
    "https://github.com/plugcrypt/CRT-Nodes CRT-Nodes-plugcrypt"
    "https://github.com/EllangoK/ComfyUI-post-processing-nodes"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/lehych-ai/ComfyUI-WanAnimatePreprocess"
    "https://github.com/GACLove/ComfyUI-VFI"
    "https://github.com/ShmuelRonen/ComfyUI-FishSpeech"
)

WAN_FP8_MODELS=(
    "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/SteadyDancer/Wan21_SteadyDancer_fp8_e4m3fn_scaled_KJ.safetensors"
)

LORA_MODELS=(
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors"
)

VAE_MODELS=(
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/a328a632b80d44062fda7df9b6b1a7b2c3a5cf2c/Wan2_1_VAE_bf16.safetensors"
)

CLIP_VISION_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"
)

TEXT_ENCODER_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors"
)

UPSCALE_MODELS=(
    "https://raw.githubusercontent.com/gamefurius32-lgtm/upsclane1xskin/main/1xSkinContrast-SuperUltraCompact%20(3).pth"
)

WAN_ANIMATE_MODELS=(
    "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/Wan22Animate/Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors"
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
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"
)

DETECTION_MODELS=(
    "https://huggingface.co/JunkyByte/easy_ViTPose/resolve/main/onnx/wholebody/vitpose-l-wholebody.onnx"
    "https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx"
    "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_model.onnx"
    "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_data.bin"
)

WORKFLOW_FILES=(
    "https://huggingface.co/lehychh/closer-ai-workflows/resolve/main/photo_heaven_v2.json"
    "https://huggingface.co/lehychh/closer-ai-workflows/resolve/main/lipsyncmode.json"
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

    download_files "${COMFYUI_DIR}/models/upscale_models" "${UPSCALE_MODELS[@]}"

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

echo "=== Снимаем блокировку provisioning для ComfyUI ==="
if command -v sudo >/dev/null 2>&1; then
    sudo rm -f /.provisioning 2>/dev/null || rm -f /.provisioning 2>/dev/null || true
else
    rm -f /.provisioning 2>/dev/null || true
fi

echo "=== Provisioning завершён, ComfyUI запущен ==="
