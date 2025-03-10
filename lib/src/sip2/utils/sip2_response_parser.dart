String parseResponse(String response) {
  final Map<int, String> positionMeanings = {
    1: "Charge Privileges Denied",
    2: "Renewal Privileges Denied",
    3: "Recall Privileges Denied",
    4: "Hold Privileges Denied",
    5: "Card Reported Lost",
    6: "Too Many Items Charged",
    7: "Too Many Items Overdue",
    8: "Too Many Renewals",
    9: "Too Many Claims of Items Returned",
    10: "Too Many Items Lost",
    11: "Excessive Outstanding Fines",
    12: "Excessive Outstanding Fees",
    13: "Recall Overdue",
    14: "Too Many Items Billed",
  };
  final namePattern = RegExp(r'AE([^|]+)');
  final nameMatch = namePattern.firstMatch(response);

  String name = '';
  if (nameMatch != null) {
    name = nameMatch.group(1)?.trim() ?? 'Unknown'; // Extract the name
  }
  // Updated regex to capture full block
  final pattern = RegExp(r'24(.+?)AA'); 
  final match = pattern.firstMatch(response);
  print(name);
  if (match != null) {
    final extractedData = match.group(1)?.trim();
    if (extractedData != null) {
        String parsedInfo = "\n";
        for (int position in positionMeanings.keys) {
          if (position - 1 < extractedData.length && extractedData[position - 1] == 'Y') {
            parsedInfo += "Block ${position - 1}: ${positionMeanings[position]}\n" ;
          }
        }

      return parsedInfo;
    }
  }

  return "";
}
