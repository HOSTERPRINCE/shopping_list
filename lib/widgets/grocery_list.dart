import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/widgets/new_item.dart';

import '../data/categories.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  String? error;
  List<GroceryItem> _groceryItems=[];
  var _isLoading=true;
  @override
  void initState() {
    super.initState();
    _loadItem();
  }
  void _loadItem() async {

    final url=Uri.https("flutter-prep-28906-default-rtdb.firebaseio.com","Shopping-list.json");
    final response= await http.get(url);
    if(response.statusCode>=400){
      error="Unable to fetch data. Please try again later!";
    }
    if(response.body=="null"){
      setState(() {
        _isLoading=false;
      });
      return;
    }
    final listData=json.decode(response.body);
    final List<GroceryItem> loadedItems=[];
    for(final item in listData.entries){
      final category=categories.entries.firstWhere((catItem)=>catItem.value.title==item.value["category"]).value;
      loadedItems.add(GroceryItem(id: item.key, name: item.value["name"], quantity:item.value["quantity"], category: category ));
    }
    setState(() {
      _groceryItems=loadedItems;
    });
  }


  void _addItem()async{
    final newItem=await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(builder:(ctx)=> NewItem()));
    if(newItem==null || _groceryItems==[]){
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
      _isLoading=false;
    });
  }
  Future<void> removeItem(GroceryItem item) async {
    final index=_groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item has been deleted")));
    final url=Uri.https("flutter-prep-28906-default-rtdb.firebaseio.com","Shopping-list/${item.id}.json");//add item is, to not point at the whole shopping list
    final response=await http.delete(url);
    if(response.statusCode>=400){
      _groceryItems.insert(index,item);
    }

  }

  @override
  Widget build(BuildContext context) {
    Widget content=Center(child:Text("No Item added yet."));
    if(_isLoading){
      content=Center(child: CircularProgressIndicator(),);
    }
    if(_groceryItems.isNotEmpty){
      content=ListView.builder(itemCount: _groceryItems.length,itemBuilder:(ctx,index)=>
          Dismissible(key: ValueKey(_groceryItems[index].id),
            onDismissed: (direction){
            removeItem(_groceryItems[index]);
            },
            child: ListTile(title: Text(_groceryItems[index].name),
              leading: Container(height: 24,width: 24,color: _groceryItems[index].category.color,
              ),trailing: Text(_groceryItems[index].quantity.toString()),),
          ));
    }
    if(error!=null){
      content=const Center(child: Text("No Item added yet."),);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Your Groceries"),actions: [
        IconButton(onPressed: (){_addItem();}, icon: const Icon(Icons.add))
      ],),
      body:content
    );
  }
}

