// sip2_message_builder.dart
String generateTimestamp() {
    DateTime now = DateTime.now();

    String year = now.year.toString(); 
    String month = now.month.toString().padLeft(2, '0');
    String day = now.day.toString().padLeft(2, '0');
    String hour = now.hour.toString().padLeft(2, '0');
    String minute = now.minute.toString().padLeft(2, '0');
    String second = now.second.toString().padLeft(2, '0');

    return '$year$month$day    $hour$minute$second';
  }


String buildLoginMessage(String username, String password, String locationCode) {
  return '9300CN$username|CO$password|CP$locationCode|';
}


String buildMessage(String template, String barcode, String pin, String username, String password, String itemBarcode) {
  switch (template) {
    case 'Patron Status':
      return '23001${generateTimestamp()}AO|AA$barcode|AC|AD$pin|';      
    case 'Patron Information':
      return '6300${generateTimestamp()}YYYYYYYYYYAO|AA$barcode|AD$pin|BP1|BQ5|';
    case 'Item Information':
      return '17${generateTimestamp()}AO|AB$itemBarcode|AC|';
    case 'Item Checkout':
      return '11YN${generateTimestamp()}${generateTimestamp()}|AA$barcode|AB$itemBarcode|AC|AD|';
    case 'Item Checkin':
      return '09N${generateTimestamp()}${generateTimestamp()}AP|AO|AB$itemBarcode|AC|';
    case 'Renew Item':
      return '29YN${generateTimestamp()}${generateTimestamp()}|AA$barcode|AB$itemBarcode|';
    case 'Renew All Items':
      return '65${generateTimestamp()}AO|AA$barcode|AD|';    
    default:
      return '';
  }
}