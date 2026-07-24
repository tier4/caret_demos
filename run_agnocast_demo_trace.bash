#!/bin/bash
set -e

# Source ROS 2 and CARET
source /opt/ros/humble/setup.bash 2>/dev/null || source /opt/ros/iron/setup.bash 2>/dev/null || true

# Source workspaces
source /home/akm/caret_ws/caret_demos/install/setup.bash 2>/dev/null || true
source /home/akm/Agnocast/agnocast/install/local_setup.bash 2>/dev/null || true
source /home/akm/caret_ws/install/setup.bash 2>/dev/null || true

# Clean up any existing trace session
lttng destroy agnocast_demo_trace 2>/dev/null || true

echo "=== Starting trace for agnocast_demo ==="
echo "Launch will run for 5 seconds, then auto-terminate..."

# Run the launch file with timeout, then destroy trace
timeout 5 ros2 launch caret_demos agnocast_demo_trace.launch.py 2>&1 || true

echo "=== Trace session ended ==="

# Give LTTng time to finalize
sleep 1

# List trace data
echo ""
echo "=== Trace data location ==="
lttng list agnocast_demo_trace 2>/dev/null || echo "(session may be auto-destroyed)"

# Find trace directory
TRACE_DIR=$(find /root -maxdepth 3 -name "agnocast_demo_trace*" -type d 2>/dev/null | head -1)
if [ -z "$TRACE_DIR" ]; then
    TRACE_DIR=$(find /home -maxdepth 4 -name "agnocast_demo_trace*" -type d 2>/dev/null | head -1)
fi
if [ -z "$TRACE_DIR" ]; then
    TRACE_DIR=$(lttng view agnocast_demo_trace 2>&1 | head -5)
fi

echo "Trace directory: $TRACE_DIR"

# Try to check for rcl_node_init and agnocast_node_init events
echo ""
echo "=== Checking events ==="
babeltrace2 "$TRACE_DIR" 2>/dev/null | grep -E "(rcl_node_init|agnocast_node_init)" | head -30 || echo "(could not read trace, using babeltrace)"

# Alternative: try with lttng view
if [ -n "$TRACE_DIR" ]; then
    lttng view "$TRACE_DIR" 2>/dev/null | grep -E "(rcl_node_init|agnocast_node_init)" | head -30 || true
fi