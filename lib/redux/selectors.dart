import 'package:flutter/material.dart';
import 'package:sink/common/calendar.dart';
import 'package:sink/common/exceptions.dart';
import 'package:sink/models/category.dart';
import 'package:sink/models/entry.dart';
import 'package:sink/redux/state.dart';

Entry getLastRemoved(AppState state) => state.removed.last;

Set<Color> getUsedColors(AppState state) =>
    state.categories.map((category) => category.color).toSet();

Set<Color> getAvailableColors(AppState state) => state.availableColors;

Set<Category> getCategories(AppState state) => state.categories;

Set<Category> getExpenseCategories(AppState state) => state.categories
    .where((category) => category.type == CategoryType.EXPENSE)
    .toSet();

Set<Category> getIncomeCategories(AppState state) => state.categories
    .where((category) => category.type == CategoryType.INCOME)
    .toSet();

Category getCategory(AppState state, String id) =>
    state.categories.firstWhere((category) {
      return category.id == id;
    }, orElse: () {
      throw CategoryNotFound("Could not find a category with id[$id]");
    });

Color getCategoryColor(AppState state, String id) =>
    getCategory(state, id).color;

bool areCategoriesLoading(AppState state) => state.areCategoriesLoading;

DateTime getStatisticsMonthStart(AppState state) =>
    firstDay(state.statisticsDate);

DateTime getStatisticsMonthEnd(AppState state) => lastDay(state.statisticsDate);
