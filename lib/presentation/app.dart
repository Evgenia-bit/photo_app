import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:photo_app/presentation/view_model.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppViewModel(),
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final (loadStatus, resultMessage) = context.select(
                (AppViewModel model) => (
                  model.loadStatus,
                  model.resultMessage,
                ),
              );

              if (loadStatus == LoadStatus.loaded) {
                final snackBar = SnackBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  content: Text(
                    resultMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                  action: SnackBarAction(
                    label: 'Ok',
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                );

                SchedulerBinding.instance.addPostFrameCallback(
                  (_) => ScaffoldMessenger.of(context).showSnackBar(snackBar),
                );
              }

              return const Column(
                children: [
                  Expanded(child: _Camera()),
                  _TextField(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Camera extends StatefulWidget {
  const _Camera({super.key});

  @override
  State<_Camera> createState() => _CameraState();
}

class _CameraState extends State<_Camera> {
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    final model = context.read<AppViewModel>();
    model.initCamera().then((controller) {
      _controller = controller;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null && _controller!.value.isInitialized) {
      return CameraPreview(_controller!);
    }
    return Container();
  }
}

class _TextField extends StatelessWidget {
  const _TextField({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.read<AppViewModel>();
    final loadStatus = context.select((AppViewModel model) => model.loadStatus);

    return TextField(
      decoration: InputDecoration(
        hintText: 'Write something...',
        suffixIcon: IconButton(
          onPressed: () {
            model.uploadPhoto();
          },
          icon: loadStatus == LoadStatus.loading
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
        ),
        contentPadding: const EdgeInsets.all(12),
        //Change this value to custom as you like
        isDense: true,
      ),
      onChanged: (v) {
        model.comment = v;
      },
      onEditingComplete: () {
        model.uploadPhoto();
      },
    );
  }
}
