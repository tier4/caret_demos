# CARET Demos

ROS 2 + CARET のトレース・分析を試すためのサンプルプログラム集。

## サンプル一覧

| サンプル | 起動コマンド | 説明 |
|---------|-------------|------|
| end_to_end_sample | `ros2 launch caret_demos end_to_end_sample.launch.py` | 基本的な publish/subscribe チェーン |
| relay | `ros2 launch caret_demos end_to_end_sample_with_relay.launch.py` | relay ノードを含むチェーン |
| advanced_demo | `ros2 launch caret_demos advanced_demo.launch.py` | 複数ノード構成のデモ |
| talker_listener | `ros2 launch caret_demos talker_listener.launch.py` | 単純な2ノード通信 |
| talker_listener_loaned_message | `ros2 launch caret_demos talker_listener_loaned_message.launch.py` | LoanedMessage を使用した通信 |
| talker_listener_serialized_message | `ros2 launch caret_demos talker_listener_serialized_message.launch.py` | シリアライズメッセージを使用した通信 |
| multi_talker_listener | `ros2 launch caret_demos multi_talker_listener.launch.py` | 複数 talker/listener |
| cyclic_pipeline_intra_process | `ros2 launch caret_demos cyclic_pipeline_intra_process.launch.py` | Intra-process 通信の循環パイプライン |
| agnocast_demo | `ros2 launch caret_demos agnocast_demo.launch.py` | agnocast を使用したデモ（別途ビルドが必要） |

## ビルド

### 前提
caret_demos: ~/caret_ws/caret_demos
caret： ~/ros2_caret_ws
agnocast: ~/agnocast (with source <caret workspace>)

### 通常ビルド（agnocast 関連は含まない）

```bash
cd ~/caret_ws/caret_demos
colcon build --symlink-install --packages-select caret_demos
```

### agnocast デモを含めてビルド

```bash
cd ~/caret_ws/caret_demos
colcon build --symlink-install --packages-select caret_demos --cmake-args -DBUILD_AGNOCAST_DEMO=ON
```

## トレース取得（CARET 使用時）

### 事前準備

CARET のセットアップスクリプトを source し、caret_demos の workspace も source します。

```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
```

### end_to_end_sample の場合

**ターミナル1（トレース記録用）:**
```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
ros2 caret record -v -s my-session
# "press enter to start..." で待機状態になります
```

**ターミナル2（デモ実行用）:**
```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
ros2 launch caret_demos end_to_end_sample.launch.py
```

ターミナル2の起動完了後、ターミナル1で Enter を押すとトレースが開始されます。
停止は Ctrl+C です。トレースデータはデフォルトで `~/.ros/tracing/my-session/` に保存されます。

トレースデータの分析は `samples/end_to_end_sample/visualize_result.ipynb` を参照してください。

### advanced_demo の場合

**ターミナル1（トレース記録用）:**
```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
ros2 caret record -v -s advanced-session
```

**ターミナル2（デモ実行用）:**
```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
ros2 launch caret_demos advanced_demo.launch.py
```

### agnocast_demo の場合

agnocast は独自の LD_PRELOAD（`libagnocast_heaphook.so`）を使用します。
CARET の `libcaret.so` と両方をプリロードする必要があります。

また、agnocast の `local_setup.bash` を source すると `LD_PRELOAD` の影響で `dirname` 等のコマンドが壊れるため、
事前に `unset LD_PRELOAD` してから source し、最後に `LD_PRELOAD` を設定します。

**ターミナル1（トレース記録用）:**
```bash
cd ~/caret_ws/caret_demos
source ~/ros2_caret_ws/setenv_caret.bash
source install/local_setup.bash
ros2 caret record -v -s agnocast-session
```

**ターミナル2（デモ実行用）:**
```bash
cd ~/caret_ws/caret_demos
unset LD_PRELOAD
source ~/ros2_caret_ws/setenv_caret.bash
source ~/agnocast/install/local_setup.bash
source install/local_setup.bash
export LD_PRELOAD=$HOME/agnocast/install/agnocastlib/lib/libagnocast_heaphook.so:$LD_PRELOAD
# 確認（libagnocast_heaphook.so:libcaret.so の順で両方含まれていること）
echo $LD_PRELOAD
ros2 launch caret_demos agnocast_demo.launch.py
```

## 環境

- ROS 2 Humble / Jazzy
- CARET
- agnocast（オプション）

## ライセンス

[LICENSE](LICENSE) を参照してください。