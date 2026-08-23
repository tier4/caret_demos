# CARET Demos

A collection of sample programs for testing trace and analysis with ROS 2 + CARET.

## Sample List

| Sample | Launch Command | Description |
|---------|-------------|------|
| end_to_end_sample | `ros2 launch caret_demos end_to_end_sample.launch.py` | Basic publish/subscribe chain |
| relay | `ros2 launch caret_demos end_to_end_sample_with_relay.launch.py` | Chain with a relay node |
| advanced_demo | `ros2 launch caret_demos advanced_demo.launch.py` | Multi-node demo |
| talker_listener | `ros2 launch caret_demos talker_listener.launch.py` | Simple 2-node communication |
| talker_listener_loaned_message | `ros2 launch caret_demos talker_listener_loaned_message.launch.py` | Communication using LoanedMessage |
| talker_listener_serialized_message | `ros2 launch caret_demos talker_listener_serialized_message.launch.py` | Communication using serialized messages |
| multi_talker_listener | `ros2 launch caret_demos multi_talker_listener.launch.py` | Multiple talker/listener |
| cyclic_pipeline_intra_process | `ros2 launch caret_demos cyclic_pipeline_intra_process.launch.py` | Cyclic pipeline with intra-process communication |
| agnocast_demo | `ros2 launch caret_demos agnocast_demo.launch.py` | Demo using agnocast (requires separate build) |

## Build

### Default build (without agnocast)

```bash
cd ~/caret_ws/caret_demos
colcon build --symlink-install --packages-select caret_demos
```

### Build with agnocast demo

```bash
cd ~/caret_ws/caret_demos
colcon build --symlink-install --packages-select caret_demos --cmake-args -DBUILD_AGNOCAST_DEMO=ON
```

## Trace Collection (with CARET)

### Prerequisites

Source the CARET setup script and the caret_demos workspace.

```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
```

### end_to_end_sample

**Terminal 1 (trace recording):**
```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
ros2 caret record -v -s my-session
# Waits for "press enter to start..."
```

**Terminal 2 (run demo):**
```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
ros2 launch caret_demos end_to_end_sample.launch.py
```

After Terminal 2 starts up, press Enter in Terminal 1 to begin tracing.
Stop with Ctrl+C. Trace data is saved to `~/.ros/tracing/my-session/` by default.

See `samples/end_to_end_sample/visualize_result.ipynb` for trace data analysis.

### advanced_demo

**Terminal 1 (trace recording):**
```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
ros2 caret record -v -s advanced-session
```

**Terminal 2 (run demo):**
```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
ros2 launch caret_demos advanced_demo.launch.py
```

### agnocast_demo

agnocast uses its own LD_PRELOAD (`libagnocast_heaphook.so`).
Both CARET's `libcaret.so` and agnocast's `libagnocast_heaphook.so` must be preloaded.

When sourcing agnocast's `local_setup.bash`, commands like `dirname` can break due to LD_PRELOAD.
To avoid this, `unset LD_PRELOAD` before sourcing, and set `LD_PRELOAD` at the end.

**Terminal 1 (trace recording):**
```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
ros2 caret record -v -s agnocast-session
```

**Terminal 2 (run demo):**
```bash
cd ~/caret_ws/caret_demos
unset LD_PRELOAD
source ~/ros2_caret_ws/setenv_caret.bash
source ~/agnocast/install/local_setup.bash
source install/local_setup.bash
export LD_PRELOAD=$HOME/agnocast/install/agnocastlib/lib/libagnocast_heaphook.so:$LD_PRELOAD
# Verify: both libagnocast_heaphook.so and libcaret.so should be present, in that order
echo $LD_PRELOAD
ros2 launch caret_demos agnocast_demo.launch.py
```

## Environment

- ROS 2 Humble / Jazzy
- CARET
- agnocast (optional)

## License

See [LICENSE](LICENSE).
