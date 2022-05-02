import 'package:flukit_icons/flukit_icons.dart';
import 'package:flutter/material.dart';

import '../../flukit.dart';

class FluBottomNavBarItemData {
  final FluIconModel icon;
  final String label;

  FluBottomNavBarItemData({required this.icon, required this.label});
}

class FluBottomNavBar extends StatefulWidget {
  final double selectedIndex;
  final Color background, color, activeColor;
  final Duration duration;
  final Curve curve;
  final Function(int) onTap;
  final List<FluBottomNavBarItemData> items;

  const FluBottomNavBar({
    Key? key,
    required this.activeColor,
    required this.color,
    required this.background,
    required this.duration,
    required this.curve,
    required this.onTap,
    required this.items,
    this.selectedIndex = 0
  }) : super(key: key);

  @override
  State<FluBottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<FluBottomNavBar> {
  final GlobalKey itemKey = GlobalKey();
  double itemWidth = 0;

  void getItemWidth() {
    final RenderBox box = itemKey.currentContext?.findRenderObject() as RenderBox;
    final double width = box.size.width;
    setState(() => itemWidth = width);
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) => getItemWidth());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: FluConsts.bottomNavBarHeight,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.symmetric(
        horizontal: FluConsts.bottomNavBarHMarginSize
      ).copyWith(bottom: FluConsts.bottomNavBarBMarginSize),
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: BorderRadius.circular(FluConsts.bottomNavBarRadius)
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: widget.items.map((FluBottomNavBarItemData item) {
              int index = widget.items.indexOf(item);

              return _BottomNavBarItem(
                key: index == 0 ? itemKey : null,
                onTap: () => widget.onTap(index),
                data: item,
                color: widget.selectedIndex.round() == index ? widget.activeColor : widget.color,
              );
            }).toList()
          ),
          _Indicator(
            selectedIndex: widget.selectedIndex,
            height: 6.5,
            maxWidth: itemWidth,
            duration: widget.duration,
            curve: widget.curve,
            color: widget.activeColor
          )
        ],
      )
    );
  }
}

class _BottomNavBarItem extends StatelessWidget {
  final FluBottomNavBarItemData data;
  final Color color;
  final void Function() onTap;

  const _BottomNavBarItem({
    Key? key,
    required this.data,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FluButton(
        onPressed: () => {
          onTap()
        },
        height: double.infinity,
        width: double.infinity,
        backgroundColor: Colors.transparent,
        radius: 0,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: FluIcon(
            icon: data.icon,
            color: color,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final double selectedIndex;
  final double height, maxWidth, radius;
  final Color color;
  final Duration duration;
  final Curve curve;

  const _Indicator({
    Key? key,
    required this.selectedIndex,
    required this.height,
    required this.maxWidth,
    required this.color,
    required this.duration,
    required this.curve,
    this.radius = 8
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      bottom: 0,
      left: selectedIndex * maxWidth,
      duration: duration,
      curve: curve,
      child: Container(
        height: height,
        width: maxWidth,
        alignment: Alignment.bottomCenter,
        child: Container(
          height: double.infinity,
          width: height * 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius)
            ),
            boxShadow: [Flukit.boxShadow(
              blurRadius: 30,
              offset: const Offset(0, -4),
              color: color.withOpacity(.5)
            )]
          )
        )
      )
    );
  }
}