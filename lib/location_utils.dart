String formatTimestamp(String timestamp) {
  String year = timestamp.substring(0,4);
  String month = timestamp.substring(4,6);
  String day = timestamp.substring(6,8);
  String hh = timestamp.substring(8,10);
  String mm = timestamp.substring(10,12);
  String ss = timestamp.substring(12,14);
  return '$day/$month/$year $hh:$mm';
}