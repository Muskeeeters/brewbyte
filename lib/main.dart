import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const Supabaseurl = "https://gymogmvfclamqgexjkja.supabase.co";
  const SupabaseAnnonkey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5bW9nbXZmY2xhbXFnZXhqa2phIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NzY5MTAsImV4cCI6MjA4MDI1MjkxMH0.KtAGt6QrHPu3TeRMgDxdgOXJa3RcNheaFmPLIggY0z0";
  
  await Supabase.initialize(
    url : Supabaseurl,
    anonKey: SupabaseAnnonkey,
  );
  runApp(const BrewByte());
}

class BrewByte extends StatelessWidget {
  const BrewByte({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brew Byte',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 12),),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            )
          )
        ),
        
        initialRoute: '/',
        routes: {
        '/':(context) => AuthGate(),
        '/login':(context)=>const LoginPage(),
        '/signup':(context) => SignupPage(),
        '/home':(context) =>homePage(),
    
  });
}}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build (BuildContext context) {
    return StreamBuilder<AuthState>(stream: supabase.auth.onAuthStateChange,
     builder: (context,snapshot){
      if (snapshot.connectionState == ConnectionState.active){
        final session = snapshot.data?.session;
        if(session==null){
          return const LoginPage();
        } else{
          return const Homepage();
        }
      }
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      );
     },
     
     );

  }}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key})
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async{
    setState(() => _isLoading = true);
    try{
      await supabase.auth.signInWithPassword(email: _emailController.text.trim(), password: _passwordController.text.trim(),);

    } on AuthException cath(e) {}
  }





}