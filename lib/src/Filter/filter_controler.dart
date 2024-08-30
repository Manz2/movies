import 'package:flutter/src/material/slider_theme.dart';
import 'package:movies/src/Filter/filter_model.dart';

class FilterController {
  final FilterModel _model;
  FilterController({required Filter filter})
      : _model = FilterModel(filter: filter);
  FilterModel get model => _model;

  setMovie() {}

  setTv() {}

  void setFsk0() {}

  void setFsk6() {}

  void setFsk12() {}

  void setFsk16() {}

  void setFsk18() {}

  void setDuration(RangeValues values) {}

  setYearFrom(String text) {}

  setYearTo(String text) {}

  void resetFilter() {}
}

/*
filter: Filter(
    movie: 3,
    fsk: [],
    durationFrom: 0,
    durationTo: 400,
    rating: 0,
    yearFrom: 0,
    yearTo: 6000);
*/
