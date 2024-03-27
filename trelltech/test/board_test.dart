import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trelltech/controllers/board_controller.dart';
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/storage/authtoken_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'board_test.mocks.dart';

@GenerateMocks([http.Client, AuthTokenStorage])
void main() {
  late MockClient mockClient;
  late MockAuthTokenStorage mockAuthTokenStorage;
  late BoardController boardController;
  String? apiKey;

  group('Boards -', () {
    setUpAll(() async {
      await dotenv.load();
      apiKey = dotenv.env['API_KEY'];

      mockClient = MockClient();
      mockAuthTokenStorage = MockAuthTokenStorage();
      boardController = BoardController(
        client: mockClient,
        authTokenStorage: mockAuthTokenStorage,
      );

      when(mockAuthTokenStorage.getAuthToken())
          .thenAnswer((_) async => 'token');
    });

    group('get -', () {
      test(
          'fetchBoards returns a list of boards if the http call completes successfully',
          () async {
        when(mockClient.get(
                Uri.parse(
                    'https://api.trello.com/1/members/trelltech12/boards?key=$apiKey&token=token'),
                headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '[{"id":"1","name":"Board 1","memberships":[{"idMember":"65e58f09e1fc28da619e20e2"}]}, {"id":"2","name":"Board 2","memberships":[{"idMember":"65e58f09e1fc28da619e20e2"}]}]',
                200));

        final boards = await boardController.getBoards();

        expect(boards.isNotEmpty, true);
        expect(boards.first, isA<BoardModel>());
        expect(boards.first.id, '1');
        expect(boards.first.name, 'Board 1');

        expect(boards.last, isA<BoardModel>());
        expect(boards.last.id, '2');
        expect(boards.last.name, 'Board 2');
      });

      test(
          'fetchBoards throws an exception if the http call completes with an error',
          () async {
        when(mockClient.get(
                Uri.parse(
                    'https://api.trello.com/1/members/trelltech12/boards?key=$apiKey&token=token'),
                headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        expect(() => boardController.getBoards(), throwsException);
      });
    });
    group('create -', () {
      test('successfully creates a board and triggers callback', () async {
        when(mockClient.post(any, body: anyNamed('body'))).thenAnswer(
          (_) async => http.Response(
              '{"id":"3","name":"New Board","memberships":[{"idMember":"65e58f09e1fc28da619e20e2"}]}',
              200),
        );

        final resultBoard = await boardController.create(name: "New Board");

        expect(resultBoard, isA<BoardModel>());
        expect(resultBoard.id, "3");
        expect(resultBoard.name, "New Board");
      });

      test('throws an exception if the http call to create a board fails',
          () async {
        when(mockClient.post(any, body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('No board created', 400));

        expect(() => boardController.create(name: 'Failed Board'),
            throwsException);
      });
    });
  });

  group('update -', () {
    test('successfully updates a board and returns updated BoardModel',
        () async {
      when(mockClient.put(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
            '{"id":"1","name":"Updated Board","memberships":[{"idMember":"65e58f09e1fc28da619e20e2"}]}',
            200),
      );

      final resultBoard =
          await boardController.update(id: "1", name: "Updated Board");

      expect(resultBoard, isA<BoardModel>());
      expect(resultBoard.id, "1");
      expect(resultBoard.name, "Updated Board");
    });

    test('throws an exception if the http call to update a board fails',
        () async {
      when(mockClient.put(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('Error', 400),
      );

      expect(
        () => boardController.update(id: '1', name: 'Failed Update'),
        throwsException,
      );
    });
  });

  group('delete -', () {
    test('successfully deletes a board', () async {
      when(mockClient.delete(any))
          .thenAnswer((_) async => http.Response('Successfully deleted', 200));

      await boardController.delete(id: '1');

      verify(mockClient.delete(any)).called(1);
    });

    test('throws an exception if the http call to delete a board fails',
        () async {
      when(mockClient.delete(any))
          .thenAnswer((_) async => http.Response('Error', 400));

      expect(() => boardController.delete(id: '1'), throwsException);
    });
  });
}
