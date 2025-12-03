import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

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

    } on AuthException catch(e) {
      if (mounted) {
        _showSnackBar ('An unexpected error occured : $e ', isError:true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message),
      backgroundColor: isError? Colors.redAccent:Colors.green,),);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title:const Text('Login')),
    body: Center(
      child:SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Welcome Back', style: TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:Colors.blue),),
          const SizedBox (height:32),
          TextFormField(controller: _emailController, decoration:const InputDecoration(labelText:'Email'),
          keyboardType:TextInputType.emailAddress,
          ),
          const SizedBox(height:16),
          TextFormField(
            controller: _passwordController,
            decoration:const InputDecoration(labelText:'Password'),
            obscureText:true,
          ),
          const SizedBox(height:32),
          _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed:_signIn,child:const Text('Log In'),),
          const SizedBox(height:24),
          TextButton(
            onPressed:()=>Navigator.of(context).pushNamed('/signup'),
            child:const Text('Don\'t have an account? Sign Up'),
          ),
        ],),)
    ),);
  }}