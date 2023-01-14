import '../workspace/workspace.dart';
import 'history_item_time_range.dart';

class RequestToNode {
  Connection connection;
  String itemName;
  int minTime;
  int maxTime;
  int groupTimeRange;
  HistoryItemTimeRange range;
  RequestToNode(this.connection, this.itemName, this.minTime, this.maxTime,
      this.groupTimeRange, this.range);
}
