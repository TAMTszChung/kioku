import 'package:flutter/material.dart';

Future<String?> showTextInputDialog(BuildContext context,
    {required String title,
    required String hintText,
    required String okText,
    required String cancelText,
    required String? Function(String?) validator}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return _PromptDialog(
          title: title,
          hintText: hintText,
          okText: okText,
          cancelText: cancelText,
          validator: validator);
    },
  );
}

class _PromptDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String okText;
  final String cancelText;
  final String? Function(String?) validator;

  const _PromptDialog(
      {Key? key,
      required this.title,
      required this.hintText,
      required this.okText,
      required this.cancelText,
      required this.validator})
      : super(key: key);

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  final TextEditingController _textFieldController = TextEditingController();
  String errorText = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: widget.hintText),
          ),
          Visibility(
            child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  errorText,
                  style: const TextStyle(color: Colors.red),
                )),
            visible: errorText.isNotEmpty,
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(widget.cancelText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(widget.okText),
          onPressed: () {
            String? error = widget.validator(_textFieldController.text);
            if (error != null) {
              setState(() {
                errorText = error;
              });
              return;
            }
            Navigator.pop(context, _textFieldController.text);
          },
        ),
      ],
    );
  }
}
