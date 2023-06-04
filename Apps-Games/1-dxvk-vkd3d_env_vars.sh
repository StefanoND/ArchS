# This is not a runnable script
#
# ----------------------------------------------------------------------------------------------------------
# DXVK
# ----------------------------------------------------------------------------------------------------------

# -------------------
# HUD
# -------------------

DXVK_HUD environment variable controls a HUD which can display the framerate and some stat counters. It accepts a comma-separated list of the following options:

devinfo: Displays the name of the GPU and the driver version.
fps: Shows the current frame rate.
frametimes: Shows a frame time graph.
submissions: Shows the number of command buffers submitted per frame.
drawcalls: Shows the number of draw calls and render passes per frame.
pipelines: Shows the total number of graphics and compute pipelines.
descriptors: Shows the number of descriptor pools and descriptor sets.
memory: Shows the amount of device memory allocated and used.
gpuload: Shows estimated GPU load. May be inaccurate.
version: Shows DXVK version.
api: Shows the D3D feature level used by the application.
cs: Shows worker thread statistics.
compiler: Shows shader compiler activity
samplers: Shows the current number of sampler pairs used [D3D9 Only]
scale=x: Scales the HUD by a factor of x (e.g. 1.5)
Additionally, DXVK_HUD=1 has the same effect as DXVK_HUD=devinfo,fps, and DXVK_HUD=full enables all available HUD elements.

# -------------------
# FRAMERATE
# -------------------

The DXVK_FRAME_RATE environment variable can be used to limit the frame rate. A value of 0 uncaps the frame rate,
while any positive value will limit rendering to the given number of frames per second.

# -------------------
# DEVICE FILTER
# -------------------

Some applications do not provide a method to select a different GPU. In that case, DXVK can be forced to use a given device:

DXVK_FILTER_DEVICE_NAME="Device Name" Selects devices with a matching Vulkan device name, which can be retrieved with tools such as vulkaninfo.
Matches on substrings, so "VEGA" or "AMD RADV VEGA10" is supported if the full device name is "AMD RADV VEGA10 (LLVM 9.0.0)", for example.
If the substring matches more than one device, the first device matched will be used.

Note: If the device filter is configured incorrectly, it may filter out all devices and applications will be unable to create a D3D device.

# -------------------
# STATE CACHE
# -------------------

DXVK caches pipeline state by default, so that shaders can be recompiled ahead of time on subsequent runs of an application,
even if the driver's own shader cache got invalidated in the meantime. This cache is enabled by default, and generally reduces stuttering.

The following environment variables can be used to control the cache:

DXVK_STATE_CACHE: Controls the state cache. The following values are supported:
disable: Disables the cache entirely.
reset: Clears the cache file.
DXVK_STATE_CACHE_PATH=/some/directory Specifies a directory where to put the cache files. Defaults to the current working directory of the application.

# -------------------
# DEBUGGING
# -------------------

The following environment variables can be used for debugging purposes.

VK_INSTANCE_LAYERS=VK_LAYER_KHRONOS_validation Enables Vulkan debug layers. Highly recommended for troubleshooting rendering issues and driver crashes.
Requires the Vulkan SDK to be installed on the host system.

DXVK_LOG_LEVEL=none|error|warn|info|debug Controls message logging.
DXVK_LOG_PATH=/some/directory Changes path where log files are stored. Set to none to disable log file creation entirely, without disabling logging.
DXVK_CONFIG_FILE=/xxx/dxvk.conf Sets path to the configuration file.
DXVK_DEBUG=markers|validation Enables use of the VK_EXT_debug_utils extension for translating performance event markers, or to enable Vulkan validation, respecticely.

# ----------------------------------------------------------------------------------------------------------
# VKD3D
# ----------------------------------------------------------------------------------------------------------

# -------------------
# VKD3D_CONFIG
# -------------------

VKD3D_CONFIG - a list of options that change the behavior of vkd3d-proton.
    vk_debug: enables Vulkan debug extensions and loads validation layer.
    skip_application_workarounds: Skips all application workarounds. For debugging purposes.
    dxr: Enables DXR support if supported by device.
    dxr11: Enables DXR tier 1.1 support if supported by device.
    force_static_cbv: Unsafe speed hack on NVIDIA. May or may not give a significant performance uplift.
    single_queue: Do not use asynchronous compute or transfer queues.
    no_upload_hvv: Blocks any attempt to use host-visible VRAM (large/resizable BAR) for the UPLOAD heap. May free up vital VRAM in certain critical situations, at cost of lower GPU performance. A fraction of VRAM is reserved for resizable BAR allocations either way, so it should not be a real issue even on lower VRAM cards.
    force_host_cached: Forces all host visible allocations to be CACHED, which greatly accelerates captures.
    no_invariant_position: Avoids workarounds for invariant position. The workaround is enabled by default.

VKD3D_DEBUG - controls the debug level for log messages produced by vkd3d-proton. Accepts the following values: none, err, info, fixme, warn, trace.
VKD3D_SHADER_DEBUG - controls the debug level for log messages produced by the shader compilers. See VKD3D_DEBUG for accepted values.
VKD3D_LOG_FILE - If set, redirects VKD3D_DEBUG logging output to a file instead.
VKD3D_VULKAN_DEVICE - a zero-based device index. Use to force the selected Vulkan device.
VKD3D_FILTER_DEVICE_NAME - skips devices that don't include this substring.
VKD3D_DISABLE_EXTENSIONS - a list of Vulkan extensions that vkd3d-proton should not use even if available.
VKD3D_TEST_DEBUG - enables additional debug messages in tests. Set to 0, 1 or 2.
VKD3D_TEST_FILTER - a filter string. Only the tests whose names matches the filter string will be run, e.g. VKD3D_TEST_FILTER=clear_render_target.
    Useful for debugging or developing new tests.
VKD3D_TEST_EXCLUDE - excludes tests of which the name is included in the string.
    E.g. VKD3D_TEST_EXCLUDE=test_root_signature_priority,test_conservative_rasterization_dxil.
VKD3D_TEST_PLATFORM - can be set to "wine", "windows" or "other".
    The test platform controls the behavior of todo(), todo_if(), bug_if() and broken() conditions in tests.
VKD3D_TEST_BUG - set to 0 to disable bug_if() conditions in tests.
VKD3D_PROFILE_PATH - If profiling is enabled in the build, a profiling block is emitted to ${VKD3D_PROFILE_PATH}.${pid}.

# -------------------
# SHADER CACHE
# -------------------

By default, vkd3d-proton manages its own driver cache. This cache is intended to cache DXBC/DXIL -> SPIR-V conversion.
    This reduces stutter (when pipelines are created last minute and app relies on hot driver cache) and
    load times (when applications do the right thing of loading PSOs up front).

Behavior is designed to be close to DXVK state cache.

Default behavior
vkd3d-proton.cache (and vkd3d-proton.cache.write) are placed in the current working directory. Generally, this is the game install folder when running in Steam.

Custom directory
VKD3D_SHADER_CACHE_PATH=/path/to/directory overrides the directory where vkd3d-proton.cache is placed.

Disable cache
VKD3D_SHADER_CACHE_PATH=0 disables the internal cache, and any caching would have to be explicitly managed by application.

Behavior of ID3D12PipelineLibrary
When explicit shader cache is used, the need for application managed pipeline libraries is greatly diminished,
    and the cache applications interact with is a dummy cache. If the vkd3d-proton shader cache is disabled,
    ID3D12PipelineLibrary stores everything relevant for a full cache, i.e. SPIR-V and PSO driver cache blob.
    VKD3D_CONFIG=pipeline_library_app_cache is an alternative to VKD3D_SHADER_CACHE_PATH=0 and can be automatically
    enabled based on app-profiles if relevant in the future if applications manage the caches better than vkd3d-proton can do automagically.
