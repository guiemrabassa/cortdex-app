import 'dart:convert';

import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

import 'package:share_plus/share_plus.dart';


extension NoteActions on Note {

  

  void share(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    
    Share.share(
      getPlainText(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Document getDoc() {
    return Document.fromDelta(Delta.fromJson(jsonDecode(content)));
  }

  String getPlainText() {
    return getDoc().toPlainText();
  }

  /* Future<List<NoteAttribute>> getAllAttributes() {
    return cortdexClient.getAllAttributesFromNote(noteId: id);
  } */

}



