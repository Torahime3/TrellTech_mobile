import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:trelltech/controllers/card_controller.dart';
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/storage/authtoken_storage.dart';
import 'card_test.mocks.dart';

@GenerateMocks([http.Client, AuthTokenStorage])
void main() {
  late MockClient mockClient;
  late MockAuthTokenStorage mockAuthTokenStorage;
  late CardController cardController;
  late ListModel mockList;
  String? apiKey;

  setUpAll(() async {
    await dotenv.load();
    apiKey = dotenv.env['API_KEY'];

    mockClient = MockClient();
    mockAuthTokenStorage = MockAuthTokenStorage();
    cardController = CardController(
        client: mockClient, authTokenStorage: mockAuthTokenStorage);
    mockList = ListModel(id: '1', name: 'Test List');

    when(mockAuthTokenStorage.getAuthToken()).thenAnswer((_) async => 'token');
  });

  group('getCards -', () {
    test('returns a list of cards if the http call completes successfully',
        () async {
      const cardId = "1";
      const cardName = "Test Card";
      when(mockClient.get(
              Uri.parse(
                  'https://api.trello.com/1/lists/${mockList.id}/cards?key=$apiKey&token=token'),
              headers: anyNamed('headers')))
          .thenAnswer((_) async =>
              http.Response('[{"id":"1","name":"$cardName"}]', 200));

      final cards = await cardController.getCards(list: mockList);

      expect(cards.isNotEmpty, true);
      expect(cards.first, isA<CardModel>());
      expect(cards.first.id, cardId);
      expect(cards.first.name, cardName);
    });

    test('throws an exception if the http call to get cards fails', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() async => await cardController.getCards(list: mockList),
          throwsException);
    });
  });

  group('create - ', () {
    const cardName = 'New Card';
    const cardId = 'newCardId';

    test('successfully creates a card and returns CardModel', () async {
      when(mockClient.post(
        Uri.parse(
            'https://api.trello.com/1/cards?idList=${mockList.id}&key=$apiKey&token=token&name=$cardName'),
        body: anyNamed('body'),
      )).thenAnswer((_) async =>
          http.Response('{"id": "$cardId", "name": "$cardName"}', 200));

      final result = await cardController.create(mockList.id, cardName);

      expect(result, isA<CardModel>());
      expect(result.id, cardId);
      expect(result.name, cardName);
    });

    test('throws an exception if the http call to create a card fails',
        () async {
      when(mockClient.post(
        Uri.parse(
            'https://api.trello.com/1/cards?idList=${mockList.id}&key=$apiKey&token=token&name=$cardName'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      expect(cardController.create(mockList.id, cardName), throwsException);
    });
  });

  group('update -', () {
    const cardId = 'existingCardId';
    const updatedCardName = 'Updated Card';

    test('successfully updates a card and returns updated CardModel', () async {
      when(mockClient.put(
        Uri.parse(
            'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=token&name=$updatedCardName'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async =>
          http.Response('{"id": "$cardId", "name": "$updatedCardName"}', 200));

      final result = await cardController.update(cardId, updatedCardName);

      expect(result, isA<CardModel>());
      expect(result.id, cardId);
      expect(result.name, updatedCardName);
    });

    test('throws an exception if the http call to update a card fails',
        () async {
      when(mockClient.put(
        Uri.parse(
            'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=token&name=$updatedCardName'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      expect(() => cardController.update(cardId, updatedCardName),
          throwsException);
    });
  });

  group('delete -', () {
    const cardId = 'existingCardId';

    test('successfully deletes a card', () async {
      when(mockClient.delete(
        Uri.parse(
            'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=token'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('', 200));

      final result = await cardController.delete(cardId);

      expect(result, true);
    });

    test('throws an exception if the http call to delete a card fails',
        () async {
      when(mockClient.delete(
        Uri.parse(
            'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=token'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      expect(() => cardController.delete(cardId), throwsException);
    });
  });
}
