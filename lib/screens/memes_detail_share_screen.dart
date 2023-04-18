part of 'screen.dart';

class MemesDetailShareScreen extends StatefulWidget {
  final String generateFileText;

  const MemesDetailShareScreen({
    required this.generateFileText
  });

  @override
  State<MemesDetailShareScreen> createState() => _MemesDetailShareScreenState();
}

class _MemesDetailShareScreenState extends State<MemesDetailShareScreen> {
  void shareGenerateImage() async {
    try {
      await Share.shareFiles([
          widget.generateFileText
      ]);
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        centerTitle: true,
        title: Text("MimGenerator"),
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
              children: [
                Image(
                  image: Image.file(File(widget.generateFileText)).image,
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    child:Text('Share to Facebook', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Colors.blueAccent
                    ),
                    onPressed: (){
                      shareGenerateImage();
                    },
                  ),
                ),
                SizedBox(height: 5),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    child:Text('Share to Twitter', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Colors.blue
                    ),
                    onPressed: () async {
                      shareGenerateImage();
                    },
                  ),
                ),
              ],
            )
          ),
        ),
      )
    );
  }
}
