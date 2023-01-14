import 'package:gazer_client/core/history/request_to_node.dart';

import '../protocol/dataitem/data_item_history_chart.dart';

class HistoryItemTimeRangeGetHistoryResult {
  List<DataItemHistoryChartItemValueResponse> values;
  List<RequestToNode> requests;
  HistoryItemTimeRangeGetHistoryResult(this.values, this.requests);
}
