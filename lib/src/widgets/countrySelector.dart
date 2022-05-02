import 'package:flukit_icons/flukit_icons.dart';
import 'package:flutter/material.dart';

import '../../flukit.dart';

class FluCountrySelect extends StatefulWidget {
  final void Function(FluCountryModel) onSelect;
  
  const FluCountrySelect(this.onSelect, {Key? key}) : super(key: key);

  @override
  State<FluCountrySelect> createState() => FluCountrySelectState();
}

class FluCountrySelectState extends State<FluCountrySelect> {
  late List<FluCountryModel> foundCountries;

  final double height = Flukit.screenSize.height * .85, radius = Flukit.screenSize.width * .08, flagRadius = 20, flagSize = 50;

  BorderRadius get borderRadius => BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
  );

  void filter(String enteredKeyword) {
    List<FluCountryModel> results = [];

    if (enteredKeyword.isEmpty) {
      results = Flukit.countries;
    } else {
      results = Flukit.countries.where((FluCountryModel country) => 
        country.name.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
        country.phoneCode.toLowerCase().contains(enteredKeyword.toLowerCase()
      )).toList();
    }

    setState(() => foundCountries = results);
  }

  @override
  void initState() {
    foundCountries = Flukit.countries;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: DraggableScrollableSheet(
      initialChildSize: 1,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              height: 4,
              width: Flukit.screenSize.width * .2,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Flukit.theme.backgroundColor.withOpacity(.5),
                borderRadius: BorderRadius.circular(2)
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Flukit.theme.backgroundColor,
                  borderRadius: borderRadius
                ),
                child:  ClipRRect(
                  borderRadius: borderRadius,
                  child: Scrollbar(
                    radius: const Radius.circular(10),
                    child: ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(FluConsts.defaultPaddingSize),
                      children: <Widget>[
                        Text(
                          'Select your country. 🧭',
                          style: Flukit.textTheme.headline1!.copyWith(
                            fontSize: FluConsts.subHeadlineFs,
                            color: Flukit.theme.palette.accentText
                          )
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Quaerat repellendus qui. Inventore praesentium assumenda vero soluta sit.',
                          style: Flukit.textTheme.bodyText1
                        ),
                        FluTextInput(
                          height: FluConsts.defaultElSize,
                          margin: const EdgeInsets.only(bottom: 25, top: 25),
                          textAlign: TextAlign.left,
                          hintText: 'Search',
                          prefixIcon: FluTwotoneIcons.search_searchNormal,
                          iconSize: 18,
                          iconStrokeWidth: 2,
                          borderWidth: 1.2,
                          /* boxShadow: [Flukit.boxShadow(
                            blurRadius: 30,
                            opacity: .085,
                            offset: const Offset(0,5),
                            color: Flukit.theme.primaryColor
                          )], */
                          onChanged: (value) => filter(value),
                        ),
                      ] + (foundCountries.isNotEmpty ? foundCountries.map((FluCountryModel country) {
                        return FluButton(
                          onPressed: () {
                            widget.onSelect(country);
                            Navigator.pop(context);
                          },
                          height: null,
                          padding: const EdgeInsets.all(6).copyWith(right: 10),
                          margin: const EdgeInsets.only(bottom: 10),
                          backgroundColor: Flukit.theme.secondaryColor.withOpacity(.45),
                          radius: flagRadius + 2,
                          child: Row(
                            children: [
                              FluOutline(
                                spacing: 3,
                                margin: const EdgeInsets.only(right: 10),
                                radius: flagRadius + 2,
                                boxShadow: Flukit.boxShadow(
                                  offset: const Offset(0, 0),
                                  opacity: .2,
                                  color: Flukit.theme.primaryColor
                                ),
                                child: Container(
                                  height: flagSize,
                                  width: flagSize,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(flagRadius),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'icons/flags/png/${country.isoCode.toLowerCase()}.png',
                                        package: 'country_icons'
                                      ),
                                      fit: BoxFit.fill,
                                    )
                                  ),
                                ),
                              ),
                              Expanded(child: Text(country.name, overflow: TextOverflow.ellipsis, style: Flukit.textTheme.bodyText1!.copyWith(
                                fontWeight: FluConsts.textSemibold
                              ))),
                              const SizedBox(width: 5),
                              Text('+${country.phoneCode}', textAlign: TextAlign.right, style: Flukit.textTheme.bodyText1!.copyWith(
                                fontWeight: FluConsts.textLight,
                                color: Flukit.theme.palette.accentText
                              ))
                            ]
                          )
                        );
                      }).toList()  : [const Center(
                        /// Todo show illustrations.
                        child: Text('Empty'),
                      )])
                    )
                  )
                )
              ),
            )
          ]
        );
      },
    )
  );
}