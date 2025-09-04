import 'package:flutter/material.dart';
import 'package:movies/src/Filter/filter_model.dart';

class FilterController {
  final FilterModel _model;
  FilterController({required Filter filter})
      : _model = FilterModel(filter: filter);
  FilterModel get model => _model;

  void setMovie() {
    switch (_model.filter.movie) {
      case 1:
        _model.filter.movie = 3;
        break;
      case 2:
        _model.filter.movie = 3;
        break;
      case 3:
        _model.filter.movie = 2;
        break;
      default:
        _model.filter.movie = 3;
    }
  }

  void setTv() {
    switch (_model.filter.movie) {
      case 1:
        _model.filter.movie = 3;
        break;
      case 2:
        _model.filter.movie = 3;
        break;
      case 3:
        _model.filter.movie = 1;
        break;
      default:
        _model.filter.movie = 3;
    }
  }

  void setFsk0() {
    _model.filter.fsk.contains("0")
        ? _model.filter.fsk.remove("0")
        : _model.filter.fsk.add("0");
  }

  void setFsk6() {
    _model.filter.fsk.contains("6")
        ? _model.filter.fsk.remove("6")
        : _model.filter.fsk.add("6");
  }

  void setFsk12() {
    _model.filter.fsk.contains("12")
        ? _model.filter.fsk.remove("12")
        : _model.filter.fsk.add("12");
  }

  void setFsk16() {
    _model.filter.fsk.contains("16")
        ? _model.filter.fsk.remove("16")
        : _model.filter.fsk.add("16");
  }

  void setFsk18() {
    _model.filter.fsk.contains("18")
        ? _model.filter.fsk.remove("18")
        : _model.filter.fsk.add("18");
  }

  void setDuration(RangeValues values) {
    _model.filter.durationFrom =
        values.start.toInt(); // Umwandlung von double zu int
    _model.filter.durationTo =
        values.end.toInt(); // Umwandlung von double zu int
  }

  void setYearFrom(String text) {
    if (text.isNotEmpty) {
      _model.filter.yearFrom = int.parse(text);
    } else {
      _model.filter.yearFrom = 0;
    }
  }

  void setYearTo(String text) {
    if (text.isNotEmpty) {
      _model.filter.yearTo = int.parse(text);
    } else {
      _model.filter.yearFrom = 6000;
    }
  }

  void setGenres(List<String> genres) {
    _model.filter.genres = genres;
  }

  void setRating(double rating) {
    _model.filter.rating = rating;
  }

  void setSortBy(String value) {
    _model.filter.sortBy = value;
  }

  void setAccending() {
    _model.filter.accending = !_model.filter.accending;
  }

  void resetFilter() {
    model.filter = Filter(
        movie: 3,
        fsk: [],
        durationFrom: 30,
        durationTo: 180,
        rating: 0,
        yearFrom: 0,
        yearTo: 6000,
        sortBy: 'Standard',
        accending: false,
        genres: []);
  }
}
