
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// Measured against iOS 12 in Xcode.
const EdgeInsets _kButtonPadding = EdgeInsets.all(0.0);
const EdgeInsets _kBackgroundButtonPadding = EdgeInsets.all(0.0);
const Color _kHoverColor = Color(0xfff2f2f2);

/// An iOS-style button.
///
/// Takes in a text or an icon that fades out and in on touch. May optionally have a
/// background.
///
/// The [padding] defaults to 16.0 pixels. When using a [CupertinoButton] within
/// a fixed height parent, like a [CupertinoNavigationBar], a smaller, or even
/// [EdgeInsets.zero], should be used to prevent clipping larger [child]
/// widgets.
///
/// See also:
///
///  * <https://developer.apple.com/ios/human-interface-guidelines/controls/buttons/>
class HoverButton extends StatefulWidget {
  /// Creates an iOS-style button.
  const HoverButton({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = 0,
    this.hoverColor = _kHoverColor,
    this.borderRadius,
    this.onPressed,
    this.alignment = Alignment.center,
  }) :  _filled = false,
        super(key: key);

  /// Creates an iOS-style button with a filled background.
  ///
  /// The background color is derived from the [CupertinoTheme]'s `primaryColor`.
  ///
  /// To specify a custom background color, use the [color] argument of the
  /// default constructor.
  const HoverButton.filled({
    Key? key,
    required this.child,
    this.padding,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = 0,
    this.hoverColor = _kHoverColor,
    this.borderRadius,
    this.onPressed,
    this.alignment = Alignment.center,
  }) :  color = null,
        _filled = true,
        super(key: key);

  final Alignment alignment;

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget child;

  /// The amount of space to surround the child inside the bounds of the button.
  ///
  /// Defaults to 16.0 pixels.
  final EdgeInsetsGeometry? padding;

  /// The color of the button's background.
  ///
  /// Defaults to null which produces a button with no background or border.
  ///
  /// Defaults to the [CupertinoTheme]'s `primaryColor` when the
  /// [CupertinoButton.filled] constructor is used.
  final Color? color;

  /// The color of the button's background when the button is disabled.
  ///
  /// Ignored if the [CupertinoButton] doesn't also have a [color].
  ///
  /// Defaults to [CupertinoColors.quaternarySystemFill] when [color] is
  /// specified. Must not be null.
  final Color disabledColor;

  /// The callback that is called when the button is tapped or otherwise activated.
  ///
  /// If this is set to null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Minimum size of the button.
  ///
  /// Defaults to kMinInteractiveDimensionCupertino which the iOS Human
  /// Interface Guidelines recommends as the minimum tappable area.
  final double minSize;

  /// The opacity that the button will fade to when it is pressed.
  /// The button will have an opacity of 1.0 when it is not pressed.
  ///
  /// This defaults to 0.4. If null, opacity will not change on pressed if using
  /// your own custom effects is desired.
  final Color hoverColor;

  /// The radius of the button's corners when it has a background color.
  ///
  /// Defaults to round corners of 8 logical pixels.
  final BorderRadius? borderRadius;

  final bool _filled;

  /// Whether the button is enabled or disabled. Buttons are disabled by default. To
  /// enable a button, set its [onPressed] property to a non-null value.
  bool get enabled => onPressed != null;

  @override
  _HoverButtonState createState() => _HoverButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'));
  }
}

class _HoverButtonState extends State<HoverButton> {

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      setState(() {
        _buttonHeldDown = true;
      });
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      setState(() {
        _buttonHeldDown = false;
      });
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      setState(() {
        _buttonHeldDown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    final CupertinoThemeData themeData = CupertinoTheme.of(context);
    final Color primaryColor = themeData.primaryColor;
    Color? backgroundColor;
    if(enabled){
      if(_buttonHeldDown){
        backgroundColor = widget.hoverColor;
      }else{
        backgroundColor = widget.color == null
            ? (widget._filled ? primaryColor : null)
            : CupertinoDynamicColor.resolve(widget.color!, context);
      }
    }else{
      backgroundColor = CupertinoDynamicColor.resolve(widget.disabledColor, context);
    }

    final Color foregroundColor = backgroundColor != null
        ? themeData.primaryContrastingColor
        : enabled
        ? primaryColor
        : CupertinoDynamicColor.resolve(CupertinoColors.placeholderText, context);

    final TextStyle textStyle = themeData.textTheme.textStyle.copyWith(color: foregroundColor);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      onTap: widget.onPressed,
      child: Semantics(
        button: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.minSize,
            minHeight: widget.minSize,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              color: backgroundColor,
            ),
            child: Padding(
              padding: widget.padding ?? (backgroundColor != null
                  ? _kBackgroundButtonPadding
                  : _kButtonPadding),
              child: Align(
                alignment: widget.alignment,
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: DefaultTextStyle(
                  style: textStyle,
                  child: IconTheme(
                    data: IconThemeData(color: foregroundColor),
                    child: widget.child,
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