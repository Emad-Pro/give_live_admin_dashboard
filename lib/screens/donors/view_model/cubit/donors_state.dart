part of 'donors_cubit.dart';

class DonorsState {
  final RequestState getDonorState;
  final List<Map<String, dynamic>> donorData;

  DonorsState(
      {this.getDonorState = RequestState.initial, this.donorData = const []});

  DonorsState copyWith({
    RequestState? getDonorState,
    List<Map<String, dynamic>>? donorData,
  }) {
    return DonorsState(
      getDonorState: getDonorState ?? this.getDonorState,
      donorData: donorData ?? this.donorData,
    );
  }
}
