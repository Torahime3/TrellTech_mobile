import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trelltech/controllers/list_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/storage/authtoken_storage.dart';

import 'list_test.mocks.dart';

@GenerateMocks([http.Client, AuthTokenStorage])
void main() {
  late MockClient mockClient;
  late MockAuthTokenStorage mockAuthTokenStorage;
  late ListController listController;
  String? apiKey;

  group('Lists -', () {
    setUpAll(() async {
      await dotenv.load();
      apiKey = dotenv.env['API_KEY'];

      mockClient = MockClient();
      mockAuthTokenStorage = MockAuthTokenStorage();
      listController = ListController(
        client: mockClient,
        authTokenStorage: mockAuthTokenStorage,
      );

      when(mockAuthTokenStorage.getAuthToken())
          .thenAnswer((_) async => 'token');
    });

    group('getLists -', () {
      test('returns a list of lists if the http call completes successfully',
          () async {
        when(mockClient.get(
                Uri.parse(
                    'https://api.trello.com/1/boards/1/lists?key=$apiKey&token=token'),
                headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '[{"id":"1","name":"Test List 1", "pos":16384}, {"id":"2","name":"Test List 2", "pos": 32768}]',
                200));

        final lists = await listController.getLists(
            board: BoardModel(id: '1', name: 'Test Board'));

        expect(lists.isNotEmpty, true);
        expect(lists.first, isA<ListModel>());
        expect(lists.first.id, '1');
        expect(lists.first.name, 'Test List 1');
        expect(lists.first.pos, 16384);
        expect(lists.last, isA<ListModel>());
        expect(lists.last.id, '2');
        expect(lists.last.name, 'Test List 2');
        expect(lists.last.pos, 32768);
      });

      test('throws an exception if the http call to get lists fails', () async {
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        expect(
            () async => await listController.getLists(
                board: BoardModel(id: '1', name: 'Failed Board')),
            throwsException);
      });
    });

    group('create -', () {
      test('successfully creates a list and returns ListModel', () async {
        when(mockClient.post(any, body: anyNamed('body'))).thenAnswer(
            (_) async => http.Response(
                '{"id":"1", "name":"Test List", "pos": 16384}', 200));

        final result = await listController.create("Test List",
            board: BoardModel(id: '1', name: 'Test Board'));

        expect(result, isA<ListModel>());
        expect(result.id, "1");
        expect(result.name, "Test List");
        expect(result.pos, 16384);
      });

      test('throws an exception if the http call to create a list fails',
          () async {
        when(mockClient.post(any, body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('Error', 400));

        expect(
            () async => await listController.create('Failed List',
                board: BoardModel(id: '1', name: 'Dummy Board')),
            throwsException);
      });
    });

    group('update -', () {
      const updatedListId = "1";
      const updatedListName = "Updated List";
      const updatedListPos = 16384;
      test('successfully updates a list and returns updated ListModel',
          () async {
        when(mockClient.put(any, body: anyNamed('body'))).thenAnswer(
            (_) async => http.Response(
                '{"id":"$updatedListId", "name":"$updatedListName", "pos": $updatedListPos}',
                200));

        final result = await listController.update(
          id: updatedListId,
          name: updatedListName,
          pos: updatedListPos,
        );

        expect(result, isA<ListModel>());
        expect(result.id, updatedListId);
        expect(result.name, updatedListName);
        expect(result.pos, updatedListPos);
      });

      test('throws an exception if the http call to update a list fails',
          () async {
        when(mockClient.put(any, body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('Error', 400));

        expect(
            () async => await listController.update(
                  id: 'failListId',
                  name: 'Failed Update',
                ),
            throwsException);
      });
    });

    group('delete -', () {
      test('successfully deletes a list', () async {
        when(mockClient.put(any, body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('', 200));

        final result = await listController.delete(id: '1');

        expect(result, true);
      });

      test('throws an exception if the http call to delete a list fails',
          () async {
        when(mockClient.put(any, body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('Error', 400));

        expect(() async => await listController.delete(id: 'failListId'),
            throwsException);
      });
    });
  });
}
