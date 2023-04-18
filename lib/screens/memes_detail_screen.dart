part of 'screen.dart';


class MemesDetailScreen extends StatefulWidget {
  final MemesData memesData;

  const MemesDetailScreen({
    required this.memesData
  });

  @override
  State<MemesDetailScreen> createState() => _MemesDetailScreenState();
}

class _MemesDetailScreenState extends State<MemesDetailScreen> {
  final GlobalKey genKey = GlobalKey();

  TextEditingController textController = TextEditingController();

  late String text;
  late File   logo;
  late String fromGenerateText;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    text = textController.text;
    logo = File("");
    fromGenerateText = "";
  }


  void showDialogAddText() {
    showDialog(
        context: context,
        builder: (context) => WillPopScope(
            onWillPop: () async => true,
            child: AlertDialog(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children:  <Widget> [
                  Text('Tambah Text', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                      keyboardType: TextInputType.text,
                      controller: textController,
                      cursorColor: Colors.blueGrey,
                      decoration: InputDecoration(
                          hintText: "Text",
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueGrey, width: 2.5
                              )
                          )
                      ),
                      style: TextStyle( fontSize: 16, fontWeight: FontWeight.w600)
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child:Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: (){
                        setState(() {
                          text = textController.text;
                        });

                        textController.clear();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              )
            )
        )
    );
  }

  Future selectImage() async {
      try {
        final image = await ImagePicker().pickImage(source: ImageSource.gallery);

        if(image == null) return;

        final imageTemp = File(image.path);

        setState(() {
          logo = imageTemp;
        });

      } on PlatformException catch(e) {
        print('Failed to pick image: $e');
      }
    }

  Future<void> generatePicture() async {
    RenderRepaintBoundary boundary = genKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final randomString = getRandomString(12);
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/$randomString.png').create();
    file.writeAsBytesSync(pngBytes);

    setState(() {
      fromGenerateText = '${tempDir.path}/$randomString.png';
    });
  }

  Future<void> saveToLocal() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString("image_path", fromGenerateText);
    } finally {
      showDialog(
          context: context,
          builder: (BuildContext builderContext) {
            _timer = Timer(Duration(seconds: 2), () {
              Navigator.of(context).pop();
            });

            return AlertDialog(
              backgroundColor: Colors.white,
              content: SingleChildScrollView(
                child: Text(
                  'Berhasil menambah data ke penyimpanan internal', 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }
      ).then((val){
        if (_timer.isActive) {
          _timer.cancel();
        }
      });
    }

  }

  Widget showShareAndSaveButton() {
    if(logo.existsSync() && text.isNotEmpty ) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Icon(Icons.save),
                  Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0
              ),
              onPressed: () async {
                await generatePicture();
                await saveToLocal();
              },
            ),
          ),
          SizedBox(width: 10.0),
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Icon(Icons.share),
                  Text('Share', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
              ),
              onPressed: () async {
                await generatePicture();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MemesDetailShareScreen(generateFileText: fromGenerateText)
                    )
                );
              },
            ),
          ),
        ],
      );
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        centerTitle: true,
        title: Text('MimGenerator'),
      ),
      body: WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future<bool>.value(false);
        },
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RepaintBoundary(
                  key: genKey,
                  child: Stack(
                    children: [
                      Image(
                        image: NetworkImage(widget.memesData.url),
                      ),
                      Positioned(
                          top: 1.0,
                          child: Container(
                            margin: EdgeInsets.all(10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                !logo.existsSync() ? (
                                    SizedBox()
                                ) : (
                                    Container(
                                      padding: EdgeInsets.all(6), // Border width
                                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                      child: ClipOval(
                                        child: SizedBox.fromSize(
                                          size: Size.fromRadius(48), // Image radius
                                          child: Image.file(logo, fit: BoxFit.cover,),
                                        ),
                                      ),
                                    )
                                ),
                                SizedBox(width: 20.0),
                                Text(
                                  text,
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            )
                          )
                      ),
                      Positioned(
                            bottom: 10.0,
                            child: Container(
                              margin: EdgeInsets.all(10.0),
                              child: Text(
                                  text,
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
                                  overflow: TextOverflow.fade,
                              ),
                            )
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Icon(Icons.image),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20)
                      ),
                      onPressed: (){
                        selectImage();
                      },
                    ),
                    SizedBox(width: 30),
                    ElevatedButton(
                      child: Icon(Icons.text_fields),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20)
                      ),
                      onPressed: (){
                        showDialogAddText();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20.0,),
                showShareAndSaveButton()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
