import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    print("build UI");
    return Scaffold(
      body: Container(
        child: Text("Homepage"),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();
    // TODO: implement build
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(Icons.menu),
//          StreamBuilder(
//            stream: bloc.listStream,
//            builder: (context, snapshot) {
//              List<FoodItem> foodItems = snapshot.data;
//              int length = foodItems != null ? foodItems.length : 0;
//
//              return buildGestureDetector(length, context, foodItems);
//            },
//          )
        ],
      ),
    );
  }
}
