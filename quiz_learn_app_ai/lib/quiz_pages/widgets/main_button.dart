import 'package:flutter/material.dart';
class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    this.title = '',
    this.enabled = true,
    this.child,
    this.color,
    required this.onTap,
  });

  final String title;
  final bool enabled;
  final Widget? child;
  final Color? color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: 55,
        child: InkWell(
          onTap: enabled == false ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: color ?? Colors.white,
            ),
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: child ??
                  Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: enabled == false
                            ? Colors.lightBlue
                            : Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
