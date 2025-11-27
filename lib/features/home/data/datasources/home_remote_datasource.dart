import 'package:cowork_frontend/core/network/dio_client.dart';
import 'package:cowork_frontend/core/constants/api_endpoints.dart';
import '../models/space_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<SpaceModel>> getSpaces();
  Future<List<SpaceModel>> getFeaturedSpaces();
  Future<List<SpaceModel>> searchSpaces(String query);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient dioClient;

  HomeRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<SpaceModel>> getSpaces() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.spaces);
      final List<dynamic> data = response.data;
      return data.map((json) => SpaceModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SpaceModel>> getFeaturedSpaces() async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.spaces,
        queryParameters: {'featured': true},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => SpaceModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SpaceModel>> searchSpaces(String query) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.spaces,
        queryParameters: {'search': query},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => SpaceModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
