part of 'service_form_cubit.dart';

@immutable
abstract class ServiceFormState {
  const ServiceFormState();
}

class ServiceFormInitial extends ServiceFormState {
  const ServiceFormInitial() : super();
}

class ServiceFormLoaded extends ServiceFormState {
  final int selectedTab;
  final DateTime? date;
  final List<Service> services;
  final List<Price> prices;
  final List<Service> selectedServices;

  const ServiceFormLoaded(
    this.selectedTab,
    this.date,
    this.services,
    this.prices,
    this.selectedServices,
  ) : super();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServiceFormLoaded &&
        other.selectedTab == selectedTab &&
        other.date == date &&
        listEquals(other.services, services) &&
        listEquals(other.prices, prices) &&
        listEquals(other.selectedServices, selectedServices);
  }

  @override
  int get hashCode {
    return selectedTab.hashCode ^
        date.hashCode ^
        services.hashCode ^
        prices.hashCode ^
        selectedServices.hashCode;
  }

  ServiceFormLoaded copyWith({
    int? selectedTab,
    DateTime? date,
    List<Service>? services,
    List<Price>? prices,
    List<Service>? selectedServices,
  }) {
    return ServiceFormLoaded(
      selectedTab ?? this.selectedTab,
      date ?? this.date,
      services ?? this.services,
      prices ?? this.prices,
      selectedServices ?? this.selectedServices,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedTab': selectedTab,
      'date': date?.millisecondsSinceEpoch,
      'services': services.map((x) => x.toMap()).toList(),
      'prices': prices.map((x) => x.toMap()).toList(),
      'selectedServices': selectedServices.map((x) => x.toMap()).toList(),
    };
  }

  factory ServiceFormLoaded.fromMap(Map<String, dynamic> map) {
    return ServiceFormLoaded(
      map['selectedTab']?.toInt() ?? 0,
      map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : null,
      List<Service>.from(map['services']?.map((x) => Service.fromMap(x))),
      List<Price>.from(map['prices']?.map((x) => Price.fromMap(x))),
      List<Service>.from(
          map['selectedServices']?.map((x) => Service.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceFormLoaded.fromJson(String source) =>
      ServiceFormLoaded.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ServiceFormLoaded(selectedTab: $selectedTab, date: $date, services: $services, prices: $prices, selectedServices: $selectedServices)';
  }
}

class ServiceFormError extends ServiceFormState {
  final String _message;
  const ServiceFormError(this._message) : super();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServiceFormError && other._message == _message;
  }

  @override
  int get hashCode => _message.hashCode;
}
