#!/bin/bash
set -e

# ========================================================================
# run_agnocast_demo.bash
#
# Launches the agnocast demo with CARET tracing enabled.
# Sets LD_PRELOAD to include both:
#   - libcaret.so (CARET tracing)
#   - libagnocast_heaphook.so (agnocast shared memory allocator)
# ========================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CARET_DEMOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source caret_demos workspace
if [ -f "$CARET_DEMOS_DIR/install/setup.bash" ]; then
    source "$CARET_DEMOS_DIR/install/setup.bash"
fi

# Prepend agnocast heaphook to LD_PRELOAD (before libcaret.so)
#export LD_PRELOAD="/opt/ros/humble/lib/libagnocast_heaphook.so:/opt/ros/humble/lib/libagnocast.so:${LD_PRELOAD}"
#export LD_PRELOAD="/opt/ros/humble/lib/libagnocast_heaphook.so"
export LD_PRELOAD="/home/akm/Agnocast/agnocast/install/agnocastlib/lib/libagnocast_heaphook.so"

# Source CARET environment (sets LD_PRELOAD with libcaret.so)
source /home/akm/ros2_caret_ws/setenv_caret.bash

echo "=== LD_PRELOAD ==="
echo "$LD_PRELOAD"
echo "=================="

# Run the demo
ros2 launch caret_demos agnocast_demo.launch.py

# LD_DEBUG に bindings を指定し、どの共有ライブラリが agnocast 関連シンボルを結びつけているか出力
#LD_DEBUG=bindings ros2 launch caret_demos agnocast_demo.launch.py 2>&1 | grep -i agnocast

