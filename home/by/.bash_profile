#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export NVD_BACKEND=direct # Hardware video acceleration on Nvidia and Wayland is possible with the nvidia-vaapi-driver. This may solve specific issues in Electron apps.
export __NV_PRIME_RENDER_OFFLOAD=1  # When set to 1, it allows applications to offload rendering tasks to the NVIDIA GPU while the display is still managed by the integrated GPU.
export LIBVA_DRIVER_NAME=nvidia  # this tells applications that use VA-API(Video Acceleration API) to use the NVIDIA for hardware acceleration.
export VDPAU_DRIVER=nvidia  # this indicates that the VDPAU (Video Decode and Presentation API for Unix) should use the NVIDIA for video decoding.
export __GLX_VENDOR_LIBRARY_NAME=nvidia  # this directs OpenGL applications to use the NVIDIA driver. This is important for ensuring that OpenGL applications utilize the NVIDIA driver for rendering, which is necessary for proper functionality when using the NVIDIA GPU for offloading.
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json  # This sets the Vulkan ICD (Installable Client Driver) file to the NVIDIA driver. It tells Vulkan applications to use the NVIDIA driver for rendering.
export VK_DRIVER_FILES=/usr/share/vulkan/icd.d/nvidia_icd.json
# export VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d

export JAVA_HOME=/usr/lib/jvm/default

exec Hyprland
