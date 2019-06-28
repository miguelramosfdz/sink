import 'package:flutter/material.dart' as Material;
import 'package:sink/common/exceptions.dart';
import 'package:sink/models/category.dart';
import 'package:sink/models/entry.dart';
import 'package:sink/redux/selectors.dart';
import 'package:sink/redux/state.dart';
import 'package:test/test.dart';

const white = Material.Colors.white;
const blue = Material.Colors.blue;
const black = Material.Colors.black;
const red = Material.Colors.red;

main() {
  test('retrieves last removed entry', () {
    var state = AppState(removed: [
      Entry(
        amount: 1.0,
        date: DateTime.now(),
        categoryId: 'a',
        description: 'b',
        type: EntryType.EXPENSE,
      ),
      Entry(
        amount: 2.0,
        date: DateTime.now(),
        categoryId: 'c',
        description: 'd',
        type: EntryType.EXPENSE,
      ),
    ]);

    var entry = getLastRemoved(state);

    expect(entry, state.removed[1]);
  });

  test('retrieves used colors', () {
    var state = AppState(
      categories: Set<Category>.from([
        Category(id: '1', name: '1', icon: '', color: white, type: null),
        Category(id: '2', name: '2', icon: '', color: blue, type: null),
        Category(id: '3', name: '3', icon: '', color: black, type: null),
      ]),
    );

    var colors = getUsedColors(state);

    var expected = Set<Material.Color>.from([white, blue, black]);
    expect(colors.length, 3);
    expect(colors, expected);
  });

  test('retrieves a set of categories', () {
    var cat = Category(
      id: '1',
      name: '1',
      icon: '',
      color: red,
      type: null,
    );
    var state = AppState(categories: Set<Category>.from([cat]));

    var categories = getCategories(state);

    expect(categories.length, 1);
    expect(categories.first, cat);
  });

  test('retrieves a set of expense categories', () {
    var first = Category(
      id: '1',
      icon: '',
      name: 'expense 1',
      color: red,
      type: CategoryType.EXPENSE,
    );

    var second = Category(
      id: '2',
      icon: '',
      name: 'expense 2',
      color: red,
      type: CategoryType.INCOME,
    );

    var third = Category(
      id: '3',
      name: 'income',
      icon: '',
      color: red,
      type: CategoryType.EXPENSE,
    );

    var st = AppState(categories: Set<Category>.from([first, second, third]));

    var result = getExpenseCategories(st);

    expect(result.length, 2);
    expect(result, Set.from([first, third]));
  });

  test('does not retrieve any expense categories from empty set', () {
    var state = AppState(categories: Set<Category>.from([]));

    var result = getExpenseCategories(state);

    expect(result.length, 0);
  });

  test('retrieves a set of income categories', () {
    var first = Category(
      id: '1',
      name: 'expense 1',
      icon: '',
      color: red,
      type: CategoryType.EXPENSE,
    );

    var second = Category(
      id: '2',
      name: 'expense 2',
      icon: '',
      color: red,
      type: CategoryType.INCOME,
    );

    var third = Category(
      id: '3',
      name: 'income',
      icon: '',
      color: red,
      type: CategoryType.EXPENSE,
    );

    var st = AppState(categories: Set<Category>.from([first, second, third]));

    var result = getIncomeCategories(st);

    expect(result.length, 1);
    expect(result, Set.from([second]));
  });

  test('does not retrieve any income categories from empty set', () {
    var state = AppState(categories: Set<Category>.from([]));

    var result = getIncomeCategories(state);

    expect(result.length, 0);
  });

  test('should retrieve a category by id', () {
    var state = AppState(
      categories: Set<Category>.from([
        Category(id: '1', name: '1', icon: '', color: white, type: null),
        Category(id: '2', name: '2', icon: '', color: blue, type: null),
        Category(id: '3', name: '3', icon: '', color: black, type: null),
      ]),
    );

    var category = getCategory(state, '2');

    expect(category,
        Category(id: '2', name: '2', icon: '', color: blue, type: null));
  });

  test('should indicate that a category could not be found', () {
    var state = AppState(
      categories: Set<Category>.from([
        Category(id: '1', name: '1', icon: '', color: white, type: null),
        Category(id: '2', name: '2', icon: '', color: blue, type: null),
        Category(id: '3', name: '3', icon: '', color: black, type: null),
      ]),
    );

    expect(
      () => getCategory(state, '51'),
      throwsA(TypeMatcher<CategoryNotFound>()),
    );
  });

  test('indicates wheter the categories are loading', () {
    var state = AppState();
    expect(areCategoriesLoading(state), true);

    state = state.copyWith(areCategoriesLoading: false);
    expect(areCategoriesLoading(state), false);
  });

  test('retrieves available colors', () {
    var colors = Set<Material.Color>.from([Material.Colors.red]);
    var state = AppState(availableColors: colors);

    var result = getAvailableColors(state);

    expect(result, Set.from([Material.Colors.red]));
  });

  test("finds category's colour", () {
    var cat1 = Category(id: '1', name: '1', icon: '', color: white, type: null);
    var cat2 = Category(id: '2', name: '2', icon: '', color: blue, type: null);
    var cat3 = Category(id: '3', name: '3', icon: '', color: black, type: null);
    var state = AppState(
      categories: Set<Category>.from([cat1, cat2, cat3]),
    );

    var c1 = getCategoryColor(state, '1');
    var c2 = getCategoryColor(state, '2');
    var c3 = getCategoryColor(state, '3');

    expect(c1, cat1.color);
    expect(c2, cat2.color);
    expect(c3, cat3.color);
  });

  test('throws exception if color of non-existent category is requested', () {
    var state = AppState(
        categories: Set<Category>.from([
      Category(id: '1', name: '1', icon: '', color: white, type: null),
    ]));

    expect(
      () => getCategoryColor(state, 'non-existent'),
      throwsA(TypeMatcher<CategoryNotFound>()),
    );
  });

  test("retrieves month's start for statistics", () {
    var state1 = AppState(statisticsDate: DateTime(2000, 1, 27));
    var state2 = AppState(statisticsDate: DateTime(2000, 3, 5));
    var state3 = AppState(statisticsDate: DateTime(2000, 12, 7));

    var result1 = getStatisticsMonthStart(state1);
    var result2 = getStatisticsMonthStart(state2);
    var result3 = getStatisticsMonthStart(state3);

    expect(result1, DateTime(2000, 1, 1));
    expect(result2, DateTime(2000, 3, 1));
    expect(result3, DateTime(2000, 12, 1));
  });

  test("retrieves month's end for statistics", () {
    var state = AppState(statisticsDate: DateTime(2000, 1, 1));

    var result = getStatisticsMonthEnd(state);

    expect(result, DateTime(2000, 1, 31));
  });
}
