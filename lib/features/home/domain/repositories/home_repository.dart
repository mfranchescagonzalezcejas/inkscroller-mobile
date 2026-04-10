import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/home_chapter.dart';

class HomeRepository {
  Future<Either<Failure, List<HomeChapter>>> getLatestChapters({int limit = 10}) {
    throw UnimplementedError();
  }
}
