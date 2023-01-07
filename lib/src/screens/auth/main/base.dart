import 'dart:math' as math;

import 'package:flukit/flukit.dart';
import 'package:flukit_icons/flukit_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef OnAuthGoingBackFunction = String Function(
    FluAuthScreenController controller,
    TextEditingController inputController,
    bool onFirstPage,
    bool onLastPage);
typedef OnAuthGoingForwardFunction = Future<bool> Function(
    FluAuthScreenController controller,
    PageController pageController,
    TextEditingController inputController,
    bool onFirstPage,
    bool onLastPage);

class FluAuthScreenParameters {
  FluAuthScreenParameters({this.canGetBack = true});

  final bool canGetBack;
}

class FluSteppedAuthScreen extends StatefulWidget {
  const FluSteppedAuthScreen({
    Key? key,
    this.controller,
    this.onGoingBack,
    this.onGoingForward,
    this.headerAction,
    this.animationDuration,
    this.animationCurve,
    this.countrySelectorTitle,
    this.countrySelectorDesc,
    this.countrySelectorSearchInputHint,
    this.bgGradient = true,
  }) : super(key: key);

  final Curve? animationCurve;
  final Duration? animationDuration;
  final bool bgGradient;
  final FluAuthScreenController? controller;
  final String? countrySelectorTitle,
      countrySelectorDesc,
      countrySelectorSearchInputHint;

  final Widget? headerAction;
  final OnAuthGoingBackFunction? onGoingBack;
  final OnAuthGoingForwardFunction? onGoingForward;

  @override
  State<FluSteppedAuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<FluSteppedAuthScreen> {
  final Curve animationCurve = Curves.fastOutSlowIn;
  final Duration animationDuration = const Duration(milliseconds: 300);
  late FluAuthScreenParameters args;
  late FluAuthScreenController controller;
  final TextEditingController inputController = TextEditingController();
  final PageController pageController = PageController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    /// initialize controller
    controller = Get.put(
        widget.controller ??
            FluAuthScreenController(initialSteps: <FluAuthScreenStep>[]),
        tag: 'AuthScreenController#${math.Random().nextInt(99999)}');

    /// Get the arguments and set controller values;
    args = (Get.arguments != null && Get.arguments is FluAuthScreenParameters)
        ? Get.arguments as FluAuthScreenParameters
        : FluAuthScreenParameters();
    controller.canGetBack = args.canGetBack;

    onInit();
    super.initState();
  }

  bool get onFirstPage => controller.stepIndex == 0;
  bool get onLastPage => controller.stepIndex == controller.steps.length - 1;

  /// check if input value is empty or not.
  /// or if the custom validator test is passed.
  String? inputValidator(
      String? value,
      bool Function(String value, FluAuthScreenController controller)?
          customValidator) {
    bool valid = false;

    if (customValidator == null) {
      valid = value!.isNotEmpty;
    } else {
      valid = value!.isNotEmpty && customValidator(value, controller);
    }

    return !valid ? 'incorrect' : null;
  }

  /// On input value changed, we reset the error state and make user able to submit or not.
  void onInputValueChanged(
      String value,
      void Function(String value, FluAuthScreenController controller)?
          callback) {
    controller.hasError = false;
    controller.canSubmit = value.isNotEmpty;
    callback?.call(value, controller);
  }

  ///handle back button "onPressed" event.
  void onBack() {
    /* if(controller.steps.length == 1) {
      widget.onGoingBack?.call(
        controller,
        inputController,
        onFirstPage,
        onLastPage
      );
    } */
    /// if we are not on first page, we call the "onGoingBack" action.
    if (!onFirstPage) {
      widget.onGoingBack
          ?.call(controller, inputController, onFirstPage, onLastPage);

      if (controller.previousInputValue.isNotEmpty) {
        inputController.text = controller.previousInputValue;
        controller.canSubmit = true;
        controller.previousInputValue = "";
      } else {
        inputController.text = "";
        controller.canSubmit = false;
      }

      controller.hasError = false;
      pageController.previousPage(
          duration: widget.animationDuration ?? animationDuration,
          curve: widget.animationCurve ?? animationCurve);
    }

    /// else just navigate to previous page.
    else {
      String? route = widget.onGoingBack
          ?.call(controller, inputController, onFirstPage, onLastPage);
      if (route != null) Get.offAllNamed(route);
    }
  }

  ///handle next button "onPressed" event.
  Future onSubmit(BuildContext context) async {
    FluAuthScreenStep step = controller.steps[controller.stepIndex];

    /// if keyboard is visible, let's hide it.
    FocusScope.of(Flu.context).unfocus();

    /// ensure that another action is not ongoing.
    if (!controller.loading) {
      bool v = false;

      if (step is FluAuthScreenCustomStep) {
        if (step.onButtonPressed != null && step.onButtonPressed!(controller)) {
          if (widget.onGoingForward != null) {
            v = await widget.onGoingForward!(controller, pageController,
                inputController, onFirstPage, onLastPage);
          }
        }
      } else if (step is FluAuthScreenInputStep) {
        if (_formKey.currentState!.validate()) {
          v = widget.onGoingForward != null &&
              await widget.onGoingForward!(controller, pageController,
                  inputController, onFirstPage, onLastPage);
        } else {
          controller.hasError = true;
          Flu.throwError(step.onError?.call(controller));
        }
      }

      if (!onLastPage && v) {
        controller.previousInputValue = inputController.text;
        inputController.text = '';

        controller.canSubmit = false;
        pageController.nextPage(
            duration: widget.animationDuration ?? animationDuration,
            curve: widget.animationCurve ?? animationCurve);
      }
    }
  }

  void onInit() async {
    await Flu.appController
        .setAuthorizationState(FluAuthorizationStates.waitAuth)
        .onError((error, stackTrace) => throw {
              "Error while setting authorizationState parameter in secure storage.",
              error,
              stackTrace
            });
  }

  Widget text(String text, {bool isTitle = false}) => FluText(
      text: text,
      textAlign: TextAlign.center,
      stylePreset: isTitle ? FluTextStyle.headlineBold : FluTextStyle.body,
      style: TextStyle(
          fontSize:
              isTitle ? Flu.appSettings.headlineFs : Flu.appSettings.bodyFs));

  @override
  Widget build(BuildContext context) {
    return FluScreen(
        systemUiOverlayStyle: Flu.theme()
            .systemUiOverlayStyle
            .copyWith(statusBarColor: Colors.transparent),
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: pageController,
                        onPageChanged: (v) {
                          controller.stepIndex = v;
                          controller.canGetBack =
                              onFirstPage ? args.canGetBack : true;
                        },
                        itemCount: controller.steps.length,
                        itemBuilder: (context, index) {
                          FluAuthScreenStep step = controller.steps[index];

                          return Column(
                            children: [
                              Expanded(
                                  child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          gradient: widget.bgGradient
                                              ? LinearGradient(
                                                  colors: [
                                                      Flu.theme()
                                                          .primary
                                                          .withOpacity(.025),
                                                      Flu.theme().background
                                                    ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter)
                                              : null),

                                      ///! TODO: add an images for each page
                                      child: controller
                                              .steps[index].image.isNotEmpty
                                          ? FluImage(
                                              controller.steps[index].image,
                                              source: controller
                                                  .steps[index].imageType,
                                            )
                                          : null)),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                        horizontal:
                                            Flu.appSettings.defaultPaddingSize)
                                    .copyWith(top: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Hero(
                                      tag: '</title>',
                                      child: text(controller.steps[index].title,
                                          isTitle: true),
                                    ),
                                    const SizedBox(height: 3),
                                    Hero(
                                        tag: '</description>',
                                        child:
                                            text(controller.steps[index].desc)),
                                    GetBuilder<FluAuthScreenController>(
                                        init: controller,
                                        initState: (_) {},
                                        builder: (_) {
                                          if (step is FluAuthScreenCustomStep) {
                                            return Container(
                                                margin: const EdgeInsets.only(
                                                    top: 35, bottom: 8),
                                                child: step.builder(
                                                    context,
                                                    controller,
                                                    inputController));
                                          } else if (step
                                              is FluAuthScreenInputStep) {
                                            return FluOutline(
                                              thickness: .85,
                                              radius: Flu.appSettings
                                                      .defaultElRadius +
                                                  2,
                                              margin: const EdgeInsets.only(
                                                  top: 35, bottom: 8),
                                              boxShadow: Flu.boxShadow(
                                                blurRadius: 30,
                                                opacity: .065,
                                                offset: const Offset(0, 0),
                                                color: Flu.theme().shadow,
                                              ),
                                              child: FluTextField(
                                                inputController:
                                                    inputController,
                                                inputFormatters: null,
                                                validator: (value) =>
                                                    inputValidator(value,
                                                        step.inputValidator),
                                                onChanged: (value) =>
                                                    onInputValueChanged(value,
                                                        step.onInputValueChanged),
                                                label: step.inputHint,
                                                borderWidth: 1.5,
                                                keyboardType:
                                                    TextInputType.text,
                                                inputAction:
                                                    TextInputAction.done,
                                                fillColor:
                                                    Flu.theme().background,
                                                borderColor:
                                                    (controller.hasError
                                                            ? Flu.theme().danger
                                                            : Flu.theme()
                                                                .background)
                                                        .withOpacity(.015),
                                                labelColor: controller.hasError
                                                    ? Flu.theme().danger
                                                    : Flu.theme().text,
                                                color: controller.hasError
                                                    ? Flu.theme().danger
                                                    : Flu.theme().accentText,
                                                height: step.inputHeight ??
                                                    Flu.appSettings
                                                            .defaultElSize -
                                                        2,
                                                cornerRadius:
                                                    step.inputRadius ??
                                                        Flu.appSettings
                                                            .defaultElRadius,
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        })
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                  AnimatedSwitcher(
                      duration: widget.animationDuration ?? animationDuration,
                      child: !Flu.isKeyboardHidden(context)
                          ? GetX<FluAuthScreenController>(
                              init: controller,
                              initState: (_) {},
                              builder: (_) {
                                return Hero(
                                  tag: '</mainButton>',
                                  child: FluButton.text(
                                    onPressed: controller.canSubmit
                                        ? () => onSubmit(context)
                                        : null,
                                    text: controller.steps[controller.stepIndex]
                                        .buttonLabel,
                                    prefixIcon: controller
                                        .steps[controller.stepIndex].buttonIcon,
                                    spacing: 5,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    style: FluButtonStyle.primary.copyWith(
                                      block: true,
                                      height: Flu.appSettings.defaultElSize,
                                      cornerRadius:
                                          Flu.appSettings.defaultElRadius,
                                      padding: EdgeInsets.zero,
                                      margin: EdgeInsets.symmetric(
                                              horizontal: Flu.appSettings
                                                  .defaultPaddingSize)
                                          .copyWith(bottom: 25),
                                      color: controller.canSubmit
                                          ? Flu.theme().onPrimary
                                          : Flu.theme().accentText,
                                      background: controller.canSubmit
                                          ? Flu.theme().primary
                                          : Flu.theme().primary.withOpacity(.1),
                                      boxShadow: Flu.boxShadow(
                                          color: Flu.theme().shadow,
                                          opacity: controller.canSubmit
                                              ? .085
                                              : .085,
                                          blurRadius: 20,
                                          offset: const Offset(0, 0)),
                                      iconSize: 20,
                                      iconStrokewidth: 1.8,
                                      loading: controller.loading,
                                    ),
                                  ),
                                );
                              })
                          : Container())
                ],
              ),
              Positioned(
                top: Flu.statusBarHeight,
                child: Container(
                    width: Flu.screenSize.width,
                    padding: EdgeInsets.symmetric(
                            horizontal: Flu.appSettings.defaultPaddingSize)
                        .copyWith(top: 8),
                    child: Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AnimatedOpacity(
                              opacity: controller.canGetBack ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Hero(
                                tag: '</backButton>',
                                child: FluButton.icon(
                                  onPressed: controller.canGetBack
                                      ? () => onBack()
                                      : null,
                                  icon: FluIcons.arrowLeft,
                                  style: FluButtonStyle(
                                    height: Flu.appSettings.minElSize - 5,
                                    square: true,
                                    padding: EdgeInsets.zero,
                                    cornerRadius: Flu.appSettings.minElRadius,
                                    background:
                                        Flu.theme().background.withOpacity(.25),
                                    color: Flu.theme().accentText,
                                    boxShadow: Flu.boxShadow(
                                        color: widget.bgGradient
                                            ? Flu.theme().primary
                                            : Flu.theme().shadow,
                                        offset: const Offset(-15, 15),
                                        opacity: .1),
                                    iconSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            widget.headerAction ??
                                AnimatedOpacity(
                                  opacity: onFirstPage ? 1 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: FluButton(
                                      onPressed: onFirstPage
                                          ? () =>
                                              Flu.showCountrySelectionBottomSheet(
                                                context: context,
                                                title:
                                                    widget.countrySelectorTitle,
                                                desc:
                                                    widget.countrySelectorDesc,
                                                searchInputHint: widget
                                                    .countrySelectorSearchInputHint,
                                                onCountrySelected:
                                                    (Country country) {
                                                  controller.setRegion(
                                                      country.isoCode);
                                                },
                                              )
                                          : null,
                                      style: FluButtonStyle(
                                        height: Flu.appSettings.minElSize - 5,
                                        cornerRadius:
                                            Flu.appSettings.minElRadius,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        background: Flu.theme()
                                            .background
                                            .withOpacity(.25),
                                        boxShadow: Flu.boxShadow(
                                            color: widget.bgGradient
                                                ? Flu.theme().primary
                                                : Flu.theme().shadow,
                                            offset: const Offset(15, 15),
                                            opacity: .1),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: controller.countriesLoading
                                            ? SizedBox(
                                                height: 15,
                                                width: 15,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Flu.theme().accentText,
                                                  ),
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Row(children: [
                                                Text(
                                                  controller.region == null
                                                      ? 'Togo'
                                                      : controller.region!.name,
                                                  style: Flu
                                                      .textTheme.bodyText1!
                                                      .copyWith(
                                                    color:
                                                        Flu.theme().accentText,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Container(
                                                    height: 20,
                                                    width: 25,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      child: Image.asset(
                                                        'icons/flags/png/${controller.countryCode.toLowerCase()}.png',
                                                        package:
                                                            'country_icons',
                                                        fit: BoxFit.fill,
                                                      ),
                                                    )),
                                              ]),
                                      )),
                                )
                          ],
                        ))),
              ),
            ],
          ),
        ));
  }
}
