import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';


class SendPostXML extends StatefulWidget {
  const SendPostXML({super.key});

  @override
  SendPostXMLState createState() => SendPostXMLState();
}

class SendPostXMLState extends State<SendPostXML> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _agencyIdController = TextEditingController();
  final TextEditingController _patronBarcodeController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();

  Future<String> parseAndFormatXml(String response) async {
    try {
      final document = XmlDocument.parse(response);

      // Extract specific fields
      
      final userName = document.findAllElements('UnstructuredPersonalUserName').first.text;
      final userId = document.findAllElements('UserIdentifierValue').first.text;
      final userPrivilege = document.findAllElements('AgencyUserPrivilegeType').first.text;
      final validToDate = document.findAllElements('ValidToDate').first.text;
      final blockOrTrap = document.findAllElements('BlockOrTrapType').first.text;

      // Return formatted string
      return '''
              Response Details:
              User Name: $userName
              User ID: $userId
              User Privilege: $userPrivilege
              Valid To Date: $validToDate
              Block or Trap: $blockOrTrap
              ''';
    } catch (e) {
      return 'Error parsing XML: $e';
    }
  }

  Future<void> sendPostRequest() async {
  String xmlData = '''
    <NCIPMessage version="http://www.niso.org/ncip/v1_0/imp1/dtd/ncip_v1_0.dtd">
      <LookupUser>
        <InitiationHeader>
          <FromAgencyId>
            <UniqueAgencyId>
              <Scheme>http://www.auto-graphics.com/ncip/schemes/uniqueagencyid/agencynames.scm</Scheme>
              <Value>CPomAG:ARSL:ARPUAJNCL</Value>
            </UniqueAgencyId>
          </FromAgencyId>
          <ToAgencyId>
            <UniqueAgencyId>
              <Scheme>http://</Scheme>
              <Value>${_agencyIdController.text}</Value>
            </UniqueAgencyId>
          </ToAgencyId>
        </InitiationHeader>
        <VisibleUserId>
          <VisibleUserIdentifierType>
            <Scheme>http://www.niso.org/ncip/v1_0/schemes/userelementtype/userelementtype.scm</Scheme>
            <Value datatype="string">Barcode</Value>
          </VisibleUserIdentifierType>
          <VisibleUserIdentifier datatype="string">${_patronBarcodeController.text}</VisibleUserIdentifier>
        </VisibleUserId>
        <UserElementType>
          <Scheme>http://www.niso.org/ncip/v1_0/schemes/userelementtype/userelementtype.scm</Scheme>
          <Value>Name Information</Value>
        </UserElementType>
      </LookupUser>
    </NCIPMessage>
  ''';

  try {
    final response = await http.post(
      Uri.parse('${_hostController.text}:${_portController.text}'),
      headers: {'Content-Type': 'application/xml'},
      body: xmlData,
    );

    if (response.statusCode == 200) {
      String formattedResponse = await parseAndFormatXml(response.body);
      setState(() {
        _responseController.text = formattedResponse;
      });
    } else {
      setState(() {
        _responseController.text = "Error! Status code: ${response.statusCode}";
      });
    }
  } catch (e) {
    setState(() {
      _responseController.text = "Error sending request: $e";
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title:  Text('NCIP Connection Tester'),
      ),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextBox(
                controller: _hostController,
                placeholder: 'Host',
              ),
              TextBox(
                controller: _portController,
                placeholder: 'Port',
              ),
              TextBox(
                controller: _agencyIdController,
                placeholder: 'Agency ID',
              ),
              TextBox(
                controller: _patronBarcodeController,
                placeholder: 'Patron Barcode',
              ),
              const SizedBox(height: 20),
              Button(
                onPressed: sendPostRequest,
                child: const Text('Send Request'),
              ),
              const SizedBox(height: 10,),
              TextBox(
                controller: _responseController,
                readOnly: true,
                maxLines: 10,
                placeholder: 'Response',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
