import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:movies/src/Filter/filter_controler.dart';
import 'package:movies/src/Filter/filter_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterView extends StatefulWidget {
  static const routeName = '/filter';
  final Filter filter;

  const FilterView({super.key, required this.filter});

  @override
  State<StatefulWidget> createState() => FilterViewState();
}

class FilterViewState extends State<FilterView> {
  late final FilterController controller;
  bool movieIsSelected = true;
  bool tvIsSelected = true;
  bool fsk0 = false;
  bool fsk6 = false;
  bool fsk12 = false;
  bool fsk16 = false;
  bool fsk18 = false;
  RangeValues _durationrange = const RangeValues(60, 120);
  double rating = 0;
  int yearFrom = 0;
  int yearTo = 6000;
  double _fontSize = 16.0;
  bool accending = true;
  List<String> sortOptions = [
    'Standard',
    'Hinzugefügt',
    'Bewertung',
    'Jahr',
    'Public Rating',
    'Alphabetisch',
    'Dauer',
  ];
  final List<String> allGenres = [
    'Action',
    'Komödie',
    'Drama',
    'Thriller',
    'Adventure',
    'Animation',
    'Krimi',
    'Familie',
    'Fantasy',
    'Historie',
    'Horror',
    'Liebesfilm',
    'Science Fiction',
    'Kriegsfilm',
    'Western',
  ];

  final List<String> initialGenres = ['Action', 'Komödie', 'Drama', 'Thriller'];

  List<String> selectedGenres = [];
  bool showAllGenres = false;

  TextEditingController dropdownController = TextEditingController();

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('font_size') ?? 16.0; // Standardwert
    });
  }

  @override
  void initState() {
    controller = FilterController(filter: widget.filter);
    setState(() {
      movieIsSelected =
          controller.model.filter.movie == 1 ||
          controller.model.filter.movie == 3;
      tvIsSelected =
          controller.model.filter.movie == 2 ||
          controller.model.filter.movie == 3;
      fsk0 = controller.model.filter.fsk.contains('0');
      fsk6 = controller.model.filter.fsk.contains('6');
      fsk12 = controller.model.filter.fsk.contains('12');
      fsk16 = controller.model.filter.fsk.contains('16');
      fsk18 = controller.model.filter.fsk.contains('18');
      _durationrange = RangeValues(
        controller.model.filter.durationFrom.toDouble(),
        controller.model.filter.durationTo.toDouble(),
      );
      rating = controller.model.filter.rating;
      yearFrom = controller.model.filter.yearFrom;
      yearTo = controller.model.filter.yearTo;
      dropdownController.text = controller.model.filter.sortBy;
      accending = controller.model.filter.accending;
      selectedGenres = controller.model.filter.genres.toList();
    });
    _loadFontSize();
    super.initState();
  }

  _toggleMovieButton() {
    controller.setMovie();
    if (movieIsSelected == true) {
      _durationrange = const RangeValues(30, 180);
      controller.setDuration(const RangeValues(30, 180));
    }
    setState(() {
      movieIsSelected = !movieIsSelected;
      if (!movieIsSelected && !tvIsSelected) {
        movieIsSelected = true;
        tvIsSelected = true;
      } // Wechseln des Zustands
    });
  }

  _toggleTvButton() {
    controller.setTv();
    controller.setDuration(const RangeValues(30, 180));
    setState(() {
      _durationrange = const RangeValues(30, 180);
      tvIsSelected = !tvIsSelected;
      if (!movieIsSelected && !tvIsSelected) {
        movieIsSelected = true;
        tvIsSelected = true;
      } // Wechseln des Zustands
      if (controller.model.filter.sortBy == 'Dauer') {
        controller.setSortBy('Standard');
        dropdownController.text = 'Standard';
      }
    });
  }

  _togglefsk0() {
    controller.setFsk0();
    setState(() {
      fsk0 = !fsk0; // Wechseln des Zustands
    });
  }

  _togglefsk6() {
    controller.setFsk6();
    setState(() {
      fsk6 = !fsk6; // Wechseln des Zustands
    });
  }

  _togglefsk12() {
    controller.setFsk12();
    setState(() {
      fsk12 = !fsk12; // Wechseln des Zustands
    });
  }

  _togglefsk16() {
    controller.setFsk16();
    setState(() {
      fsk16 = !fsk16; // Wechseln des Zustands
    });
  }

  _togglefsk18() {
    controller.setFsk18();
    setState(() {
      fsk18 = !fsk18; // Wechseln des Zustands
    });
  }

  _toggleAccending() {
    controller.setAccending();
    setState(() {
      accending = !accending; // Wechseln des Zustands
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleGenres =
        showAllGenres
            ? allGenres
            : {
              ...selectedGenres, // alle gewählten
              ...initialGenres, // plus die „Startanzeige“
            }.toList();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(controller.model.filter);
          },
          icon: const Icon(Icons.arrow_back_sharp),
          //replace with our own icon data.
        ),
        title: const Text('Filter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_sharp),
            onPressed: () {
              controller.resetFilter();
              setState(() {
                controller.setSortBy('Standard');
                dropdownController.text = 'Standard';
                controller.model.filter.accending = true;
                accending = true;
                movieIsSelected = true;
                tvIsSelected = true;
                fsk0 = false;
                fsk6 = false;
                fsk12 = false;
                fsk16 = false;
                fsk18 = false;
                _durationrange = const RangeValues(30, 180);
                rating = 0;
                yearFrom = 0;
                yearTo = 6000;
                selectedGenres = [];
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style:
                      movieIsSelected
                          ? ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            foregroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                          : null,
                  onPressed: _toggleMovieButton,
                  child: Text('Filme', style: TextStyle(fontSize: _fontSize)),
                ),
                ElevatedButton(
                  style:
                      tvIsSelected
                          ? ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            foregroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                          : null,
                  onPressed: _toggleTvButton,
                  child: Text('Serien', style: TextStyle(fontSize: _fontSize)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text("FSK", style: TextStyle(fontSize: _fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          _togglefsk0();
                        },
                        child:
                            fsk0
                                ? Image.asset('assets/images/FSK0.png')
                                : Image.asset('assets/images/FSK0-bw.png'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          _togglefsk6();
                        },
                        child:
                            fsk6
                                ? Image.asset('assets/images/FSK6.png')
                                : Image.asset('assets/images/FSK6-bw.png'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          _togglefsk12();
                        },
                        child:
                            fsk12
                                ? Image.asset('assets/images/FSK12.png')
                                : Image.asset('assets/images/FSK12-bw.png'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          _togglefsk16();
                        },
                        child:
                            fsk16
                                ? Image.asset('assets/images/FSK16.png')
                                : Image.asset('assets/images/FSK16-bw.png'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          _togglefsk18();
                        },
                        child:
                            fsk18
                                ? Image.asset('assets/images/FSK18.png')
                                : Image.asset('assets/images/FSK18-bw.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text("Dauer", style: TextStyle(fontSize: _fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25, left: 25),
              child: RangeSlider(
                values: _durationrange,
                max: 180,
                min: 30,
                labels: RangeLabels(
                  _durationrange.start.round().toString(),
                  _durationrange.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  controller.setDuration(values);
                  if (values.start != 30 || values.end != 180) {
                    controller.model.filter.movie = 1;
                  }
                  setState(() {
                    tvIsSelected = false;
                    movieIsSelected = true;
                    _durationrange = values;
                  });
                },
                divisions: 30,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text("Bewertung", style: TextStyle(fontSize: _fontSize)),
            ),
            StarRating(
              mainAxisAlignment: MainAxisAlignment.center,
              size: 60.0,
              rating: rating,
              color: Colors.orange,
              borderColor: Colors.grey,
              allowHalfRating: true,
              starCount: 5,
              onRatingChanged:
                  (rating) => setState(() {
                    controller.setRating(rating);
                    this.rating = rating;
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text("Genres", style: TextStyle(fontSize: _fontSize)),
            ),

            Wrap(
              spacing: 8.0,
              children:
                  visibleGenres.map((genre) {
                    final isSelected = selectedGenres.contains(genre);
                    return ChoiceChip(
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedGenres.add(genre);
                          } else {
                            selectedGenres.remove(genre);
                          }
                          controller.setGenres(selectedGenres);
                        });
                      },
                    );
                  }).toList(),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  showAllGenres = !showAllGenres;
                });
              },
              child: Text(showAllGenres ? 'Weniger anzeigen' : 'Mehr anzeigen'),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text("Jahr", style: TextStyle(fontSize: _fontSize)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: TextField(
                      controller: TextEditingController(
                        text: yearFrom != 0 ? yearFrom.toString() : '',
                      ),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: "von"),
                      onChanged: (text) => controller.setYearFrom(text),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: TextField(
                      controller: TextEditingController(
                        text: yearTo != 6000 ? yearTo.toString() : '',
                      ),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: "bis"),
                      onChanged: (text) => controller.setYearTo(text),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text("Sortieren", style: TextStyle(fontSize: _fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownMenu(
                    initialSelection: controller.model.filter.sortBy,
                    controller: dropdownController,
                    dropdownMenuEntries:
                        sortOptions.map<DropdownMenuEntry<String>>((
                          String value,
                        ) {
                          return DropdownMenuEntry<String>(
                            value: value,
                            label: value,
                          );
                        }).toList(),
                    onSelected: (value) {
                      dropdownController.text = value!;
                      if (value == 'Dauer') {
                        controller.model.filter.movie = 1;
                        setState(() {
                          tvIsSelected = false;
                          movieIsSelected = true;
                        });
                      }
                      controller.setSortBy(value.toString());
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child:
                        accending
                            ? IconButton(
                              icon: const Icon(Icons.arrow_downward),
                              onPressed: () {
                                _toggleAccending();
                              },
                            )
                            : IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              onPressed: () {
                                _toggleAccending();
                              },
                            ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
                  () => Navigator.of(context).pop(controller.model.filter),
              child: Text('Anwenden', style: TextStyle(fontSize: _fontSize)),
            ),
          ),
        ),
      ),
    );
  }
}
