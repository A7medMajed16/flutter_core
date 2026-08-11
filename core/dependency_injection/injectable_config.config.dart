// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/local_datasources/auth_local_datasources.dart'
    as _i88;
import '../../features/auth/data/datasources/remote_datasources/auth_remote_datasources.dart'
    as _i353;
import '../../features/auth/data/repositories/auth_repo_impl.dart' as _i662;
import '../../features/auth/domain/repositories/auth_repo.dart' as _i723;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/presentation/bloc/account_info_cubit/account_info_cubit.dart'
    as _i786;
import '../../features/auth/presentation/bloc/cubit/login_cubit.dart' as _i500;
import '../../features/auth/presentation/bloc/forgot_password_cubit/forgot_password_cubit.dart'
    as _i110;
import '../../features/auth/presentation/bloc/register_cubit/register_cubit.dart'
    as _i759;
import '../../features/home/presentation/bloc/home_cubit/home_cubit.dart'
    as _i104;
import '../../features/my_programs/data/datasources/remote_datasources/my_programs_remote_datasources.dart'
    as _i962;
import '../../features/my_programs/data/repositories/my_programs_repo_impl.dart'
    as _i4;
import '../../features/my_programs/domain/repositories/my_programs_repo.dart'
    as _i1009;
import '../../features/my_programs/domain/usecases/get_my_programs_usecase.dart'
    as _i596;
import '../../features/my_programs/domain/usecases/get_term_attendance_usecase.dart'
    as _i439;
import '../../features/my_programs/domain/usecases/get_term_programs_usecase.dart'
    as _i304;
import '../../features/my_programs/presentation/bloc/my_programs_cubit.dart'
    as _i644;
import '../../features/news/data/datasources/remote_datasources/news_remote_datasource.dart'
    as _i1044;
import '../../features/news/data/repositories/news_repo_impl.dart' as _i691;
import '../../features/news/domain/repositories/news_repo.dart' as _i952;
import '../../features/news/domain/usecases/get_news_usecase.dart' as _i915;
import '../../features/news/presentation/bloc/news_cubit.dart' as _i103;
import '../../features/payments/presentation/bloc/payments_cubit/payments_cubit.dart'
    as _i641;
import '../../features/profile/data/datasources/local_datasources/profile_local_datasources.dart'
    as _i702;
import '../../features/profile/data/datasources/remote_datasources/profile_remote_datasource.dart'
    as _i940;
import '../../features/profile/data/repositories/profile_repo_impl.dart'
    as _i988;
import '../../features/profile/domain/repositories/profile_repo.dart' as _i790;
import '../../features/profile/domain/usecases/get_profile_usecase.dart'
    as _i965;
import '../../features/profile/presentation/bloc/profile_cubit/profile_cubit.dart'
    as _i113;
import '../../features/support/data/datasources/remote_datasources/support_remote_datasources.dart'
    as _i477;
import '../../features/support/data/repositories/support_repo_impl.dart'
    as _i735;
import '../../features/support/domain/repositories/support_repo.dart' as _i253;
import '../../features/support/domain/usecases/get_faqs_usecase.dart' as _i629;
import '../../features/support/presentation/bloc/support_cubit/support_cubit.dart'
    as _i69;
import '../api/client/dio_consumer.dart' as _i651;
import '../usecases/upload/upload_audio_usecase.dart' as _i958;
import '../usecases/upload/upload_document_usecase.dart' as _i363;
import '../usecases/upload/upload_image_usecase.dart' as _i811;
import '../usecases/upload/upload_images_usecase.dart' as _i947;
import '../usecases/upload/upload_video_usecase.dart' as _i115;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreInjectableModule = _$CoreInjectableModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreInjectableModule.prefs,
      preResolve: true,
    );
    gh.factory<_i786.AccountInfoCubit>(() => _i786.AccountInfoCubit());
    gh.factory<_i110.ForgotPasswordCubit>(() => _i110.ForgotPasswordCubit());
    gh.factory<_i759.RegisterCubit>(() => _i759.RegisterCubit());
    gh.factory<_i641.PaymentsCubit>(() => _i641.PaymentsCubit());
    gh.singleton<_i361.Dio>(() => coreInjectableModule.dio());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => coreInjectableModule.secureStorage,
    );
    gh.lazySingleton<_i88.AuthLocalDataSource>(
      () => _i88.AuthLocalDataSourceImpl(),
    );
    gh.singleton<_i651.DioConsumer>(
      () => coreInjectableModule.dioConsumer(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i702.ProfileLocalDatasources>(
      () => _i702.ProfileLocalDatasourcesImpl(),
    );
    gh.lazySingleton<_i958.UploadAudioUseCase>(
      () => _i958.UploadAudioUseCase(gh<_i651.DioConsumer>()),
    );
    gh.lazySingleton<_i363.UploadDocumentUseCase>(
      () => _i363.UploadDocumentUseCase(gh<_i651.DioConsumer>()),
    );
    gh.lazySingleton<_i811.UploadImageUseCase>(
      () => _i811.UploadImageUseCase(gh<_i651.DioConsumer>()),
    );
    gh.lazySingleton<_i947.UploadImagesUseCase>(
      () => _i947.UploadImagesUseCase(gh<_i651.DioConsumer>()),
    );
    gh.lazySingleton<_i115.UploadVideoUseCase>(
      () => _i115.UploadVideoUseCase(gh<_i651.DioConsumer>()),
    );
    gh.lazySingleton<_i353.AuthRemoteDataSource>(
      () => _i353.AuthRemoteDataSourceImpl(gh<_i651.DioConsumer>()),
    );
    gh.lazySingleton<_i477.SupportRemoteDataSource>(
      () => _i477.SupportRemoteDataSourceImpl(gh<_i651.DioConsumer>()),
    );
    gh.lazySingleton<_i962.MyProgramsRemoteDataSource>(
      () => _i962.MyProgramsRemoteDataSourceImpl(gh<_i651.DioConsumer>()),
    );
    gh.lazySingleton<_i1044.NewsRemoteDataSource>(
      () => _i1044.NewsRemoteDataSourceImpl(gh<_i651.DioConsumer>()),
    );
    gh.lazySingleton<_i940.ProfileRemoteDataSource>(
      () => _i940.ProfileRemoteDataSourceImpl(gh<_i651.DioConsumer>()),
    );
    gh.lazySingleton<_i790.ProfileRepo>(
      () => _i988.ProfileRepoImpl(
        gh<_i940.ProfileRemoteDataSource>(),
        gh<_i702.ProfileLocalDatasources>(),
      ),
    );
    gh.lazySingleton<_i253.SupportRepo>(
      () => _i735.SupportRepoImpl(gh<_i477.SupportRemoteDataSource>()),
    );
    gh.lazySingleton<_i952.NewsRepo>(
      () => _i691.NewsRepoImpl(gh<_i1044.NewsRemoteDataSource>()),
    );
    gh.lazySingleton<_i629.GetFaqsUseCase>(
      () => _i629.GetFaqsUseCase(gh<_i253.SupportRepo>()),
    );
    gh.factory<_i69.SupportCubit>(
      () => _i69.SupportCubit(
        gh<_i629.GetFaqsUseCase>(),
        gh<_i363.UploadDocumentUseCase>(),
      ),
    );
    gh.lazySingleton<_i1009.MyProgramsRepo>(
      () => _i4.MyProgramsRepoImpl(gh<_i962.MyProgramsRemoteDataSource>()),
    );
    gh.lazySingleton<_i723.AuthRepo>(
      () => _i662.AuthRepoImpl(
        gh<_i353.AuthRemoteDataSource>(),
        gh<_i88.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i915.GetNewsUseCase>(
      () => _i915.GetNewsUseCase(gh<_i952.NewsRepo>()),
    );
    gh.lazySingleton<_i965.GetProfileUseCase>(
      () => _i965.GetProfileUseCase(gh<_i790.ProfileRepo>()),
    );
    gh.lazySingleton<_i596.GetMyProgramsUsecase>(
      () => _i596.GetMyProgramsUsecase(gh<_i1009.MyProgramsRepo>()),
    );
    gh.lazySingleton<_i439.GetTermAttendanceUseCase>(
      () => _i439.GetTermAttendanceUseCase(gh<_i1009.MyProgramsRepo>()),
    );
    gh.lazySingleton<_i304.GetTermProgramsUseCase>(
      () => _i304.GetTermProgramsUseCase(gh<_i1009.MyProgramsRepo>()),
    );
    gh.factory<_i644.MyProgramsCubit>(
      () => _i644.MyProgramsCubit(
        gh<_i596.GetMyProgramsUsecase>(),
        gh<_i439.GetTermAttendanceUseCase>(),
        gh<_i304.GetTermProgramsUseCase>(),
      ),
    );
    gh.lazySingleton<_i188.LoginUsecase>(
      () => _i188.LoginUsecase(gh<_i723.AuthRepo>()),
    );
    gh.factory<_i103.NewsCubit>(
      () => _i103.NewsCubit(gh<_i915.GetNewsUseCase>()),
    );
    gh.factory<_i500.LoginCubit>(
      () => _i500.LoginCubit(gh<_i188.LoginUsecase>()),
    );
    gh.factory<_i104.HomeCubit>(
      () => _i104.HomeCubit(
        gh<_i915.GetNewsUseCase>(),
        gh<_i965.GetProfileUseCase>(),
      ),
    );
    gh.factory<_i113.ProfileCubit>(
      () => _i113.ProfileCubit(gh<_i965.GetProfileUseCase>()),
    );
    return this;
  }
}

class _$CoreInjectableModule extends _i291.CoreInjectableModule {}
