import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:movies/src/Filter/filter_controler.dart';
import 'package:movies/src/Filter/filter_model.dart';

class FilterView extends StatefulWidget {
  static const routeName = '/filter';
  final Filter filter;

  const FilterView({super.key, required this.filter});

  @override
  State<StatefulWidget> createState() => FilterViewState();
}

class FilterViewState extends State<FilterView> {
  late final FilterController controller;
  bool movieIsSelected = false;
  bool tvIsSelected = false;
  bool fsk0 = false;
  bool fsk6 = false;
  bool fsk12 = false;
  bool fsk16 = false;
  bool fsk18 = false;
  RangeValues _durationrange = const RangeValues(60, 120);
  double rating = 1;
  int yearFrom = 0;
  int yearTo = 6000;

  @override
  void initState() {
    controller = FilterController(filter: widget.filter);
    setState(() {
      movieIsSelected = controller.model.filter.movie == 1 ||
          controller.model.filter.movie == 3;
      tvIsSelected = controller.model.filter.movie == 2 ||
          controller.model.filter.movie == 3;
      fsk0 = controller.model.filter.fsk.contains('FSK0');
      fsk6 = controller.model.filter.fsk.contains('FSK6');
      fsk12 = controller.model.filter.fsk.contains('FSK12');
      fsk16 = controller.model.filter.fsk.contains('FSK16');
      fsk18 = controller.model.filter.fsk.contains('FSK18');
      _durationrange = RangeValues(
          controller.model.filter.durationFrom.toDouble(),
          controller.model.filter.durationTo.toDouble());
      rating = controller.model.filter.rating;
      yearFrom = controller.model.filter.yearFrom;
      yearTo = controller.model.filter.yearTo;
    });
    super.initState();
  }

  _toggleMovieButton() {
    controller.setMovie();
    setState(() {
      movieIsSelected = !movieIsSelected; // Wechseln des Zustands
    });
  }

  _toggleTvButton() {
    controller.setTv();
    setState(() {
      tvIsSelected = !tvIsSelected; // Wechseln des Zustands
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

  @override
  Widget build(BuildContext context) {
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
                  movieIsSelected = false;
                  tvIsSelected = false;
                  fsk0 = false;
                  fsk6 = false;
                  fsk12 = false;
                  fsk16 = false;
                  fsk18 = false;
                  _durationrange = const RangeValues(60, 120);
                  rating = 1;
                  yearFrom = 0;
                  yearTo = 6000; // Wechseln des Zustands
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
                      style: movieIsSelected
                          ? ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                              foregroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.onPrimary),
                            )
                          : null,
                      onPressed: _toggleMovieButton,
                      child: const Text('Filme')),
                  ElevatedButton(
                      style: tvIsSelected
                          ? ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                              foregroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.onPrimary),
                            )
                          : null,
                      onPressed: _toggleTvButton,
                      child: const Text('Serien'))
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text("FSK"),
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
                          child: fsk0
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
                          child: fsk6
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
                          child: fsk12
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
                          child: fsk16
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
                          child: fsk18
                              ? Image.asset('assets/images/FSK18.png')
                              : Image.asset('assets/images/FSK18-bw.png'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text("Dauer"),
              ),
              RangeSlider(
                values: _durationrange,
                max: 180,
                min: 30,
                labels: RangeLabels(
                  _durationrange.start.round().toString(),
                  _durationrange.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  controller.setDuration(values);
                  setState(() {
                    _durationrange = values;
                  });
                },
                divisions: 30,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: Text("Bewertung"),
              ),
              StarRating(
                mainAxisAlignment: MainAxisAlignment.center,
                size: 60.0,
                rating: rating,
                color: Colors.orange,
                borderColor: Colors.grey,
                allowHalfRating: true,
                starCount: 5,
                onRatingChanged: (rating) => setState(() {
                  this.rating = rating;
                }),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: Text("Jahr"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: TextField(
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
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "bis"),
                        onChanged: (text) => controller.setYearTo(text),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 40, 25, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () =>
                          Navigator.of(context).pop(controller.model.filter),
                      child: const Text('Anwenden')),
                ),
              )
            ],
          ),
        ));
  }
}