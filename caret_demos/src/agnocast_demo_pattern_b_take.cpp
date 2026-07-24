#include "agnocast/agnocast.hpp"
#include "std_msgs/msg/string.hpp"

#include <memory>
#include <string>
#include <utility>

using namespace std::chrono_literals;

// ==========================================
// [Node5] TakeByPatternBNode (agnocast take/pub by Pattern B + PollingSubscriber)
// ==========================================
// Pattern B (Stage 2) + take: agnocast::Node + polling subscription (no callback) + this->create_publisher
// Runs with AgnocastOnlySingleThreadedExecutor
class TakeByPatternBNode : public agnocast::Node
{
public:
  TakeByPatternBNode() : agnocast::Node("take_by_pattern_b_node")
  {
    // Polling subscription: create_subscription without callback (uses the 2-argument overload)
    polling_sub_ = agnocast::create_subscription<std_msgs::msg::String>(
      this, "/topic4", rclcpp::QoS(10));

    agnocast_pub_ = this->create_publisher<std_msgs::msg::String>("/topic5", rclcpp::QoS(10));

    // Use a timer to periodically take data (simulating a control loop)
    // agnocast::create_timer returns agnocast::TimerBase::SharedPtr (= rclcpp::TimerBase::SharedPtr)
    timer_ = agnocast::create_timer(
      this, this->get_clock(), 1s,
      std::bind(&TakeByPatternBNode::timer_callback, this));
  }

private:
  void timer_callback()
  {
    // take_data() returns an optional nullable shared_ptr
    auto taken_msg = polling_sub_->take_data();
    if (!taken_msg) {
      RCLCPP_INFO(get_logger(), "[Node5/TakeByPatternB] no data on /topic4 yet");
      return;
    }

    RCLCPP_INFO(
      get_logger(),
      "[Node5/TakeByPatternB] agnocast take /topic4 -> agnocast pub /topic5 (%s)",
      taken_msg->data.c_str());

    auto out = agnocast_pub_->borrow_loaned_message();
    out->data = taken_msg->data;
    agnocast_pub_->publish(std::move(out));
  }

  agnocast::PollingSubscriber<std_msgs::msg::String>::SharedPtr polling_sub_;
  agnocast::Publisher<std_msgs::msg::String>::SharedPtr agnocast_pub_;
  agnocast::TimerBase::SharedPtr timer_;
};

// ==========================================
// Main Function
// ==========================================
int main(int argc, char ** argv)
{
  agnocast::init(argc, argv);
  agnocast::AgnocastOnlySingleThreadedExecutor executor;
  auto node = std::make_shared<TakeByPatternBNode>();
  executor.add_node(node);
  executor.spin();
  return 0;
}