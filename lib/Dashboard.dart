import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buy!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                bool isAuthenticated = await authenticateUser(
                    _usernameController.text, _passwordController.text);
                if (isAuthenticated) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid username or password')));
                }
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Buy'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to the Pokemon World!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

Future<Database> openDB() async {
  return databaseFactoryWeb.openDatabase('user_database.db');
}

Future<void> saveUser(String username, String password) async {
  final Database db = await openDB();
  final store = intMapStoreFactory.store('users');
  await store.add(db, {'username': username, 'password': password});
}

Future<bool> authenticateUser(String username, String password) async {
  final Database db = await openDB();
  final store = intMapStoreFactory.store('users');
  final finder = Finder(filter: Filter.and([
    Filter.equals('username', username),
    Filter.equals('password', password),
  ]));
  final recordSnapshots = await store.find(db, finder: finder);
  return recordSnapshots.isNotEmpty;
}

class SignupPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                await saveUser(_usernameController.text, _passwordController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User created successfully')));
                Navigator.pop(context);
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  List<dynamic> pokemonData = [];
  dynamic selectedPokemon;

  @override
  void initState() {
    super.initState();
    fetchPokemonData();
  }

  Future<void> fetchPokemonData() async {
    final Uri url = Uri.parse('https://api.pokemontcg.io/v2/cards?q=name:gardevoir');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        pokemonData = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Pokemon Cards'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              title: Text('Buy'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: pokemonData.length,
              itemBuilder: (BuildContext context, int index) {
                final pokemon = pokemonData[index];
                final marketPrice = pokemon['tcgplayer']['prices']['holofoil']['market'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPokemon = pokemonData[index];
                    });
                  },
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Image.network(pokemon['images']['small']),
                          title: Text(pokemon['name']),
                          subtitle: Text('Market Price: \$${marketPrice?.toStringAsFixed(2) ?? ''}'),
                        ),
                        if (selectedPokemon == pokemon) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedPokemon = null;
                                    });
                                  },
                                  child: Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedPokemon != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _cardHolderController,
                      decoration: InputDecoration(
                        labelText: 'Card Holder Name',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter the card holder name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter the card number';
                        }
                        if ((value?.length?.toInt() ?? 0) < 16)  {
                          return 'Card number must be 16 digits';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter the CVV';
                        }
                        if ((value?.length?.toInt() ?? 0) <3) {
                          return 'CVV must be 3 digits';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Process the payment here
                            // For demo purposes, print the values
                            print('Card Holder: ${_cardHolderController.text}');
                            print('Card Number: ${_cardNumberController.text}');
                            print('CVV: ${_cvvController.text}');

                            // Show a dialog with the payment success message
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Payment Successful'),
                                  content: Text('Thank you for your purchase!'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Text('Purchase'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
