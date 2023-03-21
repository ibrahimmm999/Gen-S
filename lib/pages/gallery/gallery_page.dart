import 'package:flutter/material.dart';
import 'package:music_player/pages/gallery/empty_gallery_page.dart';
import 'package:music_player/providers/user_provider.dart';
import 'package:music_player/shared/theme.dart';
import 'package:music_player/widgets/custom_popup.dart';
import 'package:music_player/widgets/gallery_grid.dart';
import 'package:music_player/widgets/setting_button.dart';
import 'package:provider/provider.dart';

import '../../providers/gallery_provider.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    GalleryProvider galleryProvider = Provider.of<GalleryProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);
    TextEditingController galleryController = TextEditingController(text: "");

    Widget header() {
      return SliverPadding(
        padding:
            EdgeInsets.only(right: defaultMargin, left: defaultMargin, top: 24),
        sliver: SliverAppBar(
          stretch: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Gallery",
                style: userProvider.user.role == "USER"
                    ? primaryUserColorText.copyWith(
                        fontSize: 24, fontWeight: bold)
                    : primaryAdminColorText.copyWith(
                        fontSize: 24, fontWeight: bold),
              ),
              Row(
                children: [
                  userProvider.user.role == "USER"
                      ? const SizedBox()
                      : Icon(
                          Icons.delete_outline_outlined,
                          size: 36,
                          color: primaryAdminColor,
                        ),
                  const SizedBox(width: 16),
                  userProvider.user.role == "USER"
                      ? const SettingButton()
                      : GestureDetector(
                          onTap: () {
                            showDialog(
                              builder: (BuildContext context) {
                                return CustomPopUp(
                                    title: "Gallery Name",
                                    add: () {},
                                    controller: galleryController);
                              },
                              context: context,
                            );
                          },
                          child: Icon(
                            Icons.add,
                            color: primaryAdminColor,
                            size: 36,
                          ),
                        ),
                ],
              ),
            ],
          ),
          backgroundColor: userProvider.user.role == "USER"
              ? backgroundUserColor
              : backgroundAdminColor,
          floating: true,
          snap: true,
        ),
      );
    }

    Widget content() {
      return GridView(
        padding:
            const EdgeInsets.only(top: 24, bottom: 100, left: 20, right: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1 / 1.4,
          crossAxisSpacing: 30,
        ),
        children: galleryProvider.galleries
            .map(
              (gallery) => GalleryGrid(
                gallery: gallery,
              ),
            )
            .toList(),
      );
    }

    return Scaffold(
      backgroundColor: userProvider.user.role == "USER"
          ? backgroundUserColor
          : backgroundAdminColor,
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              header(),
            ];
          },
          body: galleryProvider.galleries.isEmpty
              ? const EmptyGalleryPage()
              : content(),
        ),
      ),
    );
  }
}
