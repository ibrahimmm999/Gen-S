import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:music_player/models/ads_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AdsBanner extends StatefulWidget {
  const AdsBanner({super.key, required this.listOfAds});
  final List<AdsModel> listOfAds;

  @override
  State<AdsBanner> createState() => _AdsBannerState();
}

class _AdsBannerState extends State<AdsBanner> {
  bool isAds = true;

  @override
  void initState() {
    Timer.periodic(
      Duration(seconds: widget.listOfAds.length * 6 + 20),
      (timer) async {
        setState(() {
          isAds = false;
        });
        await Future.delayed(const Duration(seconds: 20));
        setState(() {
          isAds = true;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isAds,
      child: CarouselSlider(
        items: widget.listOfAds.map((e) {
          return GestureDetector(
              onTap: () async {
                await _launchURL(e.link);
              },
              child: Image.network(
                e.url,
                width: double.infinity,
                fit: BoxFit.cover,
              ));
        }).toList(),
        options: CarouselOptions(
          scrollPhysics: const NeverScrollableScrollPhysics(),
          autoPlay: true,
          enableInfiniteScroll: true,
          viewportFraction: 1,
          enlargeCenterPage: false,
          height: 60,
          autoPlayAnimationDuration: const Duration(milliseconds: 2000),
          autoPlayInterval: const Duration(seconds: 6),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      uri = Uri.parse("http://$url");
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $url';
    }
  }
}
