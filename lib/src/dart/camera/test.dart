
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cortdex/main.dart';
import 'package:cortdex/src/dart/camera/hook.dart';


class CameraWidget extends HookConsumerWidget {
  const CameraWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    // Create a state for the CameraController
    final controller = useCameraController(cameras.first, ResolutionPreset.max);
    // Use `useFuture` to track the initialization


    
        
    
    return controller == null 
    ? const Center(child: CircularProgressIndicator())
    : const Center(child: CircularProgressIndicator());
    // : controller.buildPreview();

  }
}

