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
                    'https://api.trello.com/1/members/trelltech12/boards?key=${dotenv.env['API_KEY']}&token=token'),
                headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '[{"id":"1","name":"Board 1"}, {"id":"2","name":"Board 2"}]',
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
                    'https://api.trello.com/1/members/trelltech12/boards?key=${dotenv.env['API_KEY']}&token=token'),
                headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        expect(() => boardController.getBoards(), throwsException);
      });
    });
    group('create -', () {
      test('successfully creates a board and triggers callback', () async {
        const newBoardName = "New Board";
        const newBoardId = "3";
        const expectedBoardJson =
            '{"id":"$newBoardId", "name":"$newBoardName"}';

        when(mockClient.post(any, body: anyNamed('body'))).thenAnswer(
          (_) async => http.Response(expectedBoardJson, 200),
        );

        final resultBoard = await boardController.create(name: newBoardName);

        expect(resultBoard, isA<BoardModel>());
        expect(resultBoard.id, newBoardId);
        expect(resultBoard.name, newBoardName);
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
      const updatedBoardId = "1";
      const updatedBoardName = "Updated Board";
      const expectedBoardJson =
          '{"id":"$updatedBoardId", "name":"$updatedBoardName"}';

      when(mockClient.put(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(expectedBoardJson, 200),
      );

      final resultBoard =
          await boardController.update(updatedBoardId, updatedBoardName);

      expect(resultBoard, isA<BoardModel>());
      expect(resultBoard.id, updatedBoardId);
      expect(resultBoard.name, updatedBoardName);
    });

    test('throws an exception if the http call to update a board fails',
        () async {
      when(mockClient.put(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('Error', 400),
      );

      expect(
        () => boardController.update('1', 'Failed Update'),
        throwsException,
      );
    });
  });
}
