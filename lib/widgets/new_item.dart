import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;//it tells dart that all the data in the package is bundelled in the object as

import '../data/categories.dart';
import '../models/category.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});


  @override
  State<NewItem> createState() => _NewItemState();

}

class _NewItemState extends State<NewItem> {
  final _formKey= GlobalKey<FormState>();
  var _enteredName="";
  var _enteredQuantity=1;
  var _selectedCategory=categories[Categories.vegetables]!;
  var _isSending=false;
  @override
  Widget build(BuildContext context) {
    void _saveItem() async{
      if(_formKey.currentState!.validate()){
        _formKey.currentState!.save();
        setState(() {
          _isSending=true;
        });
        final url=Uri.https("flutter-prep-28906-default-rtdb.firebaseio.com","Shopping-list.json");
        final response=await http.post(url,headers: {"Content-Type":"application/json"},body:json.encode({
          "name": _enteredName, "quantity": _enteredQuantity, "category": _selectedCategory.title
        }) );
        final resData=json.decode(response.body);

        if(!context.mounted){
          return;
        }
        Navigator.of(context).pop(GroceryItem(id: resData["name"], name: _enteredName, quantity: _enteredQuantity, category:_selectedCategory));
        //   GroceryItem(id: DateTime.now().toString(), name: _enteredName, quantity: _enteredQuantity, category: _selectedCategory)

      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(padding:const EdgeInsets.all(16),
        child: Form(
            key:_formKey,
            child: //form is the inbuild widget in flutter to handle forms
        Column(
          children: [
            TextFormField(
              maxLength: 50,
              decoration:const  InputDecoration(
                label: Text("Name"),
              ),
              validator: (value){
                if(value==null || value.isEmpty || value.trim().length<=1 || value.trim().length>=50 ){
                  return "Enter a valur between 1 to 50";
                }
                return null;
              },
              onSaved: (value){
                _enteredName=value!;
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      label: Text("Quantity"),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _enteredQuantity.toString(),
                      validator: (value){
                        if(value==null || value.isEmpty || int.tryParse(value)==null || int.tryParse(value)!<=0 ){
                          return "Must be a valid, positive number";
                        }
                        return null;
                      },
                    onSaved: (value){
                      _enteredQuantity=int.parse(value!);
                    },
                  ),
                ),
                const SizedBox(width: 8,),
                Expanded(
                  child: DropdownButtonFormField(value: _selectedCategory,
                      items: [
                    for(final category in categories.entries)
                      DropdownMenuItem(value:category.value,child: Row(
                        children: [
                          Container(
                            height: 16,
                            width: 16,
                            color: category.value.color,
                          ),
                          const SizedBox(width: 6,),
                          Text(category.value.title),
                        ],
                      ))
                  ], onChanged: (value){
                    setState(() {
                      _selectedCategory=value!;
                    });
                  }),
                )
              ],
            ),
            const SizedBox(height: 50,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: _isSending ? null :(){_formKey.currentState!.reset();}, child:const Text("Reset")),
                ElevatedButton(onPressed: _isSending ? null :_saveItem, child: _isSending ?const SizedBox(height: 16,width: 16,child: CircularProgressIndicator(),) :const Text("Add Item"))
              ],
            )
          ],
        )),),
    );
  }
}
