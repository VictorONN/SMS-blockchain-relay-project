import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:relay_mobile/pages/home_page.dart';


enum NavigationEvents {
  DashboardClickedEvent,
}

abstract class NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  NavigationBloc() : super(HomePage()) {
    on<NavigationEvents>((event, emit) {
      switch (event) {
        case NavigationEvents.DashboardClickedEvent:
          emit(HomePage());
      }
    });
  }
  // @override
  // NavigationStates get initialState => MyAccountsPage();

  // // final Product product;
  // NavigationBloc(initialState, MyAccountsPage()) : super(initialState);

  // @override
  // Stream<NavigationStates> mapEventToState(NavigationEvents event) async* {
  //   print(event);
  //   switch (event) {
  //     case NavigationEvents.DashboardClickedEvent:
  //       yield const DashboardGallery();
  //       break;

  //     case NavigationEvents.MyAccountClickedEvent:
  //       yield MyAccountsPage();
  //       break;
  //   }
  // }
}
