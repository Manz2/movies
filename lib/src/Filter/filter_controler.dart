import 'package:flutter/src/material/slider_theme.dart';
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
    _model.filter.fsk.contains("FSK0")
        ? _model.filter.fsk.remove("FSK0")
        : _model.filter.fsk.add("FSK0");
  }

  void setFsk6() {
    _model.filter.fsk.contains("FSK6")
        ? _model.filter.fsk.remove("FSK6")
        : _model.filter.fsk.add("FSK6");
  }

  void setFsk12() {
    _model.filter.fsk.contains("FSK12")
        ? _model.filter.fsk.remove("FSK12")
        : _model.filter.fsk.add("FSK12");
  }

  void setFsk16() {
    _model.filter.fsk.contains("FSK16")
        ? _model.filter.fsk.remove("FSK16")
        : _model.filter.fsk.add("FSK16");
  }

  void setFsk18() {
    _model.filter.fsk.contains("FSK18")
        ? _model.filter.fsk.remove("FSK18")
        : _model.filter.fsk.add("FSK18");
  }

  void setDuration(RangeValues values) {
    _model.filter.durationFrom =
        values.start.toInt(); // Umwandlung von double zu int
    _model.filter.durationTo =
        values.end.toInt(); // Umwandlung von double zu int
  }

  setYearFrom(String text) {
    _model.filter.yearFrom = int.parse(text);
  }

  setYearTo(String text) {
    _model.filter.yearTo = int.parse(text);
  }

  void resetFilter() {
    model.filter = Filter(
        movie: 3,
        fsk: [],
        durationFrom: 60,
        durationTo: 120,
        rating: 0,
        yearFrom: 0,
        yearTo: 6000);
  }
}
