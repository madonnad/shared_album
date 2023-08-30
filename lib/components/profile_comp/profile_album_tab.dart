import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_photo/bloc/bloc/profile_bloc.dart';

class ProfileAlbumTab extends StatefulWidget {
  const ProfileAlbumTab({super.key});

  @override
  State<ProfileAlbumTab> createState() => _ProfileAlbumTabState();
}

class _ProfileAlbumTabState extends State<ProfileAlbumTab> {
  var items = ['all', 'tagged'];
  String dropDownValue = 'all';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${state.myAlbums.length} Albums",
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.black54),
                  ),
                  DropdownButton<String>(
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    dropdownColor: Colors.white,
                    underline: const SizedBox(),
                    alignment: AlignmentDirectional.centerEnd,
                    value: dropDownValue,
                    items: items.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropDownValue = newValue!;
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      crossAxisCount: 2,
                      childAspectRatio: .85),
                  itemCount: state.myAlbums.length,
                  itemBuilder: (context, index) {
                    if (state.myAlbums[index].albumCoverUrl == null) {
                      context.read<ProfileBloc>().add(
                            FetchProfileAlbumCoverURL(
                              index: index,
                            ),
                          );
                    }
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        height: 177,
                        child: (state.isLoading == false &&
                                state.myAlbums[index].albumCoverUrl != null)
                            ? Image.network(
                                state.myAlbums[index].albumCoverUrl!,
                                fit: BoxFit.cover,
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.cyan,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}