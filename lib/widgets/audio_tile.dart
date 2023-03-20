import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:music_player/models/audio_model.dart';
import 'package:music_player/providers/playlist_provider.dart';
import 'package:music_player/widgets/delete_popup.dart';
import 'package:provider/provider.dart';

import '../providers/audio_player_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/user_provider.dart';
import '../shared/theme.dart';

class AudioTile extends StatelessWidget {
  final bool isHistory;
  final bool isMostPlayed;
  final bool isSearch;
  final AudioModel audio;
  final List<AudioModel> playlist;

  const AudioTile({
    this.isHistory = false,
    this.isMostPlayed = false,
    this.isSearch = false,
    required this.audio,
    required this.playlist,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AudioPlayerProvider audioPlayerProvider =
        Provider.of<AudioPlayerProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    PlaylistProvider playlistProvider = Provider.of<PlaylistProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    int index = playlist.indexOf(audio);

    return GestureDetector(
      onTap: () async {
        audioPlayerProvider.setPlay(
          playlist,
          index,
        );
      },
      child: StreamBuilder<SequenceState?>(
          stream: audioPlayerProvider.audioPlayer.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            bool isSelect = false;
            if (state?.sequence.isNotEmpty ?? false) {
              AudioModel curraudio = state!.currentSource!.tag;
              isSelect = curraudio.id == audio.id;
            }
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              color: backgroundColor,
              child: Row(
                children: [
                  Visibility(
                    visible: isMostPlayed,
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      width: 30,
                      child: Text(
                        index + 1 < 10
                            ? "0${index + 1}"
                            : {index + 1}.toString(),
                        style:
                            (isSelect ? secondaryColorText : primaryColorText)
                                .copyWith(
                                    fontWeight: bold,
                                    fontSize: 20,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 0.1
                                      ..color = primaryColor),
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    margin: const EdgeInsets.only(right: 24),
                    width: 60,
                    child: audio.images.isEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              "assets/bg_song_example.png",
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: audio.images[0].url,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Text(
                      audio.title,
                      overflow: TextOverflow.ellipsis,
                      style: (isSelect ? secondaryColorText : primaryColorText)
                          .copyWith(
                        fontSize: 16,
                        fontWeight: bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      StreamBuilder<PlayerState>(
                          stream:
                              audioPlayerProvider.audioPlayer.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final playing = playerState?.playing;
                            return Visibility(
                              visible: isSelect && (playing ?? false),
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: secondaryColor,
                                size: 24,
                              ),
                            );
                          }),
                      const SizedBox(width: 20),
                      Visibility(
                        visible: !isHistory &&
                            audio.uploaderId == userProvider.user.id,
                        child: PopupMenuButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: isSelect ? secondaryColor : primaryColor,
                          ),
                          color: dropDownColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(defaultRadius),
                          ),
                          elevation: 4,
                          onSelected: (value) {
                            if (value == 0) {
                              showDialog(
                                context: context,
                                builder: (context) => DeletePopUp(
                                  delete: () async {
                                    if (await audioProvider.deleteAudio(
                                        audioId: audio.id)) {
                                      audioPlayerProvider.deleteAudio(
                                          audioId: audio.id);
                                      playlistProvider
                                          .deleteAudioFromAllPlaylist(
                                              audioId: audio.id);
                                      ScaffoldMessenger.of(context)
                                          .removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: successColor,
                                          content: const Text(
                                            'Delete audio successfuly',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: alertColor,
                                          content: Text(
                                            audioProvider.errorMessage,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 0,
                              child: Center(
                                child: Text(
                                  'Delete',
                                  style:
                                      primaryColorText.copyWith(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }
}
