import 'package:eorderbook/models/area.dart';
import 'package:eorderbook/models/sector.dart';
import 'package:eorderbook/screens/select_customer_screen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class SelectSectorAndAreaScreen extends StatefulWidget {
  const SelectSectorAndAreaScreen({Key? key}) : super(key: key);

  @override
  State<SelectSectorAndAreaScreen> createState() => _SelectSectorAndAreaScreenState();
}

class _SelectSectorAndAreaScreenState extends State<SelectSectorAndAreaScreen> {
  @override
  void initState() {
    super.initState();
    fetchSector();
  }

  List<Sector> fetchd = [];
  Sector selected=Sector(id: -1, distCode: -1, secCd: -1, name: "Select Sector");
  Area selectedArea=Area(id: -1, distCode: -1, areaCd: -1, name: "Select Area", secCd: -1);
  fetchSector() async {

    fetchd.add(selected);
    final Database database = await openDatabase('eOrderBook.db');

    List<Map<String, dynamic>> parties =
    await database.rawQuery("SELECT * FROM Sector where seccd!=0");

    database.close();

    for (var sector in parties) {
      fetchd.add(
          Sector(id: sector['ID'], distCode: sector['dist_code'], secCd: sector['seccd'], name: sector['name']));
    }

    setState(() {

    });

  }
  List<Area>areas=[Area(id: -1, distCode: -1, areaCd: -1, name: "Select Area", secCd: -1)];
  fetchArea() async {
    areas.clear();
    areas.add(Area(id: -1, distCode: -1, areaCd: -1, name: "Select Area", secCd: -1));
    final Database database = await openDatabase('eOrderBook.db');

    List<Map<String, dynamic>> areaQuery =
    await database.rawQuery("SELECT * FROM Area where SecCd=${selected.secCd}");

    database.close();

    for (var area in areaQuery) {
      areas.add(
          Area(id: area['ID'], areaCd: area['areacd'], distCode: area['dist_code'], name: area['name'], secCd: area['seccd']));
    }
    setState(() {

    });
  }

  String selectedSectorItem="Select Sector";
  bool sectorSelected=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Sector and Area"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("Select Sector:"),
          const SizedBox(height: 8,),
          DropdownButton<Sector>(
            value: selected,
            onChanged: (Sector? newValue) async{
              selected = newValue!;
              fetchArea();
              setState(() {

                if(selected!=fetchd[0]){
                  sectorSelected=true;
                }else{
                  sectorSelected=false;
                }
              });
            },
            items: fetchd.map<DropdownMenuItem<Sector>>((Sector value) {
              return DropdownMenuItem<Sector>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(value.name),
                ),
              );
            }).toList(),
          ),

          Visibility(
            visible: sectorSelected,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Area"),
                const SizedBox(height: 8,),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButton<Area>(
                    value: areas[0],
                    onChanged: (Area? newValue) {
                      setState(() {
                        selectedArea = newValue!;
                        // debugPrint(selectedArea.toMap());
                        if(selectedArea!=areas[0]){
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  SelectCustomerScreen(sectorId: selected,areaId: selectedArea,)));
                        }
                      });
                    },
                    items: areas.map<DropdownMenuItem<Area>>((Area value) {
                      return DropdownMenuItem<Area>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(value.name),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
