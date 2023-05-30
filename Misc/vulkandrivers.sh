# This is not a runnable scripts
# If you have any issues with loading vulkan, set VK_ICD_FILENAMES and VK_LAYER_PATH relative to your GPU
#
# AMD Users doesn't need it, they should use Amd Vulkan Prefixer instead
# https://gitlab.com/AndrewShark/amd-vulkan-prefixes
# https://wiki.archlinux.org/title/Vulkan#Selecting_via_AMD_Vulkan_Prefixes

#NVIDIA
printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json" | sudo tee -a /etc/environment
printf "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d" | sudo tee -a /etc/environment

#AMD (deprecated, don't use)
printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.i686.json" | sudo tee -a /etc/environment
printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json" | sudo tee -a /etc/environment
printf "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d" | sudo tee -a /etc/environment

#INTEL
printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json" | sudo tee -a /etc/environment
printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nv_vulkan_wrapper.json" | sudo tee -a /etc/environment
printf "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d" | sudo tee -a /etc/environment

#VIRTIO
printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/virtio_icd.i686.json" | sudo tee -a /etc/environment
printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/virtio_icd.x86_64.json" | sudo tee -a /etc/environment
printf "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d" | sudo tee -a /etc/environment

#SOFTWARE
printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.i686.json" | sudo tee -a /etc/environment
printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.x86_64.json" | sudo tee -a /etc/environment
printf "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d" | sudo tee -a /etc/environment
